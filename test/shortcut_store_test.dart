import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_repository.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_store.dart';
import 'package:sreerajp_youtube_shortcut/src/youtube_launcher_service.dart';
import 'package:sreerajp_youtube_shortcut/src/youtube_url_formatter.dart';

void main() {
  ShortcutStore buildStore([ShortcutRepository? repository]) {
    return ShortcutStore(
      repository: repository ?? MemoryShortcutRepository(),
      formatter: const YoutubeUrlFormatter(),
      launcher: _FakeYoutubeLauncher(),
    );
  }

  test(
    'updates an existing shortcut and preserves id and created timestamp',
    () async {
      final ShortcutStore store = buildStore();

      await store.addShortcut(
        nameInput: 'Original Name',
        urlInput: 'https://youtu.be/abc123',
      );

      final ShortcutEntry beforeUpdate = store.entries.single;

      await Future<void>.delayed(const Duration(milliseconds: 1));

      await store.updateShortcut(
        id: beforeUpdate.id,
        nameInput: 'Updated Name',
        urlInput: 'https://www.youtube.com/shorts/newshortid',
      );

      final ShortcutEntry afterUpdate = store.entries.single;

      expect(afterUpdate.id, beforeUpdate.id);
      expect(afterUpdate.createdAtIso, beforeUpdate.createdAtIso);
      expect(afterUpdate.name, 'Updated Name');
      expect(
        afterUpdate.sourceUrl,
        'https://www.youtube.com/shorts/newshortid',
      );
      expect(
        afterUpdate.canonicalUrl,
        'https://www.youtube.com/shorts/newshortid',
      );
      expect(afterUpdate.targetType, ShortcutTargetType.shortVideo);
      expect(afterUpdate.updatedAt.isAfter(beforeUpdate.updatedAt), isTrue);
    },
  );

  test('prevents duplicate names when editing a different shortcut', () async {
    final ShortcutStore store = buildStore();

    await store.addShortcut(
      nameInput: 'News',
      urlInput: 'https://youtu.be/news123',
    );
    await store.addShortcut(
      nameInput: 'Music',
      urlInput: 'https://youtu.be/music123',
    );

    final ShortcutEntry musicShortcut = store.entries.firstWhere(
      (ShortcutEntry entry) => entry.name == 'Music',
    );

    await expectLater(
      store.updateShortcut(
        id: musicShortcut.id,
        nameInput: 'News',
        urlInput: 'https://youtu.be/music123',
      ),
      throwsA(isA<ShortcutValidationException>()),
    );

    expect(store.entries.map((ShortcutEntry entry) => entry.name), <String>[
      'Music',
      'News',
    ]);
  });

  test('keeps shortcut position when editing', () async {
    final ShortcutStore store = buildStore();

    await store.addShortcut(
      nameInput: 'First',
      urlInput: 'https://youtu.be/first123',
    );
    final String firstId = store.entries.single.id;

    await Future<void>.delayed(const Duration(milliseconds: 1));

    await store.addShortcut(
      nameInput: 'Second',
      urlInput: 'https://youtu.be/second123',
    );

    expect(store.entries.map((ShortcutEntry entry) => entry.name), <String>[
      'Second',
      'First',
    ]);

    await Future<void>.delayed(const Duration(milliseconds: 1));

    await store.updateShortcut(
      id: firstId,
      nameInput: 'First Updated',
      urlInput: 'https://www.youtube.com/watch?v=first123',
    );

    expect(store.entries.map((ShortcutEntry entry) => entry.name), <String>[
      'Second',
      'First Updated',
    ]);
  });

  test('uses system theme by default and updates selection', () async {
    final ShortcutStore store = buildStore();

    expect(store.themePreference, AppThemePreference.system);

    await store.setThemePreference(AppThemePreference.dark);

    expect(store.themePreference, AppThemePreference.dark);
  });

  test('persists selected theme preference across reload', () async {
    final MemoryShortcutRepository repository = MemoryShortcutRepository();
    final ShortcutStore store = buildStore(repository);

    await store.setThemePreference(AppThemePreference.light);

    final ShortcutStore reloadedStore = buildStore(repository);
    await reloadedStore.load();

    expect(reloadedStore.themePreference, AppThemePreference.light);
  });
  test('reorders shortcuts and persists manual order', () async {
    final MemoryShortcutRepository repository = MemoryShortcutRepository();
    final ShortcutStore store = buildStore(repository);

    await store.addShortcut(
      nameInput: 'First',
      urlInput: 'https://youtu.be/first123',
    );
    await store.addShortcut(
      nameInput: 'Second',
      urlInput: 'https://youtu.be/second123',
    );
    await store.addShortcut(
      nameInput: 'Third',
      urlInput: 'https://youtu.be/third123',
    );

    expect(store.entries.map((ShortcutEntry entry) => entry.name), <String>[
      'Third',
      'Second',
      'First',
    ]);

    await store.reorderShortcuts(0, 3);

    expect(store.entries.map((ShortcutEntry entry) => entry.name), <String>[
      'Second',
      'First',
      'Third',
    ]);

    final ShortcutStore reloadedStore = buildStore(repository);
    await reloadedStore.load();

    expect(
      reloadedStore.entries.map((ShortcutEntry entry) => entry.name),
      <String>['Second', 'First', 'Third'],
    );
  });

  group('entriesSorted', () {
    Future<ShortcutStore> loadedStore(List<ShortcutEntry> seed) async {
      final ShortcutStore store = buildStore(MemoryShortcutRepository(seed));
      await store.load();
      return store;
    }

    test(
      'manual sort preserves stored order regardless of launch state',
      () async {
        final List<ShortcutEntry> seed = <ShortcutEntry>[
          _seedEntry(id: 'a', name: 'Alpha'),
          _seedEntry(
            id: 'b',
            name: 'Bravo',
            lastLaunched: '2026-04-20T00:00:00Z',
            launchCount: 9,
          ),
          _seedEntry(
            id: 'c',
            name: 'Charlie',
            lastLaunched: '2026-04-25T00:00:00Z',
            launchCount: 3,
          ),
        ];
        final ShortcutStore store = await loadedStore(seed);

        expect(store.sortPreference, ShortcutSortPreference.manual);
        expect(
          store.entriesSorted.map((ShortcutEntry e) => e.id).toList(),
          <String>['a', 'b', 'c'],
        );
      },
    );

    test(
      'recent sort orders by lastLaunchedAt desc; never-launched fall to bottom in manual order',
      () async {
        final List<ShortcutEntry> seed = <ShortcutEntry>[
          _seedEntry(id: 'never-1', name: 'Never One'),
          _seedEntry(
            id: 'old',
            name: 'Old launch',
            lastLaunched: '2026-04-01T00:00:00Z',
            launchCount: 1,
          ),
          _seedEntry(id: 'never-2', name: 'Never Two'),
          _seedEntry(
            id: 'newest',
            name: 'Newest launch',
            lastLaunched: '2026-04-25T00:00:00Z',
            launchCount: 1,
          ),
        ];
        final ShortcutStore store = await loadedStore(seed);
        await store.setSortPreference(ShortcutSortPreference.recent);

        expect(
          store.entriesSorted.map((ShortcutEntry e) => e.id).toList(),
          <String>['newest', 'old', 'never-1', 'never-2'],
        );
      },
    );

    test(
      'alphabetical sort orders by name case-insensitively; ties break by manual order',
      () async {
        final List<ShortcutEntry> seed = <ShortcutEntry>[
          _seedEntry(id: 'c', name: 'charlie'),
          _seedEntry(id: 'a', name: 'Alpha'),
          _seedEntry(id: 'b1', name: 'bravo'),
          _seedEntry(id: 'b2', name: 'Bravo'),
        ];
        final ShortcutStore store = await loadedStore(seed);
        await store.setSortPreference(ShortcutSortPreference.alphabetical);

        expect(
          store.entriesSorted.map((ShortcutEntry e) => e.id).toList(),
          <String>['a', 'b1', 'b2', 'c'],
        );
      },
    );

    test(
      'newest sort orders by createdAt desc; ties break by manual order',
      () async {
        final List<ShortcutEntry> seed = <ShortcutEntry>[
          _seedEntry(
            id: 'older',
            name: 'Older',
            createdAt: '2026-02-01T00:00:00Z',
          ),
          _seedEntry(
            id: 'newest',
            name: 'Newest',
            createdAt: '2026-04-20T00:00:00Z',
          ),
          _seedEntry(
            id: 'middle-a',
            name: 'Middle A',
            createdAt: '2026-03-10T00:00:00Z',
          ),
          _seedEntry(
            id: 'middle-b',
            name: 'Middle B',
            createdAt: '2026-03-10T00:00:00Z',
          ),
        ];
        final ShortcutStore store = await loadedStore(seed);
        await store.setSortPreference(ShortcutSortPreference.newest);

        expect(
          store.entriesSorted.map((ShortcutEntry e) => e.id).toList(),
          <String>['newest', 'middle-a', 'middle-b', 'older'],
        );
      },
    );

    test(
      'mostUsed sort orders by launchCount desc; ties break by recency then manual order',
      () async {
        final List<ShortcutEntry> seed = <ShortcutEntry>[
          _seedEntry(
            id: 'tie-older',
            name: 'Tie older',
            lastLaunched: '2026-04-10T00:00:00Z',
            launchCount: 5,
          ),
          _seedEntry(
            id: 'top',
            name: 'Top',
            lastLaunched: '2026-04-01T00:00:00Z',
            launchCount: 12,
          ),
          _seedEntry(
            id: 'tie-newer',
            name: 'Tie newer',
            lastLaunched: '2026-04-20T00:00:00Z',
            launchCount: 5,
          ),
          _seedEntry(
            id: 'tie-manual-first',
            name: 'Tie manual first',
            launchCount: 5,
          ),
          _seedEntry(
            id: 'tie-manual-second',
            name: 'Tie manual second',
            launchCount: 5,
          ),
          _seedEntry(id: 'never', name: 'Never'),
        ];
        final ShortcutStore store = await loadedStore(seed);
        await store.setSortPreference(ShortcutSortPreference.mostUsed);

        expect(
          store.entriesSorted.map((ShortcutEntry e) => e.id).toList(),
          <String>[
            'top',
            'tie-newer',
            'tie-older',
            'tie-manual-first',
            'tie-manual-second',
            'never',
          ],
        );
      },
    );

    test('favoritesFirst puts favorited entries before non-favorited entries', () async {
      final List<ShortcutEntry> seed = <ShortcutEntry>[
        _seedEntry(id: 'a', name: 'Alpha'),
        _seedEntry(id: 'b', name: 'Bravo', isFavorite: true),
        _seedEntry(id: 'c', name: 'Charlie'),
      ];
      final ShortcutStore store = await loadedStore(seed);
      await store.setSortPreference(ShortcutSortPreference.alphabetical);
      await store.setFavoritesFirst(true);

      expect(
        store.entriesSorted.map((ShortcutEntry e) => e.id).toList(),
        <String>['b', 'a', 'c'],
      );
    });
  });

  test('adds and updates shortcut with custom tags and favorite flag', () async {
    final ShortcutStore store = buildStore();

    await store.addShortcut(
      nameInput: 'Tech Channel',
      urlInput: 'https://youtu.be/tech123',
      tags: const <String>['#Tech', '#News'],
      isFavorite: true,
    );

    final ShortcutEntry entry = store.entries.single;
    expect(entry.tags, <String>['#Tech', '#News']);
    expect(entry.isFavorite, isTrue);

    await store.toggleFavorite(entry.id);
    expect(store.entries.single.isFavorite, isFalse);
  });

  test('adds and updates shortcut with custom color and custom icon', () async {
    final ShortcutStore store = buildStore();

    await store.addShortcut(
      nameInput: 'Customized Shortcut',
      urlInput: 'https://youtu.be/custom123',
      customColorHex: '#EA580C',
      customIconName: 'music',
    );

    final ShortcutEntry added = store.entries.single;
    expect(added.customColorHex, '#EA580C');
    expect(added.customIconName, 'music');

    await store.updateShortcut(
      id: added.id,
      nameInput: 'Customized Shortcut',
      urlInput: 'https://youtu.be/custom123',
      customColorHex: '#059669',
      customIconName: 'game',
    );

    final ShortcutEntry updated = store.entries.single;
    expect(updated.customColorHex, '#059669');
    expect(updated.customIconName, 'game');
  });

  test('persists curated theme preferences (amoled, warmSepia, forestDark, cyberpunkNeon)', () async {
    final MemoryShortcutRepository repository = MemoryShortcutRepository();
    final ShortcutStore store = buildStore(repository);

    await store.setThemePreference(AppThemePreference.amoled);
    expect(store.themePreference, AppThemePreference.amoled);

    final ShortcutStore reloaded = buildStore(repository);
    await reloaded.load();
    expect(reloaded.themePreference, AppThemePreference.amoled);

    await reloaded.setThemePreference(AppThemePreference.cyberpunkNeon);
    expect(reloaded.themePreference, AppThemePreference.cyberpunkNeon);
  });
}

ShortcutEntry _seedEntry({
  required String id,
  required String name,
  String createdAt = '2026-01-01T00:00:00Z',
  String? lastLaunched,
  int launchCount = 0,
  bool isFavorite = false,
  List<String> tags = const <String>[],
}) {
  return ShortcutEntry(
    id: id,
    name: name,
    sourceUrl: 'https://youtu.be/$id',
    canonicalUrl: 'https://www.youtube.com/watch?v=$id',
    targetType: ShortcutTargetType.video,
    createdAtIso: createdAt,
    updatedAtIso: createdAt,
    lastLaunchedAtIso: lastLaunched,
    launchCount: launchCount,
    isFavorite: isFavorite,
    tags: tags,
  );
}

class _FakeYoutubeLauncher implements YoutubeLauncher {
  @override
  Future<void> openShortcut(ShortcutEntry entry) async {}
}

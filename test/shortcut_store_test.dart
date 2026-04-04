import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/src/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_services.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_store.dart';

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
}

class _FakeYoutubeLauncher implements YoutubeLauncher {
  @override
  Future<void> openShortcut(ShortcutEntry entry) async {}
}

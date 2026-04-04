import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/src/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_services.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_store.dart';

void main() {
  ShortcutStore buildStore() {
    return ShortcutStore(
      repository: MemoryShortcutRepository(),
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

  test('moves an edited shortcut to the top based on updated time', () async {
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

    expect(store.entries.first.name, 'Second');

    await Future<void>.delayed(const Duration(milliseconds: 1));

    await store.updateShortcut(
      id: firstId,
      nameInput: 'First Updated',
      urlInput: 'https://www.youtube.com/watch?v=first123',
    );

    expect(store.entries.first.id, firstId);
    expect(store.entries.first.name, 'First Updated');
  });
}

class _FakeYoutubeLauncher implements YoutubeLauncher {
  @override
  Future<void> openShortcut(ShortcutEntry entry) async {}
}

import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/services/backup_service.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/repositories/shortcut_repository.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';
import 'package:sreerajp_youtube_shortcut/services/youtube_launcher_service.dart';
import 'package:sreerajp_youtube_shortcut/services/youtube_url_formatter.dart';

void main() {
  group('ShortcutBackupService', () {
    const ShortcutBackupService service = ShortcutBackupService();

    test('round-trips a non-empty entry list', () async {
      final ShortcutStore store = _buildStore();
      await store.addShortcut(
        nameInput: 'News',
        urlInput: 'https://youtu.be/news123',
      );
      await store.addShortcut(
        nameInput: 'Music',
        urlInput: 'https://www.youtube.com/playlist?list=PL12345',
      );

      final String encoded = service.encode(
        entries: store.entries,
        exportedAtUtc: DateTime.utc(2026, 4, 26, 12, 0),
      );
      final List<ShortcutEntry> decoded = service.decode(encoded);

      expect(decoded.map((ShortcutEntry e) => e.name), <String>[
        'Music',
        'News',
      ]);
      expect(decoded.map((ShortcutEntry e) => e.canonicalUrl), <String>[
        'https://www.youtube.com/playlist?list=PL12345',
        'https://www.youtube.com/watch?v=news123',
      ]);
    });

    test('rejects payload with mismatched type marker', () {
      const String raw =
          '{"type":"something_else","schemaVersion":1,"shortcuts":[]}';
      expect(
        () => service.decode(raw),
        throwsA(isA<ShortcutBackupException>()),
      );
    });

    test('rejects payload from a newer schema version', () {
      const String raw =
          '{"type":"sreerajp_youtube_shortcuts_backup","schemaVersion":99,"shortcuts":[]}';
      expect(
        () => service.decode(raw),
        throwsA(isA<ShortcutBackupException>()),
      );
    });

    test('rejects malformed JSON', () {
      expect(
        () => service.decode('not really json {'),
        throwsA(isA<ShortcutBackupException>()),
      );
    });

    test(
      'round-trips encrypted export and import with valid password',
      () async {
        final ShortcutStore store = _buildStore();
        await store.addShortcut(
          nameInput: 'Encrypted Video',
          urlInput: 'https://youtu.be/secret123',
          isPrivate: true,
        );

        final String encryptedRaw = service.encodeEncrypted(
          entries: store.entries,
          passphrase: 'MyVaultPassword123',
          exportedAtUtc: DateTime.utc(2026, 8, 10, 12, 0),
        );

        expect(service.isEncrypted(encryptedRaw), isTrue);
        expect(encryptedRaw, startsWith('v1:'));

        final List<ShortcutEntry> decoded = service.decodeEncrypted(
          encryptedRaw,
          'MyVaultPassword123',
        );

        expect(decoded.length, 1);
        expect(decoded.first.name, 'Encrypted Video');
        expect(decoded.first.isPrivate, isTrue);
      },
    );

    test('rejects encrypted import with wrong password', () async {
      final ShortcutStore store = _buildStore();
      await store.addShortcut(
        nameInput: 'Vault Note',
        urlInput: 'https://youtu.be/secret456',
      );

      final String encryptedRaw = service.encodeEncrypted(
        entries: store.entries,
        passphrase: 'CorrectPassword',
        exportedAtUtc: DateTime.utc(2026, 8, 10, 12, 0),
      );

      expect(
        () => service.decodeEncrypted(encryptedRaw, 'WrongPassword'),
        throwsA(isA<ShortcutBackupException>()),
      );
    });
  });

  group('ShortcutStore backup operations', () {
    test(
      'export returns cancelled when the user dismisses the picker',
      () async {
        final ShortcutStore store = _buildStore();
        await store.addShortcut(
          nameInput: 'Item',
          urlInput: 'https://youtu.be/abc123',
        );

        final BackupExportOutcome outcome = await store.exportShortcutsToFile();

        expect(outcome, isA<BackupExportCancelled>());
      },
    );

    test(
      'export returns success and forwards content through the gateway',
      () async {
        final _RecordingBackupGateway gateway = _RecordingBackupGateway();
        final ShortcutStore store = _buildStore(gateway: gateway);
        await store.addShortcut(
          nameInput: 'Item',
          urlInput: 'https://youtu.be/abc123',
        );

        gateway.exportReturn = 'yt_shortcuts_backup_2026-04-26_1200.json';

        final BackupExportOutcome outcome = await store.exportShortcutsToFile();

        expect(outcome, isA<BackupExportSuccess>());
        final BackupExportSuccess success = outcome as BackupExportSuccess;
        expect(success.exportedCount, 1);
        expect(success.destinationLabel, gateway.exportReturn);
        expect(gateway.lastExportContent, contains('"name": "Item"'));
      },
    );

    test('merge import skips entries whose name already exists', () async {
      final ShortcutStore baseStore = _buildStore();
      await baseStore.addShortcut(
        nameInput: 'News',
        urlInput: 'https://youtu.be/news123',
      );
      await baseStore.addShortcut(
        nameInput: 'Music',
        urlInput: 'https://youtu.be/music123',
      );
      final String encoded = const ShortcutBackupService().encode(
        entries: baseStore.entries,
        exportedAtUtc: DateTime.utc(2026, 4, 26),
      );

      final _RecordingBackupGateway gateway = _RecordingBackupGateway()
        ..importReturn = BackupFileReadResult(
          contents: encoded,
          displayName: 'backup.json',
        );

      final ShortcutStore target = _buildStore(gateway: gateway);
      await target.addShortcut(
        nameInput: 'Music',
        urlInput: 'https://youtu.be/existing-music',
      );

      final BackupImportOutcome outcome = await target.importShortcutsFromFile(
        mode: BackupImportMode.merge,
      );

      expect(outcome, isA<BackupImportSuccess>());
      final BackupImportSuccess success = outcome as BackupImportSuccess;
      expect(success.added, 1);
      expect(success.skipped, 1);
      expect(success.fileEntryCount, 2);
      expect(target.entries.map((ShortcutEntry e) => e.name), <String>[
        'News',
        'Music',
      ]);
    });

    test(
      'replace import wipes existing entries before loading the file',
      () async {
        final ShortcutStore baseStore = _buildStore();
        await baseStore.addShortcut(
          nameInput: 'Imported A',
          urlInput: 'https://youtu.be/aaa111',
        );
        final String encoded = const ShortcutBackupService().encode(
          entries: baseStore.entries,
          exportedAtUtc: DateTime.utc(2026, 4, 26),
        );

        final _RecordingBackupGateway gateway = _RecordingBackupGateway()
          ..importReturn = BackupFileReadResult(
            contents: encoded,
            displayName: 'backup.json',
          );

        final ShortcutStore target = _buildStore(gateway: gateway);
        await target.addShortcut(
          nameInput: 'Existing',
          urlInput: 'https://youtu.be/existing',
        );

        final BackupImportOutcome outcome = await target
            .importShortcutsFromFile(mode: BackupImportMode.replace);

        expect(outcome, isA<BackupImportSuccess>());
        expect(target.entries.map((ShortcutEntry e) => e.name), <String>[
          'Imported A',
        ]);
      },
    );

    test('import returns cancelled when the picker is dismissed', () async {
      final ShortcutStore store = _buildStore();
      final BackupImportOutcome outcome = await store.importShortcutsFromFile(
        mode: BackupImportMode.merge,
      );
      expect(outcome, isA<BackupImportCancelled>());
    });

    test('deleteShortcuts removes only the listed ids', () async {
      final ShortcutStore store = _buildStore();
      await store.addShortcut(
        nameInput: 'A',
        urlInput: 'https://youtu.be/aaa12345',
      );
      await store.addShortcut(
        nameInput: 'B',
        urlInput: 'https://youtu.be/bbb12345',
      );
      await store.addShortcut(
        nameInput: 'C',
        urlInput: 'https://youtu.be/ccc12345',
      );

      final List<String> idsToDelete = store.entries
          .where((ShortcutEntry e) => e.name == 'A' || e.name == 'C')
          .map((ShortcutEntry e) => e.id)
          .toList();

      await store.deleteShortcuts(idsToDelete);

      expect(store.entries.map((ShortcutEntry e) => e.name), <String>['B']);
    });

    test(
      'deleteShortcuts notifies listeners exactly once for a non-empty change',
      () async {
        final ShortcutStore store = _buildStore();
        await store.addShortcut(
          nameInput: 'A',
          urlInput: 'https://youtu.be/aaa12345',
        );
        await store.addShortcut(
          nameInput: 'B',
          urlInput: 'https://youtu.be/bbb12345',
        );

        int notifyCount = 0;
        store.addListener(() => notifyCount++);

        await store.deleteShortcuts(<String>[store.entries.first.id]);

        expect(notifyCount, 1);
      },
    );

    test('deleteShortcuts is a no-op when no ids match', () async {
      final ShortcutStore store = _buildStore();
      await store.addShortcut(
        nameInput: 'A',
        urlInput: 'https://youtu.be/aaa12345',
      );

      int notifyCount = 0;
      store.addListener(() => notifyCount++);

      await store.deleteShortcuts(const <String>[]);
      await store.deleteShortcuts(<String>['unknown-id']);

      expect(store.entries.length, 1);
      expect(notifyCount, 0);
    });

    test('export with entriesOverride writes only the subset', () async {
      final _RecordingBackupGateway gateway = _RecordingBackupGateway()
        ..exportReturn = 'subset.json';
      final ShortcutStore store = _buildStore(gateway: gateway);
      await store.addShortcut(
        nameInput: 'Alpha',
        urlInput: 'https://youtu.be/alpha123',
      );
      await store.addShortcut(
        nameInput: 'Beta',
        urlInput: 'https://youtu.be/beta1234',
      );

      final List<ShortcutEntry> picked = store.entries
          .where((ShortcutEntry e) => e.name == 'Alpha')
          .toList();

      final BackupExportOutcome outcome = await store.exportShortcutsToFile(
        entriesOverride: picked,
      );

      expect(outcome, isA<BackupExportSuccess>());
      expect((outcome as BackupExportSuccess).exportedCount, 1);
      expect(gateway.lastExportContent, contains('"name": "Alpha"'));
      expect(gateway.lastExportContent, isNot(contains('"name": "Beta"')));
    });
  });
}

ShortcutStore _buildStore({BackupFileGateway? gateway}) {
  return ShortcutStore(
    repository: MemoryShortcutRepository(),
    formatter: const YoutubeUrlFormatter(),
    launcher: _FakeYoutubeLauncher(),
    backupGateway: gateway ?? const NoOpBackupFileGateway(),
  );
}

class _FakeYoutubeLauncher implements YoutubeLauncher {
  @override
  Future<void> openShortcut(ShortcutEntry entry) async {}
}

class _RecordingBackupGateway implements BackupFileGateway {
  String? exportReturn;
  BackupFileReadResult? importReturn;
  String? lastExportContent;
  String? lastSuggestedFileName;

  @override
  Future<String?> writeBackupToUserChosenLocation({
    required String suggestedFileName,
    required String contents,
  }) async {
    lastSuggestedFileName = suggestedFileName;
    lastExportContent = contents;
    return exportReturn;
  }

  @override
  Future<BackupFileReadResult?> readBackupFromUserChosenLocation() async {
    return importReturn;
  }
}

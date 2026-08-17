import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:pointycastle/export.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';

enum BackupImportMode { merge, replace }

abstract class BackupFileGateway {
  /// Returns the saved file's display name when the user picked a destination,
  /// or `null` if the user cancelled the system picker.
  Future<String?> writeBackupToUserChosenLocation({
    required String suggestedFileName,
    required String contents,
  });

  /// Returns the picked file's contents and display name, or `null` if the user
  /// cancelled the system picker.
  Future<BackupFileReadResult?> readBackupFromUserChosenLocation();
}

class BackupFileReadResult {
  const BackupFileReadResult({
    required this.contents,
    required this.displayName,
  });

  final String contents;
  final String displayName;
}

class AndroidBackupFileGateway implements BackupFileGateway {
  AndroidBackupFileGateway();

  static const MethodChannel _channel = MethodChannel(
    'in.sreerajp.sreerajp_youtube_shortcut/backup_io',
  );

  @override
  Future<String?> writeBackupToUserChosenLocation({
    required String suggestedFileName,
    required String contents,
  }) async {
    try {
      final String? displayName = await _channel.invokeMethod<String>(
        'exportJson',
        <String, dynamic>{'filename': suggestedFileName, 'content': contents},
      );
      return displayName;
    } on MissingPluginException {
      throw const ShortcutBackupException(
        AppErrorCode.backupUnavailable,
        'Backup is not available on this device build.',
      );
    } on PlatformException catch (error) {
      throw ShortcutBackupException(
        AppErrorCode.backupUnavailable,
        error.message ?? 'The backup file could not be saved.',
      );
    }
  }

  @override
  Future<BackupFileReadResult?> readBackupFromUserChosenLocation() async {
    try {
      final Map<dynamic, dynamic>? raw = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('importJson');
      if (raw == null) {
        return null;
      }
      final String contents = (raw['contents'] as String?) ?? '';
      final String displayName = (raw['displayName'] as String?) ?? '';
      return BackupFileReadResult(contents: contents, displayName: displayName);
    } on MissingPluginException {
      throw const ShortcutBackupException(
        AppErrorCode.backupUnavailable,
        'Backup is not available on this device build.',
      );
    } on PlatformException catch (error) {
      throw ShortcutBackupException(
        AppErrorCode.backupUnavailable,
        error.message ?? 'The backup file could not be read.',
      );
    }
  }
}

class NoOpBackupFileGateway implements BackupFileGateway {
  const NoOpBackupFileGateway();

  @override
  Future<String?> writeBackupToUserChosenLocation({
    required String suggestedFileName,
    required String contents,
  }) async => null;

  @override
  Future<BackupFileReadResult?> readBackupFromUserChosenLocation() async =>
      null;
}

class ShortcutBackupService {
  const ShortcutBackupService();

  static const int _currentSchemaVersion = 1;
  static const String _appIdentifier = 'in.sreerajp.sreerajp_youtube_shortcut';
  static const String _payloadType = 'sreerajp_youtube_shortcuts_backup';

  String encode({
    required List<ShortcutEntry> entries,
    required DateTime exportedAtUtc,
  }) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'type': _payloadType,
      'schemaVersion': _currentSchemaVersion,
      'appId': _appIdentifier,
      'exportedAtIso': exportedAtUtc.toUtc().toIso8601String(),
      'shortcutCount': entries.length,
      'shortcuts': entries
          .map((ShortcutEntry entry) => entry.toJson())
          .toList(growable: false),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  List<ShortcutEntry> decode(String raw) {
    if (raw.trim().isEmpty) {
      throw const ShortcutBackupException(
        AppErrorCode.fileEmpty,
        'The selected file is empty.',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      throw const ShortcutBackupException(
        AppErrorCode.fileNotJson,
        'The selected file is not valid JSON.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const ShortcutBackupException(
        AppErrorCode.fileNotOurBackup,
        'The selected file is not a SreerajP YouTube Shortcuts backup.',
      );
    }

    if (decoded['type'] != _payloadType) {
      throw const ShortcutBackupException(
        AppErrorCode.fileNotOurBackup,
        'The selected file is not a SreerajP YouTube Shortcuts backup.',
      );
    }

    final dynamic schemaRaw = decoded['schemaVersion'];
    final int? schemaVersion = schemaRaw is int
        ? schemaRaw
        : (schemaRaw is num ? schemaRaw.toInt() : null);
    if (schemaVersion == null || schemaVersion < 1) {
      throw const ShortcutBackupException(
        AppErrorCode.schemaVersionMissing,
        'This backup file is missing a schema version.',
      );
    }
    if (schemaVersion > _currentSchemaVersion) {
      throw const ShortcutBackupException(
        AppErrorCode.schemaVersionTooNew,
        'This backup was created by a newer app version. Update the app and try again.',
      );
    }

    final dynamic listRaw = decoded['shortcuts'];
    if (listRaw is! List) {
      throw const ShortcutBackupException(
        AppErrorCode.shortcutListMissing,
        'The backup file is missing the shortcut list.',
      );
    }

    final List<ShortcutEntry> parsed = <ShortcutEntry>[];
    for (final dynamic item in listRaw) {
      if (item is! Map<String, dynamic>) {
        throw const ShortcutBackupException(
          AppErrorCode.entryMalformed,
          'A shortcut entry inside the backup is malformed.',
        );
      }
      try {
        parsed.add(ShortcutEntry.fromJson(item));
      } catch (_) {
        throw const ShortcutBackupException(
          AppErrorCode.entryMalformed,
          'A shortcut entry inside the backup is malformed.',
        );
      }
    }

    return List<ShortcutEntry>.unmodifiable(parsed);
  }

  static const int _pbkdf2Iterations = 10000;
  static const int _pbkdf2KeySize = 32;

  Uint8List _deriveKey(String passphrase, Uint8List salt) {
    final PBKDF2KeyDerivator pbkdf2 = PBKDF2KeyDerivator(
      HMac(SHA256Digest(), 64),
    )..init(Pbkdf2Parameters(salt, _pbkdf2Iterations, _pbkdf2KeySize));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(passphrase)));
  }

  bool isEncrypted(String raw) {
    final String trimmed = raw.trim();
    return trimmed.startsWith('v1:');
  }

  String encodeEncrypted({
    required List<ShortcutEntry> entries,
    required String passphrase,
    required DateTime exportedAtUtc,
  }) {
    final String plainJson = encode(
      entries: entries,
      exportedAtUtc: exportedAtUtc,
    );

    final Random random = Random.secure();
    final Uint8List salt = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      salt[i] = random.nextInt(256);
    }
    final Uint8List keyBytes = _deriveKey(passphrase, salt);
    final encrypt.Key key = encrypt.Key(keyBytes);
    final encrypt.IV iv = encrypt.IV.fromSecureRandom(12);

    final encrypt.Encrypter encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    final encrypt.Encrypted encrypted = encrypter.encrypt(plainJson, iv: iv);

    final String saltB64 = base64Encode(salt);
    final String ivB64 = iv.base64;
    final String ciphertextB64 = encrypted.base64;

    return 'v1:$saltB64:$ivB64:$ciphertextB64';
  }

  List<ShortcutEntry> decodeEncrypted(String raw, String passphrase) {
    final String trimmed = raw.trim();
    if (!trimmed.startsWith('v1:')) {
      return decode(raw);
    }

    final List<String> parts = trimmed.substring(3).split(':');
    if (parts.length != 3) {
      throw const ShortcutBackupException(
        AppErrorCode.encryptedFormatInvalid,
        'The encrypted backup file format is invalid.',
      );
    }

    try {
      final Uint8List salt = base64Decode(parts[0]);
      final encrypt.IV iv = encrypt.IV.fromBase64(parts[1]);
      final encrypt.Encrypted encrypted = encrypt.Encrypted.fromBase64(
        parts[2],
      );

      final Uint8List keyBytes = _deriveKey(passphrase, salt);
      final encrypt.Key key = encrypt.Key(keyBytes);
      final encrypt.Encrypter encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      final String plainJson = encrypter.decrypt(encrypted, iv: iv);
      return decode(plainJson);
    } catch (e) {
      if (e is ShortcutBackupException) rethrow;
      throw const ShortcutBackupException(
        AppErrorCode.decryptFailed,
        'Invalid password or corrupted backup file.',
      );
    }
  }

  String suggestedFileName(DateTime nowUtc, {bool isEncrypted = false}) {
    final DateTime utc = nowUtc.toUtc();
    final String year = utc.year.toString().padLeft(4, '0');
    final String month = utc.month.toString().padLeft(2, '0');
    final String day = utc.day.toString().padLeft(2, '0');
    final String hour = utc.hour.toString().padLeft(2, '0');
    final String minute = utc.minute.toString().padLeft(2, '0');
    final String ext = isEncrypted ? 'aes.json' : 'json';
    return 'yt_shortcuts_backup_$year-$month-${day}_$hour$minute.$ext';
  }
}

sealed class BackupExportOutcome {
  const BackupExportOutcome();
}

class BackupExportSuccess extends BackupExportOutcome {
  const BackupExportSuccess({
    required this.exportedCount,
    required this.destinationLabel,
  });

  final int exportedCount;
  final String destinationLabel;
}

class BackupExportCancelled extends BackupExportOutcome {
  const BackupExportCancelled();
}

sealed class BackupImportOutcome {
  const BackupImportOutcome();
}

class BackupImportSuccess extends BackupImportOutcome {
  const BackupImportSuccess({
    required this.mode,
    required this.fileEntryCount,
    required this.added,
    required this.skipped,
    required this.totalAfter,
  });

  final BackupImportMode mode;
  final int fileEntryCount;
  final int added;
  final int skipped;
  final int totalAfter;
}

class BackupImportCancelled extends BackupImportOutcome {
  const BackupImportCancelled();
}

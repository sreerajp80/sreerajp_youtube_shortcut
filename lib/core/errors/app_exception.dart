/// Stable identifiers for every error the app can surface to the user.
///
/// The UI maps a code to localized text (see `lib/l10n/error_messages.dart`).
/// Codes never change once shipped — the wording behind them may.
enum AppErrorCode {
  // Validation — shortcut name and URL input.
  nameEmpty,
  urlEmpty,
  handleInvalid,
  handleOrUrlInvalid,
  shortLinkMissingVideoId,
  notYoutubeLink,
  watchMissingVideoId,
  liveMissingVideoId,
  shortsMissingId,
  playlistMissingListId,
  channelMissingIdentifier,
  unsupportedLinkFormat,
  duplicateName,

  // Storage — local persistence.
  shortcutMissing,
  readFailed,
  writeRejected,
  writeFailed,
  themeSaveFailed,
  layoutSaveFailed,
  sortSaveFailed,
  favoritesFirstSaveFailed,

  // Backup — export and import.
  backupUnavailable,
  fileEmpty,
  fileNotJson,
  fileNotOurBackup,
  schemaVersionMissing,
  schemaVersionTooNew,
  shortcutListMissing,
  entryMalformed,
  encryptedFormatInvalid,
  decryptFailed,

  // Launching the YouTube app.
  youtubeAppUnavailable,
}

/// Base type for every error this app raises on purpose.
///
/// [message] is developer-facing and is safe to log. It must never be shown to
/// the user directly — screens resolve [code] through `AppLocalizations`.
sealed class AppException implements Exception {
  const AppException(this.code, this.message);

  final AppErrorCode code;
  final String message;

  @override
  String toString() => '$runtimeType(${code.name}): $message';
}

/// The user typed something the app cannot turn into a shortcut.
final class ShortcutValidationException extends AppException {
  const ShortcutValidationException(super.code, super.message);
}

/// Reading from or writing to local storage failed.
final class ShortcutStorageException extends AppException {
  const ShortcutStorageException(super.code, super.message);
}

/// Exporting or importing a backup file failed.
final class ShortcutBackupException extends AppException {
  const ShortcutBackupException(super.code, super.message);
}

/// The YouTube app could not be handed the link.
final class YoutubeLaunchException extends AppException {
  const YoutubeLaunchException(super.code, super.message);
}

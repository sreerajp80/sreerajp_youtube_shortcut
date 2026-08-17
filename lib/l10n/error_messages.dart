import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';

/// Turns a thrown [AppException] into text the user can read.
///
/// Screens must show this, never `exception.message` — that field is the
/// developer-facing string kept for logs.
extension AppExceptionLocalization on AppException {
  String localized(AppLocalizations l10n) {
    switch (code) {
      case AppErrorCode.backupUnavailable:
        return l10n.errBackupUnavailable;
      case AppErrorCode.fileEmpty:
        return l10n.errFileEmpty;
      case AppErrorCode.fileNotJson:
        return l10n.errFileNotJson;
      case AppErrorCode.fileNotOurBackup:
        return l10n.errFileNotOurBackup;
      case AppErrorCode.schemaVersionMissing:
        return l10n.errSchemaVersionMissing;
      case AppErrorCode.schemaVersionTooNew:
        return l10n.errSchemaVersionTooNew;
      case AppErrorCode.shortcutListMissing:
        return l10n.errShortcutListMissing;
      case AppErrorCode.entryMalformed:
        return l10n.errEntryMalformed;
      case AppErrorCode.encryptedFormatInvalid:
        return l10n.errEncryptedFormatInvalid;
      case AppErrorCode.decryptFailed:
        return l10n.errDecryptFailed;
      case AppErrorCode.nameEmpty:
        return l10n.errNameEmpty;
      case AppErrorCode.urlEmpty:
        return l10n.errUrlEmpty;
      case AppErrorCode.handleInvalid:
        return l10n.errHandleInvalid;
      case AppErrorCode.handleOrUrlInvalid:
        return l10n.errHandleOrUrlInvalid;
      case AppErrorCode.shortLinkMissingVideoId:
        return l10n.errShortLinkMissingVideoId;
      case AppErrorCode.notYoutubeLink:
        return l10n.errNotYoutubeLink;
      case AppErrorCode.watchMissingVideoId:
        return l10n.errWatchMissingVideoId;
      case AppErrorCode.liveMissingVideoId:
        return l10n.errLiveMissingVideoId;
      case AppErrorCode.shortsMissingId:
        return l10n.errShortsMissingId;
      case AppErrorCode.playlistMissingListId:
        return l10n.errPlaylistMissingListId;
      case AppErrorCode.channelMissingIdentifier:
        return l10n.errChannelMissingIdentifier;
      case AppErrorCode.unsupportedLinkFormat:
        return l10n.errUnsupportedLinkFormat;
      case AppErrorCode.youtubeAppUnavailable:
        return l10n.errYoutubeAppUnavailable;
      case AppErrorCode.shortcutMissing:
        return l10n.errShortcutMissing;
      case AppErrorCode.duplicateName:
        return l10n.errDuplicateName;
      case AppErrorCode.readFailed:
        return l10n.errReadFailed;
      case AppErrorCode.writeRejected:
        return l10n.errWriteRejected;
      case AppErrorCode.writeFailed:
        return l10n.errWriteFailed;
      case AppErrorCode.themeSaveFailed:
        return l10n.errThemeSaveFailed;
      case AppErrorCode.layoutSaveFailed:
        return l10n.errLayoutSaveFailed;
      case AppErrorCode.sortSaveFailed:
        return l10n.errSortSaveFailed;
      case AppErrorCode.favoritesFirstSaveFailed:
        return l10n.errFavoritesFirstSaveFailed;
    }
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SreerajP YouTube Shortcuts';

  @override
  String get aboutScreenTitle => 'About';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutNotesTitle => 'Notes';

  @override
  String get aboutNotesBody =>
      'The app stays offline, stores shortcuts locally, and launches canonical YouTube links with an explicit Android intent.';

  @override
  String get fatalErrorTitle => 'Startup issue';

  @override
  String get fatalErrorBootstrapDetails =>
      'The app could not finish startup. Check local storage and package metadata.';

  @override
  String get privacyLockAppLockedTitle => 'SreerajP YouTube Shortcuts Locked';

  @override
  String get permissionsScreenTitle => 'Permissions';

  @override
  String get permissionsIntroTitle => 'Permission prompts on Android';

  @override
  String get permissionsIntroBody =>
      'Camera permission is used exclusively for the optional in-app QR scanner. The app never requests internet access or background tracking permissions.';

  @override
  String get permissionsExplicitSection => 'Explicit Permissions';

  @override
  String get permissionsImplicitSection =>
      'Implicit Permissions / Declarations';

  @override
  String get permissionCameraTitle => 'Camera (android.permission.CAMERA)';

  @override
  String get permissionCameraScope => 'Offline In-App QR Scanner';

  @override
  String get permissionCameraDetails =>
      'Requested only when launching the in-app offline camera QR scanner to scan YouTube QR codes. Camera frames are processed strictly on-device using local vision ML kit, with zero network connections or telemetry.';

  @override
  String get permissionLauncherTitle => 'Launcher visibility';

  @override
  String get permissionLauncherScope =>
      'MainActivity exported with MAIN/LAUNCHER intent filter';

  @override
  String get permissionLauncherDetails =>
      'Lets Android show and start the app from the launcher. This does not request user permission.';

  @override
  String get permissionQueriesTitle => 'Package visibility query';

  @override
  String get permissionQueriesScope =>
      '<queries> for PROCESS_TEXT (text/plain)';

  @override
  String get permissionQueriesDetails =>
      'Declares app-lookup capability for matching text processors. This is a manifest declaration, not a runtime permission.';

  @override
  String get permissionShareTargetTitle => 'Share-target intent filter';

  @override
  String get permissionShareTargetScope =>
      'MainActivity ACTION_SEND with text/plain';

  @override
  String get permissionShareTargetDetails =>
      'Lets the app appear in the Android share sheet so a YouTube link shared from another app can pre-fill the Add Shortcut form. Only the shared text is read; no internet, storage, or runtime permission is requested.';

  @override
  String get permissionClipboardTitle =>
      'Clipboard read on Add Shortcut screen';

  @override
  String get permissionClipboardScope =>
      'Clipboard.getData(text/plain) when opening the Add Shortcut form';

  @override
  String get permissionClipboardDetails =>
      'When the Add Shortcut screen opens for a new shortcut, the app reads the system clipboard once to offer a one-tap paste if it contains a YouTube link. The suggestion is dismissable and never sent off-device. No manifest permission is required, but Android 12 and newer show a brief system message when an app reads the clipboard.';

  @override
  String get permissionBackupTitle => 'Backup & Restore via system file picker';

  @override
  String get permissionBackupScope =>
      'ACTION_CREATE_DOCUMENT and ACTION_OPEN_DOCUMENT (Storage Access Framework)';

  @override
  String get permissionBackupDetails =>
      'When you export or import a shortcut backup from Settings, the app launches the Android system file picker. You pick the destination or source file yourself, and Android grants the app one-time access to that single file. No storage permission is requested in the manifest, the app cannot browse other files, and no data leaves the device.';

  @override
  String get privacyLockSubtitle =>
      'Enter your PIN or use biometrics to continue';

  @override
  String get privacyLockIncorrectPin => 'Incorrect PIN. Try again.';

  @override
  String get privacyLockBiometricTooltip => 'Biometric Unlock';

  @override
  String get privacyLockClearTooltip => 'Clear';

  @override
  String get privacyLockBackspaceTooltip => 'Backspace';

  @override
  String get layoutGrid => 'Grid';

  @override
  String get layoutList => 'List';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Classic Dark';

  @override
  String get themeAmoled => 'AMOLED Pure Black';

  @override
  String get themeWarmSepia => 'Warm Sepia';

  @override
  String get themeForestDark => 'Forest Dark';

  @override
  String get themeCyberpunkNeon => 'Cyberpunk Neon';

  @override
  String get sortManual => 'Manual order';

  @override
  String get sortAlphabetical => 'Alphabetical (A–Z)';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortRecent => 'Recently launched';

  @override
  String get sortMostUsed => 'Most launched';

  @override
  String get targetTypeVideo => 'Video';

  @override
  String get targetTypeShorts => 'Shorts';

  @override
  String get targetTypePlaylist => 'Playlist';

  @override
  String get targetTypeChannel => 'Channel';

  @override
  String get behaviorScreenTitle => 'Channel handles';

  @override
  String get behaviorHowItWorksTitle => 'How \'@\' shortcuts work';

  @override
  String get behaviorHowItWorksBody =>
      'When you save a shortcut using a bare channel handle (for example \"@JanamTVMedia\" or \"JanamTVMedia\"), the app rewrites it to the YouTube live URL:';

  @override
  String get behaviorLiveUrlPattern => 'https://www.youtube.com/@<handle>/live';

  @override
  String get behaviorRoutingBody =>
      'YouTube uses this URL convention to route viewers to a channel\'s currently-live stream. Tapping the shortcut sends this URL to the YouTube app, which then decides what to show.';

  @override
  String get behaviorNotLiveSection => 'If the channel isn\'t live';

  @override
  String get behaviorNotLiveIntro =>
      'This app stays offline and cannot check live status in advance — it just hands the URL to YouTube. What you see depends on YouTube\'s handling for that channel:';

  @override
  String get behaviorCaseStreamingState => 'Currently streaming';

  @override
  String get behaviorCaseStreamingResult =>
      'Opens the live watch page (the intended outcome).';

  @override
  String get behaviorCaseUpcomingState => 'Has an upcoming or scheduled stream';

  @override
  String get behaviorCaseUpcomingResult =>
      'Opens the upcoming stream page with the countdown and waiting room.';

  @override
  String get behaviorCasePastState => 'Has past live streams only';

  @override
  String get behaviorCasePastResult =>
      'Often opens the most recent finished live stream as a video, or the channel\'s Live tab.';

  @override
  String get behaviorCaseNeverState => 'Has never gone live';

  @override
  String get behaviorCaseNeverResult =>
      'Falls back to the channel\'s home page.';

  @override
  String get behaviorCaseInvalidState => 'Handle is invalid or misspelled';

  @override
  String get behaviorCaseInvalidResult =>
      'YouTube shows its \'page not available\' state inside the app.';

  @override
  String get behaviorCasesFootnote =>
      'YouTube can change these behaviours at any time; the app has no control over what loads after the URL is opened.';

  @override
  String get behaviorGoodToKnowSection => 'Good to know';

  @override
  String get behaviorNoConnectivityTitle => 'No connectivity check';

  @override
  String get behaviorNoConnectivityBody =>
      'This app is fully offline and never reaches the internet. It cannot verify in advance whether a handle exists or is live. Handles are validated only for shape (3-30 letters, digits, dot, dash, or underscore).';

  @override
  String get behaviorChannelPageTitle =>
      'To open the channel page instead of live';

  @override
  String get behaviorChannelPageBody =>
      'Bare handles always route to /live. To pin a shortcut that opens the channel home page, save the full URL — for example: https://www.youtube.com/@JanamTVMedia';

  @override
  String get qrDialogCloseTooltip => 'Close dialog';

  @override
  String get qrDialogTitle => 'Air-Gapped QR Code';

  @override
  String get qrDialogSubtitle =>
      'Scan this code with another device to open or save this shortcut.';

  @override
  String get qrDialogCopyUrl => 'Copy URL';

  @override
  String get qrDialogUrlCopied => 'URL copied to clipboard';

  @override
  String get commonDone => 'Done';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsIntro =>
      'Manage app appearance, information, and Android manifest permissions.';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsThemeSelection => 'Theme Selection';

  @override
  String get settingsAboutTitle => 'About';

  @override
  String get settingsAboutSubtitle =>
      'App details, version, build metadata, and notes.';

  @override
  String get settingsPermissionsTitle => 'Permissions';

  @override
  String get settingsPermissionsSubtitle =>
      'Explicit and implicit permission-related manifest declarations.';

  @override
  String get settingsHandlesTitle => 'Channel handles';

  @override
  String get settingsHandlesSubtitle =>
      'How \'@\' shortcuts route to live streams.';

  @override
  String get settingsBackupTitle => 'Backup & Restore';

  @override
  String get settingsBackupSubtitle =>
      'Export shortcuts to a JSON file you control, or import a previous backup.';

  @override
  String get settingsPrivacySection => 'Privacy & Security';

  @override
  String get themeDescSystem => 'Follow your phone system settings.';

  @override
  String get themeDescLight =>
      'Clean bright background with warm crimson accents.';

  @override
  String get themeDescDark =>
      'Classic dark mode with slate background and teal highlights.';

  @override
  String get themeDescAmoled =>
      'Pure pitch black (#000000) for OLED displays and maximum power savings.';

  @override
  String get themeDescWarmSepia =>
      'Cozy parchment cream tones with rich terracotta primary.';

  @override
  String get themeDescForestDark =>
      'Deep pine background with vibrant emerald and mint accents.';

  @override
  String get themeDescCyberpunkNeon =>
      'Futuristic dark synth palette with glowing cyan and neon magenta.';

  @override
  String get pinChangeTitle => 'Change Security PIN';

  @override
  String get pinSetTitle => 'Set Security PIN';

  @override
  String get pinConfiguredSubtitle => '4–6 digit PIN configured';

  @override
  String get pinNotConfiguredSubtitle =>
      'Set a PIN to enable app and private shortcut lock';

  @override
  String get pinChangeAction => 'Change';

  @override
  String get pinSetAction => 'Set PIN';

  @override
  String get pinEnterLabel => 'Enter 4–6 digit PIN';

  @override
  String get pinConfirmLabel => 'Confirm PIN';

  @override
  String get pinMismatchError =>
      'PINs do not match or are too short (min 4 digits).';

  @override
  String get pinSavedMessage => 'Security PIN saved.';

  @override
  String get pinSaveFailedMessage => 'Failed to set PIN.';

  @override
  String get appLockTitle => 'App Lock';

  @override
  String get appLockSubtitle =>
      'Require PIN or biometrics when launching the app';

  @override
  String get privateLockTitle => 'Lock Private Shortcuts';

  @override
  String get privateLockSubtitle =>
      'Gate access to shortcuts marked as private';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get backupScreenTitle => 'Backup & Restore';

  @override
  String get backupIntroTitle => 'Move shortcuts between devices';

  @override
  String get backupIntroBody =>
      'Export your saved shortcuts to a JSON file or scan an offline QR code bundle. Everything stays on-device — no cloud or servers required.';

  @override
  String get backupExportSection => 'Export';

  @override
  String get backupNothingToExport =>
      'No shortcuts to export yet. Add at least one shortcut from the home screen, then return here.';

  @override
  String backupExportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Save all $count shortcuts to a JSON file or generate an offline Backup QR Code.',
      one:
          'Save your 1 shortcut to a JSON file or generate an offline Backup QR Code.',
    );
    return '$_temp0';
  }

  @override
  String get backupExporting => 'Exporting…';

  @override
  String get backupExportToFile => 'Export to file';

  @override
  String get backupExportViaQr => 'Export via QR code';

  @override
  String get backupImportSection => 'Import';

  @override
  String get backupImportIntro =>
      'Pick a backup file or scan a Backup QR code from another device to restore shortcuts and app settings.';

  @override
  String get backupImportMerge => 'Import & merge';

  @override
  String get backupImportReplace => 'Import & replace';

  @override
  String get backupScanQr => 'Scan Backup QR';

  @override
  String get backupReplaceWarning =>
      'Replace removes every saved shortcut on this device first, then loads the backup. There is no undo.';

  @override
  String get backupContentsSection => 'What is in the file';

  @override
  String get backupContentsShortcuts =>
      'Each saved shortcut: name, the URL you entered, the canonical YouTube URL the app launches, the target type, and the created/updated timestamps.';

  @override
  String get backupContentsSchema =>
      'A schema version and an export timestamp so future app versions can read the file safely.';

  @override
  String get backupContentsExcluded =>
      'No theme or layout preferences, no analytics, and nothing about your device — only the shortcut entries you created.';

  @override
  String get backupExportDialogTitle => 'Export Backup';

  @override
  String get backupEncryptOption => 'Encrypt backup with password';

  @override
  String get backupEncryptSubtitle => 'Uses AES-256 encryption with PBKDF2';

  @override
  String get backupPasswordEnterLabel => 'Enter Backup Password';

  @override
  String get backupPasswordHint => 'Minimum 4 characters';

  @override
  String get backupPasswordRequired => 'Please enter a password.';

  @override
  String get backupExportAction => 'Export';

  @override
  String backupExportedMessage(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count shortcuts to \"$destination\".',
      one: 'Exported 1 shortcut to \"$destination\".',
    );
    return '$_temp0';
  }

  @override
  String get backupExportCancelled => 'Export cancelled.';

  @override
  String get backupEncryptedDetectedTitle => 'Encrypted Backup Detected';

  @override
  String get backupEncryptedDetectedBody =>
      'This backup file is encrypted. Enter the password used during export to decrypt it.';

  @override
  String get backupPasswordLabel => 'Backup Password';

  @override
  String get backupDecryptImportAction => 'Decrypt & Import';

  @override
  String get backupImportCancelled => 'Import cancelled.';

  @override
  String get backupReplaceConfirmTitle => 'Replace all shortcuts?';

  @override
  String get backupReplaceConfirmBody =>
      'Importing in replace mode removes every shortcut currently saved on this device, then loads the picked backup file. This cannot be undone. Continue?';

  @override
  String get backupReplaceAction => 'Replace';

  @override
  String get backupMergeNoneAdded =>
      'No new shortcuts added — the file matched names already saved.';

  @override
  String backupMergeAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count shortcuts.',
      one: 'Imported 1 shortcut.',
    );
    return '$_temp0';
  }

  @override
  String backupMergeAddedSkipped(int added, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'Imported $added new shortcuts',
      one: 'Imported 1 new shortcut',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: 'skipped $skipped duplicate names.',
      one: 'skipped 1 duplicate name.',
    );
    return '$_temp0; $_temp1';
  }

  @override
  String backupReplaceResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Replaced local list with $count shortcuts from the file.',
      one: 'Replaced local list with 1 shortcut from the file.',
    );
    return '$_temp0';
  }

  @override
  String get bulkQrTitle => 'Backup QR Transfer';

  @override
  String bulkQrSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shortcuts & app settings',
      one: '1 shortcut & app settings',
    );
    return '$_temp0';
  }

  @override
  String get bulkQrInstantTime => '< 1 sec (Instant)';

  @override
  String bulkQrSecondsTime(String seconds) {
    return '~$seconds seconds';
  }

  @override
  String bulkQrEstimatedTime(String estimate) {
    return 'Estimated Transfer Time: $estimate';
  }

  @override
  String bulkQrLargeWarning(int frames) {
    return 'Large Backup Bundle ($frames frames). For faster transfer of large data, use JSON File Export/Import instead.';
  }

  @override
  String bulkQrFrameCounter(int current, int total) {
    return 'Animated Frame $current / $total';
  }

  @override
  String get bulkQrPauseTooltip => 'Pause stream';

  @override
  String get bulkQrPlayTooltip => 'Play stream';

  @override
  String get bulkQrAnimatedHint =>
      'Hold the receiver device camera steady in front of this screen until all frame chunks are scanned.';

  @override
  String get bulkQrSingleHint =>
      'Scan this QR code with SreerajP YouTube Shortcuts on another device to restore all shortcuts and app settings.';

  @override
  String get detailScreenTitle => 'Shortcut details';

  @override
  String get detailShowQrTooltip => 'Show QR Code';

  @override
  String get detailUnpinFavorite => 'Unpin favorite';

  @override
  String get detailPinFavorite => 'Pin favorite';

  @override
  String get detailEditTooltip => 'Edit shortcut';

  @override
  String get detailDeleteTooltip => 'Delete shortcut';

  @override
  String get detailOpening => 'Opening...';

  @override
  String get detailOpenInYoutube => 'Open in YouTube';

  @override
  String get detailQrCode => 'QR Code';

  @override
  String get detailCopyUrl => 'Copy URL';

  @override
  String get detailEdit => 'Edit';

  @override
  String get detailDestinationSection => 'Destination';

  @override
  String get detailFullUrlLabel => 'Full URL';

  @override
  String get detailOriginalInputLabel => 'Original input';

  @override
  String get detailOriginalInputCopied => 'Original input copied to clipboard.';

  @override
  String get detailUrlCopied => 'URL copied to clipboard.';

  @override
  String get detailCopyTooltip => 'Copy';

  @override
  String get detailActivitySection => 'Activity';

  @override
  String get detailLastLaunched => 'Last launched';

  @override
  String get detailNeverLaunched => 'Never launched';

  @override
  String get detailLaunchCount => 'Launch count';

  @override
  String detailLaunchCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count launches',
      one: '1 launch',
    );
    return '$_temp0';
  }

  @override
  String get detailCreated => 'Created';

  @override
  String get detailUpdated => 'Updated';

  @override
  String get detailSameAsCreated => 'Same as created';

  @override
  String get detailActivityFootnote =>
      'Activity is tracked locally on this device only.';

  @override
  String get detailDeleteConfirmTitle => 'Delete shortcut?';

  @override
  String detailDeleteConfirmBody(String name) {
    return 'Remove \"$name\" from the local shortcut list?';
  }

  @override
  String detailRemovedMessage(String name) {
    return 'Removed \"$name\".';
  }

  @override
  String get commonDelete => 'Delete';

  @override
  String get addEditTitle => 'Edit shortcut';

  @override
  String get addNewTitle => 'Add shortcut';

  @override
  String get addEditHeroTitle => 'Update this shortcut';

  @override
  String get addNewHeroTitle => 'Create a quick-launch card';

  @override
  String get addEditHeroBody =>
      'Change the shortcut name, handle, tags, or favorite status.';

  @override
  String get addNewHeroBody =>
      'Enter a channel handle or paste a YouTube URL. Add custom tags to categorize and mark as favorite to pin to top.';

  @override
  String get addSaveChanges => 'Save changes';

  @override
  String get addSaveShortcut => 'Save shortcut';

  @override
  String get addUpdating => 'Updating...';

  @override
  String get addSaving => 'Saving...';

  @override
  String get addNameLabel => 'Shortcut name';

  @override
  String get addNameHint => 'Example: Morning Mix';

  @override
  String get addUrlLabel => 'Channel handle or YouTube URL';

  @override
  String get addUrlHint =>
      '@MyChannel or https://www.youtube.com/@MyChannel/live';

  @override
  String get addScanQrTooltip => 'Scan QR Code';

  @override
  String addFullUrlPreview(String url) {
    return 'Full URL: $url';
  }

  @override
  String get addFavoriteTitle => 'Pin as Favorite';

  @override
  String get addFavoriteSubtitle =>
      'Keep this shortcut pinned to the top of your list';

  @override
  String get addPrivateTitle => 'Private Shortcut';

  @override
  String get addPrivateSubtitle => 'Hide when private vault is locked';

  @override
  String get addAccentColorSection => 'Custom Card Accent Color';

  @override
  String get addColorDefault => 'Default';

  @override
  String get addIconSection => 'Custom Card Icon';

  @override
  String get addIconDefault => 'Default Initials';

  @override
  String get addTagsSection => 'Custom Tags';

  @override
  String get addTagLabel => 'Add tag';

  @override
  String get addTagHint => 'e.g. #Tech or Personal';

  @override
  String get addSuggestedTags => 'Suggested Tags';

  @override
  String get addOfflineFootnote =>
      'The app stores the shortcut locally and does not request internet access.';

  @override
  String get addShortcutUpdated => 'Shortcut updated.';

  @override
  String get addShortcutSaved => 'Shortcut saved.';

  @override
  String get addPasteSuggestionTitle => 'Paste this link?';

  @override
  String get addPasteDismiss => 'Dismiss';

  @override
  String get addPasteAction => 'Paste';

  @override
  String get colorCrimson => 'Crimson';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorEmerald => 'Emerald';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorSlate => 'Slate';

  @override
  String get scannerScreenTitle => 'Offline QR Scanner';

  @override
  String get scannerTorchTooltip => 'Toggle Flash';

  @override
  String get scannerSwitchCameraTooltip => 'Switch Camera';

  @override
  String get scannerGalleryTooltip => 'Pick from Gallery';

  @override
  String get scannerAlignHint => 'Align QR code within frame';

  @override
  String get scannerGalleryButton => 'Scan Image from Gallery';

  @override
  String get scannerCameraUnavailableTitle => 'Camera Access Unavailable';

  @override
  String get scannerCameraUnavailableBody =>
      'Ensure camera permission is enabled in Android settings, or select a QR code image from gallery.';

  @override
  String get scannerSelectImageButton => 'Select Image from Gallery';

  @override
  String get scannerUnreadableCode => 'Scanned QR code is empty or unreadable.';

  @override
  String get scannerNotYoutubeLink =>
      'Scanned QR code is not a valid YouTube link.';

  @override
  String get scannerNoCodeInImage =>
      'No readable QR code found in selected image.';

  @override
  String get scannerNoYoutubeCodeInImage =>
      'No readable YouTube QR code found in image.';

  @override
  String get scannerImageReadFailed => 'Failed to read image from gallery.';

  @override
  String get scannerAssembleFailed =>
      'Failed to assemble full backup payload from QR frames.';

  @override
  String scannerFrameProgress(int current, int total, int collected) {
    return 'Scanning Animated QR: Frame $current/$total ($collected/$total frames)';
  }

  @override
  String get scannerLaunchFailed => 'Failed to open YouTube app.';

  @override
  String get scannerBackupReceivedTitle => 'Full Backup Received!';

  @override
  String scannerBackupSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shortcuts & app settings',
      one: '1 shortcut & app settings',
    );
    return '$_temp0';
  }

  @override
  String get scannerBackupPrompt =>
      'Choose how to apply this backup payload to your local SreerajP YouTube Shortcuts repository:';

  @override
  String get scannerMergeButton => 'Merge with Existing Shortcuts';

  @override
  String get scannerReplaceButton => 'Replace All Shortcuts';

  @override
  String scannerMergedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count shortcuts and applied settings.',
      one: 'Imported 1 shortcut and applied settings.',
    );
    return '$_temp0';
  }

  @override
  String scannerReplacedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Replaced repository with $count shortcuts and applied settings.',
      one: 'Replaced repository with 1 shortcut and applied settings.',
    );
    return '$_temp0';
  }

  @override
  String get scannerShortcutReceivedTitle => 'Shortcut Received!';

  @override
  String get scannerStructuredPayload => 'Air-Gapped Shortcut Payload';

  @override
  String get scannerPlainLinkPayload => 'Scanned YouTube QR Link';

  @override
  String get scannerDefaultShortcutName => 'Scanned YouTube Link';

  @override
  String get scannerSaveButton => 'Save to SreerajP YouTube Shortcuts';

  @override
  String get scannerOpenButton => 'Open in YouTube';

  @override
  String get scannerScanAnotherButton => 'Scan Another Code';

  @override
  String get homeExitReorderTooltip => 'Exit reorder mode';

  @override
  String get homeReorderTitle => 'Reorder shortcuts';

  @override
  String get homeReorderDisabled => 'Reorder shortcuts (manual sort only)';

  @override
  String get homeSubtitleEmpty =>
      'Save the links you open often. Each shortcut stays local on this device.';

  @override
  String get homeSubtitleReorder =>
      'Long-press and drag cards to reorder them. Tap Done when finished.';

  @override
  String get homeSubtitleSelection =>
      'Tap to toggle selection. Press back to exit.';

  @override
  String get homeSubtitleNormal =>
      'Tap a shortcut to open it. Long-press to select multiple.';

  @override
  String get homeSectionsHeading => 'Shortcut Sections';

  @override
  String homeFilteredCount(int visible, int total) {
    return '$visible/$total';
  }

  @override
  String homeTotalCount(int total) {
    return '$total';
  }

  @override
  String get homeScanQrTooltip => 'Scan QR code';

  @override
  String get homeSwitchToList => 'Switch to list view';

  @override
  String get homeSwitchToGrid => 'Switch to grid view';

  @override
  String get homeSortTooltip => 'Sort shortcuts';

  @override
  String get homeFavoritesFirst => 'Favorites first';

  @override
  String get homeOptionsTooltip => 'Options';

  @override
  String get homeClearAllAction => 'Clear all shortcuts';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get homeAddTooltip => 'Add shortcut';

  @override
  String get homeClearSelectionTooltip => 'Clear selection';

  @override
  String homeSelectionCount(int count) {
    return '$count';
  }

  @override
  String get homeShowQrTooltip => 'Show QR code';

  @override
  String get homeDetailsTooltip => 'Shortcut details';

  @override
  String get homeEditTooltip => 'Edit shortcut';

  @override
  String get homeCopyUrlTooltip => 'Copy URL';

  @override
  String get homeExportSelectedTooltip => 'Export selected';

  @override
  String get homeDeleteSelectedTooltip => 'Delete selected';

  @override
  String get homeMoreTooltip => 'More';

  @override
  String get homeSelectAll => 'Select all';

  @override
  String get homeClearAllTitle => 'Clear all shortcuts?';

  @override
  String get homeClearAllBody =>
      'This removes every saved shortcut from the app. The YouTube links themselves are not deleted.';

  @override
  String get homeClearAllConfirm => 'Clear all';

  @override
  String get homeClearedMessage => 'All shortcuts cleared.';

  @override
  String get homeUrlCopied => 'URL copied to clipboard.';

  @override
  String homeDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count shortcuts?',
      one: 'Delete shortcut?',
    );
    return '$_temp0';
  }

  @override
  String homeDeleteOneBody(String name) {
    return 'Remove \"$name\" from the local shortcut list?';
  }

  @override
  String homeDeleteManyBody(int count) {
    return 'Remove $count shortcuts from the local shortcut list?';
  }

  @override
  String homeRemovedOne(String name) {
    return 'Removed \"$name\".';
  }

  @override
  String homeRemovedMany(int count) {
    return 'Removed $count shortcuts.';
  }

  @override
  String get homeSearchHint => 'Search shortcuts';

  @override
  String get homeClearSearchTooltip => 'Clear search';

  @override
  String get homeNoMatchTitle => 'No matching shortcuts';

  @override
  String get homeNoMatchBody =>
      'Try a different search term or clear the filters.';

  @override
  String get homeClearFilters => 'Clear filters';

  @override
  String get homeHeroTitle => 'Build your quick-launch shelf';

  @override
  String get homeHeroBody =>
      'Save the YouTube links you open most often and hand them off to the installed YouTube app with one tap.';

  @override
  String homeHeroSavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved shortcuts',
      one: '1 saved shortcut',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'No shortcuts yet';

  @override
  String get homeEmptyBody =>
      'Start with one link you open often. The app stores it locally and formats it for direct YouTube-app launch.';

  @override
  String get homeCreateFirst => 'Create first shortcut';

  @override
  String get homeUnpinFavorite => 'Unpin favorite';

  @override
  String get homePinFavorite => 'Pin favorite';

  @override
  String homeExportedMessage(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count shortcuts to \"$destination\".',
      one: 'Exported 1 shortcut to \"$destination\".',
    );
    return '$_temp0';
  }

  @override
  String get errBackupUnavailable =>
      'Backup is not available on this device build.';

  @override
  String get errFileEmpty => 'The selected file is empty.';

  @override
  String get errFileNotJson => 'The selected file is not valid JSON.';

  @override
  String get errFileNotOurBackup =>
      'The selected file is not a SreerajP YouTube Shortcuts backup.';

  @override
  String get errSchemaVersionMissing =>
      'This backup file is missing a schema version.';

  @override
  String get errSchemaVersionTooNew =>
      'This backup was created by a newer app version. Update the app and try again.';

  @override
  String get errShortcutListMissing =>
      'The backup file is missing the shortcut list.';

  @override
  String get errEntryMalformed =>
      'A shortcut entry inside the backup is malformed.';

  @override
  String get errEncryptedFormatInvalid =>
      'The encrypted backup file format is invalid.';

  @override
  String get errDecryptFailed => 'Invalid password or corrupted backup file.';

  @override
  String get errNameEmpty => 'Enter a shortcut name before saving.';

  @override
  String get errUrlEmpty =>
      'Enter a channel handle or YouTube URL before saving.';

  @override
  String get errHandleInvalid =>
      'Enter a valid channel handle (for example: JanamTVMedia or @JanamTVMedia).';

  @override
  String get errHandleOrUrlInvalid =>
      'Enter a valid channel handle or YouTube URL.';

  @override
  String get errShortLinkMissingVideoId =>
      'Short YouTube links must include a video id.';

  @override
  String get errNotYoutubeLink =>
      'Only YouTube links are supported in this app.';

  @override
  String get errWatchMissingVideoId => 'Watch URLs must include a video id.';

  @override
  String get errLiveMissingVideoId =>
      'Live stream URLs must include a video id.';

  @override
  String get errShortsMissingId => 'Shorts URLs must include a shorts id.';

  @override
  String get errPlaylistMissingListId =>
      'Playlist URLs must include a list id.';

  @override
  String get errChannelMissingIdentifier =>
      'Channel links must include an identifier.';

  @override
  String get errUnsupportedLinkFormat =>
      'This YouTube link format is not supported yet. Use watch, youtu.be, live, shorts, playlist, or channel links.';

  @override
  String get errYoutubeAppUnavailable =>
      'The YouTube app could not be opened. Check that it is installed and enabled on this device.';

  @override
  String get errShortcutMissing =>
      'This shortcut no longer exists. Reload and try again.';

  @override
  String get errDuplicateName =>
      'Choose a different shortcut name. Names must be unique.';

  @override
  String get errReadFailed =>
      'Saved shortcuts could not be read from local storage.';

  @override
  String get errWriteRejected => 'Local shortcut save was rejected.';

  @override
  String get errWriteFailed => 'Local shortcut save failed. Please try again.';

  @override
  String get errThemeSaveFailed =>
      'Theme preference could not be saved locally.';

  @override
  String get errLayoutSaveFailed =>
      'Layout preference could not be saved locally.';

  @override
  String get errSortSaveFailed => 'Sort preference could not be saved locally.';

  @override
  String get errFavoritesFirstSaveFailed =>
      'Favorites-first preference could not be saved locally.';
}

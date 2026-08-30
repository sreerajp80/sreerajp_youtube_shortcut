import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name, shown in the task switcher and on the lock screen.
  ///
  /// In en, this message translates to:
  /// **'SreerajP YouTube Shortcuts'**
  String get appTitle;

  /// AppBar title of the About screen.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutScreenTitle;

  /// Row label on the About screen for the app version and build number.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// Row label on the About screen for the build date.
  ///
  /// In en, this message translates to:
  /// **'Build Date'**
  String get aboutBuildDateLabel;

  /// Heading of the notes card at the bottom of the About screen.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get aboutNotesTitle;

  /// Body text of the notes card on the About screen, explaining how the app behaves.
  ///
  /// In en, this message translates to:
  /// **'The app stays offline, stores shortcuts locally, and launches canonical YouTube links with an explicit Android intent.'**
  String get aboutNotesBody;

  /// Heading on the screen shown when the app fails to start up.
  ///
  /// In en, this message translates to:
  /// **'Startup issue'**
  String get fatalErrorTitle;

  /// Explanation shown on the startup failure screen when bootstrapping the app throws.
  ///
  /// In en, this message translates to:
  /// **'The app could not finish startup. Check local storage and package metadata.'**
  String get fatalErrorBootstrapDetails;

  /// Title shown on the privacy lock screen when the whole app is locked.
  ///
  /// In en, this message translates to:
  /// **'SreerajP YouTube Shortcuts Locked'**
  String get privacyLockAppLockedTitle;

  /// AppBar title of the Permissions screen.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsScreenTitle;

  /// Heading of the intro card on the Permissions screen.
  ///
  /// In en, this message translates to:
  /// **'Permission prompts on Android'**
  String get permissionsIntroTitle;

  /// Body of the intro card on the Permissions screen.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is used exclusively for the optional in-app QR scanner. The app never requests internet access or background tracking permissions.'**
  String get permissionsIntroBody;

  /// Section heading for permissions the user is prompted to grant.
  ///
  /// In en, this message translates to:
  /// **'Explicit Permissions'**
  String get permissionsExplicitSection;

  /// Section heading for manifest declarations that need no user prompt.
  ///
  /// In en, this message translates to:
  /// **'Implicit Permissions / Declarations'**
  String get permissionsImplicitSection;

  /// Title of the camera permission card. Contains the Android permission id, which is not translated.
  ///
  /// In en, this message translates to:
  /// **'Camera (android.permission.CAMERA)'**
  String get permissionCameraTitle;

  /// Short scope line for the camera permission card.
  ///
  /// In en, this message translates to:
  /// **'Offline In-App QR Scanner'**
  String get permissionCameraScope;

  /// Full explanation of why the app asks for camera permission.
  ///
  /// In en, this message translates to:
  /// **'Requested only when launching the in-app offline camera QR scanner to scan YouTube QR codes. Camera frames are processed strictly on-device using local vision ML kit, with zero network connections or telemetry.'**
  String get permissionCameraDetails;

  /// Title of the launcher visibility declaration card.
  ///
  /// In en, this message translates to:
  /// **'Launcher visibility'**
  String get permissionLauncherTitle;

  /// Scope line naming the Android manifest entry for launcher visibility.
  ///
  /// In en, this message translates to:
  /// **'MainActivity exported with MAIN/LAUNCHER intent filter'**
  String get permissionLauncherScope;

  /// Explanation of the launcher visibility declaration.
  ///
  /// In en, this message translates to:
  /// **'Lets Android show and start the app from the launcher. This does not request user permission.'**
  String get permissionLauncherDetails;

  /// Title of the package visibility query declaration card.
  ///
  /// In en, this message translates to:
  /// **'Package visibility query'**
  String get permissionQueriesTitle;

  /// Scope line naming the Android manifest queries element.
  ///
  /// In en, this message translates to:
  /// **'<queries> for PROCESS_TEXT (text/plain)'**
  String get permissionQueriesScope;

  /// Explanation of the package visibility query declaration.
  ///
  /// In en, this message translates to:
  /// **'Declares app-lookup capability for matching text processors. This is a manifest declaration, not a runtime permission.'**
  String get permissionQueriesDetails;

  /// Title of the share-target declaration card.
  ///
  /// In en, this message translates to:
  /// **'Share-target intent filter'**
  String get permissionShareTargetTitle;

  /// Scope line naming the Android share intent filter.
  ///
  /// In en, this message translates to:
  /// **'MainActivity ACTION_SEND with text/plain'**
  String get permissionShareTargetScope;

  /// Explanation of the share-target intent filter.
  ///
  /// In en, this message translates to:
  /// **'Lets the app appear in the Android share sheet so a YouTube link shared from another app can pre-fill the Add Shortcut form. Only the shared text is read; no internet, storage, or runtime permission is requested.'**
  String get permissionShareTargetDetails;

  /// Title of the clipboard access card.
  ///
  /// In en, this message translates to:
  /// **'Clipboard read on Add Shortcut screen'**
  String get permissionClipboardTitle;

  /// Scope line naming the clipboard API call and when it happens.
  ///
  /// In en, this message translates to:
  /// **'Clipboard.getData(text/plain) when opening the Add Shortcut form'**
  String get permissionClipboardScope;

  /// Explanation of the one-time clipboard read on the Add Shortcut screen.
  ///
  /// In en, this message translates to:
  /// **'When the Add Shortcut screen opens for a new shortcut, the app reads the system clipboard once to offer a one-tap paste if it contains a YouTube link. The suggestion is dismissable and never sent off-device. No manifest permission is required, but Android 12 and newer show a brief system message when an app reads the clipboard.'**
  String get permissionClipboardDetails;

  /// Title of the backup and restore file access card.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore via system file picker'**
  String get permissionBackupTitle;

  /// Scope line naming the Android Storage Access Framework intents used for backup files.
  ///
  /// In en, this message translates to:
  /// **'ACTION_CREATE_DOCUMENT and ACTION_OPEN_DOCUMENT (Storage Access Framework)'**
  String get permissionBackupScope;

  /// Explanation of how backup and restore reach files without a storage permission.
  ///
  /// In en, this message translates to:
  /// **'When you export or import a shortcut backup from Settings, the app launches the Android system file picker. You pick the destination or source file yourself, and Android grants the app one-time access to that single file. No storage permission is requested in the manifest, the app cannot browse other files, and no data leaves the device.'**
  String get permissionBackupDetails;

  /// Instruction line under the title on the privacy lock screen.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN or use biometrics to continue'**
  String get privacyLockSubtitle;

  /// Error shown when the entered PIN does not match.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Try again.'**
  String get privacyLockIncorrectPin;

  /// Tooltip for the fingerprint button on the PIN pad.
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get privacyLockBiometricTooltip;

  /// Tooltip for the button that clears the entered PIN.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get privacyLockClearTooltip;

  /// Tooltip for the button that deletes the last entered PIN digit.
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get privacyLockBackspaceTooltip;

  /// Name of the grid home-screen layout.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get layoutGrid;

  /// Name of the list home-screen layout.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get layoutList;

  /// Theme option that follows the Android system setting.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Name of the light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Name of the standard dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Classic Dark'**
  String get themeDark;

  /// Name of the pure-black theme option for AMOLED screens.
  ///
  /// In en, this message translates to:
  /// **'AMOLED Pure Black'**
  String get themeAmoled;

  /// Name of the warm sepia theme option.
  ///
  /// In en, this message translates to:
  /// **'Warm Sepia'**
  String get themeWarmSepia;

  /// Name of the dark green theme option.
  ///
  /// In en, this message translates to:
  /// **'Forest Dark'**
  String get themeForestDark;

  /// Name of the neon cyberpunk theme option.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk Neon'**
  String get themeCyberpunkNeon;

  /// Sort option keeping the order the user arranged by hand.
  ///
  /// In en, this message translates to:
  /// **'Manual order'**
  String get sortManual;

  /// Sort option ordering shortcuts by name from A to Z.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical (A–Z)'**
  String get sortAlphabetical;

  /// Sort option showing the most recently created shortcuts first.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// Sort option showing the most recently opened shortcuts first.
  ///
  /// In en, this message translates to:
  /// **'Recently launched'**
  String get sortRecent;

  /// Sort option showing the most frequently opened shortcuts first.
  ///
  /// In en, this message translates to:
  /// **'Most launched'**
  String get sortMostUsed;

  /// Badge for a shortcut that points at a single YouTube video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get targetTypeVideo;

  /// Badge for a shortcut that points at a YouTube Shorts video.
  ///
  /// In en, this message translates to:
  /// **'Shorts'**
  String get targetTypeShorts;

  /// Badge for a shortcut that points at a YouTube playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get targetTypePlaylist;

  /// Badge for a shortcut that points at a YouTube channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get targetTypeChannel;

  /// AppBar title of the screen explaining how channel-handle shortcuts behave.
  ///
  /// In en, this message translates to:
  /// **'Channel handles'**
  String get behaviorScreenTitle;

  /// Heading of the card explaining handle-based shortcuts.
  ///
  /// In en, this message translates to:
  /// **'How \'@\' shortcuts work'**
  String get behaviorHowItWorksTitle;

  /// Explanation of how a bare handle is rewritten into a live URL.
  ///
  /// In en, this message translates to:
  /// **'When you save a shortcut using a bare channel handle (for example \"@JanamTVMedia\" or \"JanamTVMedia\"), the app rewrites it to the YouTube live URL:'**
  String get behaviorHowItWorksBody;

  /// The URL shape a bare handle is rewritten to. Shown in a monospace pill; not translated.
  ///
  /// In en, this message translates to:
  /// **'https://www.youtube.com/@<handle>/live'**
  String get behaviorLiveUrlPattern;

  /// Explains that YouTube, not this app, decides what the live URL opens.
  ///
  /// In en, this message translates to:
  /// **'YouTube uses this URL convention to route viewers to a channel\'s currently-live stream. Tapping the shortcut sends this URL to the YouTube app, which then decides what to show.'**
  String get behaviorRoutingBody;

  /// Section heading for what happens when a channel is not streaming.
  ///
  /// In en, this message translates to:
  /// **'If the channel isn\'t live'**
  String get behaviorNotLiveSection;

  /// Intro line above the list of possible outcomes for a handle shortcut.
  ///
  /// In en, this message translates to:
  /// **'This app stays offline and cannot check live status in advance — it just hands the URL to YouTube. What you see depends on YouTube\'s handling for that channel:'**
  String get behaviorNotLiveIntro;

  /// Channel state: the channel is live right now.
  ///
  /// In en, this message translates to:
  /// **'Currently streaming'**
  String get behaviorCaseStreamingState;

  /// What opens when the channel is live right now.
  ///
  /// In en, this message translates to:
  /// **'Opens the live watch page (the intended outcome).'**
  String get behaviorCaseStreamingResult;

  /// Channel state: a stream is scheduled but has not started.
  ///
  /// In en, this message translates to:
  /// **'Has an upcoming or scheduled stream'**
  String get behaviorCaseUpcomingState;

  /// What opens when the channel has a scheduled stream.
  ///
  /// In en, this message translates to:
  /// **'Opens the upcoming stream page with the countdown and waiting room.'**
  String get behaviorCaseUpcomingResult;

  /// Channel state: the channel has streamed before but is not live now.
  ///
  /// In en, this message translates to:
  /// **'Has past live streams only'**
  String get behaviorCasePastState;

  /// What opens when the channel has only finished streams.
  ///
  /// In en, this message translates to:
  /// **'Often opens the most recent finished live stream as a video, or the channel\'s Live tab.'**
  String get behaviorCasePastResult;

  /// Channel state: the channel has never streamed.
  ///
  /// In en, this message translates to:
  /// **'Has never gone live'**
  String get behaviorCaseNeverState;

  /// What opens when the channel has never streamed.
  ///
  /// In en, this message translates to:
  /// **'Falls back to the channel\'s home page.'**
  String get behaviorCaseNeverResult;

  /// Channel state: the saved handle does not match a real channel.
  ///
  /// In en, this message translates to:
  /// **'Handle is invalid or misspelled'**
  String get behaviorCaseInvalidState;

  /// What opens when the handle does not exist.
  ///
  /// In en, this message translates to:
  /// **'YouTube shows its \'page not available\' state inside the app.'**
  String get behaviorCaseInvalidResult;

  /// Caveat under the list of handle outcomes.
  ///
  /// In en, this message translates to:
  /// **'YouTube can change these behaviours at any time; the app has no control over what loads after the URL is opened.'**
  String get behaviorCasesFootnote;

  /// Section heading for extra notes about handle shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Good to know'**
  String get behaviorGoodToKnowSection;

  /// Note heading about the app being unable to verify handles.
  ///
  /// In en, this message translates to:
  /// **'No connectivity check'**
  String get behaviorNoConnectivityTitle;

  /// Explains that handles are only shape-checked, never looked up online.
  ///
  /// In en, this message translates to:
  /// **'This app is fully offline and never reaches the internet. It cannot verify in advance whether a handle exists or is live. Handles are validated only for shape (3-30 letters, digits, dot, dash, or underscore).'**
  String get behaviorNoConnectivityBody;

  /// Note heading about pinning a channel home page instead of the live page.
  ///
  /// In en, this message translates to:
  /// **'To open the channel page instead of live'**
  String get behaviorChannelPageTitle;

  /// Tells the user to save a full URL to open the channel home page.
  ///
  /// In en, this message translates to:
  /// **'Bare handles always route to /live. To pin a shortcut that opens the channel home page, save the full URL — for example: https://www.youtube.com/@JanamTVMedia'**
  String get behaviorChannelPageBody;

  /// Tooltip for the button that closes the QR code dialog.
  ///
  /// In en, this message translates to:
  /// **'Close dialog'**
  String get qrDialogCloseTooltip;

  /// Heading under the QR code, stressing that sharing needs no network.
  ///
  /// In en, this message translates to:
  /// **'Air-Gapped QR Code'**
  String get qrDialogTitle;

  /// Instruction under the QR code heading.
  ///
  /// In en, this message translates to:
  /// **'Scan this code with another device to open or save this shortcut.'**
  String get qrDialogSubtitle;

  /// Button that copies the shortcut URL to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get qrDialogCopyUrl;

  /// Confirmation shown after the shortcut URL is copied.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard'**
  String get qrDialogUrlCopied;

  /// Button that closes a dialog when the user has finished.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// AppBar title of the Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// Summary card at the top of the Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Manage app appearance, information, and Android manifest permissions.'**
  String get settingsIntro;

  /// Section heading for look-and-feel settings.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// Heading of the theme picker card.
  ///
  /// In en, this message translates to:
  /// **'Theme Selection'**
  String get settingsThemeSelection;

  /// Settings row that opens the About screen.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutTitle;

  /// Description of the About settings row.
  ///
  /// In en, this message translates to:
  /// **'App details, version, build metadata, and notes.'**
  String get settingsAboutSubtitle;

  /// Settings row that opens the Permissions screen.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsPermissionsTitle;

  /// Description of the Permissions settings row.
  ///
  /// In en, this message translates to:
  /// **'Explicit and implicit permission-related manifest declarations.'**
  String get settingsPermissionsSubtitle;

  /// Settings row that opens the channel-handle explanation screen.
  ///
  /// In en, this message translates to:
  /// **'Channel handles'**
  String get settingsHandlesTitle;

  /// Description of the channel handles settings row.
  ///
  /// In en, this message translates to:
  /// **'How \'@\' shortcuts route to live streams.'**
  String get settingsHandlesSubtitle;

  /// Settings row that opens the Backup and Restore screen.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get settingsBackupTitle;

  /// Description of the Backup and Restore settings row.
  ///
  /// In en, this message translates to:
  /// **'Export shortcuts to a JSON file you control, or import a previous backup.'**
  String get settingsBackupSubtitle;

  /// Section heading for PIN and lock settings.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settingsPrivacySection;

  /// Description of the System theme option.
  ///
  /// In en, this message translates to:
  /// **'Follow your phone system settings.'**
  String get themeDescSystem;

  /// Description of the Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Clean bright background with warm crimson accents.'**
  String get themeDescLight;

  /// Description of the Classic Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Classic dark mode with slate background and teal highlights.'**
  String get themeDescDark;

  /// Description of the AMOLED theme option.
  ///
  /// In en, this message translates to:
  /// **'Pure pitch black (#000000) for OLED displays and maximum power savings.'**
  String get themeDescAmoled;

  /// Description of the Warm Sepia theme option.
  ///
  /// In en, this message translates to:
  /// **'Cozy parchment cream tones with rich terracotta primary.'**
  String get themeDescWarmSepia;

  /// Description of the Forest Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Deep pine background with vibrant emerald and mint accents.'**
  String get themeDescForestDark;

  /// Description of the Cyberpunk Neon theme option.
  ///
  /// In en, this message translates to:
  /// **'Futuristic dark synth palette with glowing cyan and neon magenta.'**
  String get themeDescCyberpunkNeon;

  /// Title used when a PIN already exists and can be changed.
  ///
  /// In en, this message translates to:
  /// **'Change Security PIN'**
  String get pinChangeTitle;

  /// Title used when no PIN exists yet.
  ///
  /// In en, this message translates to:
  /// **'Set Security PIN'**
  String get pinSetTitle;

  /// Shown when a PIN is already set.
  ///
  /// In en, this message translates to:
  /// **'4–6 digit PIN configured'**
  String get pinConfiguredSubtitle;

  /// Shown when no PIN is set yet.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN to enable app and private shortcut lock'**
  String get pinNotConfiguredSubtitle;

  /// Button that opens the change-PIN dialog.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get pinChangeAction;

  /// Button that opens the set-PIN dialog.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get pinSetAction;

  /// Label of the field where the new PIN is typed.
  ///
  /// In en, this message translates to:
  /// **'Enter 4–6 digit PIN'**
  String get pinEnterLabel;

  /// Label of the field where the new PIN is repeated.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinConfirmLabel;

  /// Error shown when the two PIN fields disagree or the PIN is too short.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match or are too short (min 4 digits).'**
  String get pinMismatchError;

  /// Confirmation shown after a PIN is saved.
  ///
  /// In en, this message translates to:
  /// **'Security PIN saved.'**
  String get pinSavedMessage;

  /// Error shown when saving a PIN fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to set PIN.'**
  String get pinSaveFailedMessage;

  /// Switch that requires unlocking when the app opens.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLockTitle;

  /// Explanation of the App Lock switch.
  ///
  /// In en, this message translates to:
  /// **'Require PIN or biometrics when launching the app'**
  String get appLockSubtitle;

  /// Switch that gates shortcuts marked private.
  ///
  /// In en, this message translates to:
  /// **'Lock Private Shortcuts'**
  String get privateLockTitle;

  /// Explanation of the private shortcut lock switch.
  ///
  /// In en, this message translates to:
  /// **'Gate access to shortcuts marked as private'**
  String get privateLockSubtitle;

  /// Button that dismisses a dialog without acting.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Button that confirms and stores what the user entered.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// AppBar title of the Backup and Restore screen.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupScreenTitle;

  /// Heading of the intro card on the Backup and Restore screen.
  ///
  /// In en, this message translates to:
  /// **'Move shortcuts between devices'**
  String get backupIntroTitle;

  /// Body of the intro card, stressing that backup never uses a network.
  ///
  /// In en, this message translates to:
  /// **'Export your saved shortcuts to a JSON file or scan an offline QR code bundle. Everything stays on-device — no cloud or servers required.'**
  String get backupIntroBody;

  /// Section heading for exporting shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get backupExportSection;

  /// Shown in the export card when no shortcuts exist.
  ///
  /// In en, this message translates to:
  /// **'No shortcuts to export yet. Add at least one shortcut from the home screen, then return here.'**
  String get backupNothingToExport;

  /// Shown in the export card, telling the user how many shortcuts will be exported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Save your 1 shortcut to a JSON file or generate an offline Backup QR Code.} other{Save all {count} shortcuts to a JSON file or generate an offline Backup QR Code.}}'**
  String backupExportCount(int count);

  /// Button label while an export is running.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get backupExporting;

  /// Button that exports shortcuts to a JSON file.
  ///
  /// In en, this message translates to:
  /// **'Export to file'**
  String get backupExportToFile;

  /// Button that shows the shortcuts as scannable QR codes.
  ///
  /// In en, this message translates to:
  /// **'Export via QR code'**
  String get backupExportViaQr;

  /// Section heading for importing shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get backupImportSection;

  /// Body of the import card.
  ///
  /// In en, this message translates to:
  /// **'Pick a backup file or scan a Backup QR code from another device to restore shortcuts and app settings.'**
  String get backupImportIntro;

  /// Button that adds backup entries alongside existing shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Import & merge'**
  String get backupImportMerge;

  /// Button that wipes existing shortcuts and loads the backup.
  ///
  /// In en, this message translates to:
  /// **'Import & replace'**
  String get backupImportReplace;

  /// Button that opens the camera to scan a backup QR code.
  ///
  /// In en, this message translates to:
  /// **'Scan Backup QR'**
  String get backupScanQr;

  /// Warning under the import buttons about replace mode.
  ///
  /// In en, this message translates to:
  /// **'Replace removes every saved shortcut on this device first, then loads the backup. There is no undo.'**
  String get backupReplaceWarning;

  /// Section heading listing what a backup file contains.
  ///
  /// In en, this message translates to:
  /// **'What is in the file'**
  String get backupContentsSection;

  /// Bullet describing the shortcut fields stored in a backup.
  ///
  /// In en, this message translates to:
  /// **'Each saved shortcut: name, the URL you entered, the canonical YouTube URL the app launches, the target type, and the created/updated timestamps.'**
  String get backupContentsShortcuts;

  /// Bullet describing the schema metadata stored in a backup.
  ///
  /// In en, this message translates to:
  /// **'A schema version and an export timestamp so future app versions can read the file safely.'**
  String get backupContentsSchema;

  /// Bullet listing what a backup deliberately leaves out.
  ///
  /// In en, this message translates to:
  /// **'No theme or layout preferences, no analytics, and nothing about your device — only the shortcut entries you created.'**
  String get backupContentsExcluded;

  /// Title of the dialog shown before exporting.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get backupExportDialogTitle;

  /// Checkbox that turns on password encryption for the export.
  ///
  /// In en, this message translates to:
  /// **'Encrypt backup with password'**
  String get backupEncryptOption;

  /// Explains which encryption the backup uses.
  ///
  /// In en, this message translates to:
  /// **'Uses AES-256 encryption with PBKDF2'**
  String get backupEncryptSubtitle;

  /// Label of the export password field.
  ///
  /// In en, this message translates to:
  /// **'Enter Backup Password'**
  String get backupPasswordEnterLabel;

  /// Hint text under the export password field.
  ///
  /// In en, this message translates to:
  /// **'Minimum 4 characters'**
  String get backupPasswordHint;

  /// Error shown when encryption is on but no password was typed.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get backupPasswordRequired;

  /// Button that starts the export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get backupExportAction;

  /// Confirmation after a successful export, naming the file it was written to.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 shortcut to \"{destination}\".} other{Exported {count} shortcuts to \"{destination}\".}}'**
  String backupExportedMessage(int count, String destination);

  /// Shown when the user backs out of the export file picker.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled.'**
  String get backupExportCancelled;

  /// Title of the dialog asking for the password of an encrypted backup.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Backup Detected'**
  String get backupEncryptedDetectedTitle;

  /// Explains why a password is being asked for during import.
  ///
  /// In en, this message translates to:
  /// **'This backup file is encrypted. Enter the password used during export to decrypt it.'**
  String get backupEncryptedDetectedBody;

  /// Label of the import password field.
  ///
  /// In en, this message translates to:
  /// **'Backup Password'**
  String get backupPasswordLabel;

  /// Button that decrypts and imports an encrypted backup.
  ///
  /// In en, this message translates to:
  /// **'Decrypt & Import'**
  String get backupDecryptImportAction;

  /// Shown when the user backs out of the import flow.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled.'**
  String get backupImportCancelled;

  /// Title of the confirmation dialog for replace-mode import.
  ///
  /// In en, this message translates to:
  /// **'Replace all shortcuts?'**
  String get backupReplaceConfirmTitle;

  /// Warning text of the replace-mode confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Importing in replace mode removes every shortcut currently saved on this device, then loads the picked backup file. This cannot be undone. Continue?'**
  String get backupReplaceConfirmBody;

  /// Button confirming a destructive replace-mode import.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get backupReplaceAction;

  /// Result message when a merge import added nothing.
  ///
  /// In en, this message translates to:
  /// **'No new shortcuts added — the file matched names already saved.'**
  String get backupMergeNoneAdded;

  /// Result message when a merge import added entries and skipped none.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 shortcut.} other{Imported {count} shortcuts.}}'**
  String backupMergeAdded(int count);

  /// Result message when a merge import added some entries and skipped duplicates.
  ///
  /// In en, this message translates to:
  /// **'{added, plural, =1{Imported 1 new shortcut} other{Imported {added} new shortcuts}}; {skipped, plural, =1{skipped 1 duplicate name.} other{skipped {skipped} duplicate names.}}'**
  String backupMergeAddedSkipped(int added, int skipped);

  /// Result message after a replace-mode import.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Replaced local list with 1 shortcut from the file.} other{Replaced local list with {count} shortcuts from the file.}}'**
  String backupReplaceResult(int count);

  /// Title of the dialog that shows a whole backup as QR codes.
  ///
  /// In en, this message translates to:
  /// **'Backup QR Transfer'**
  String get bulkQrTitle;

  /// Says how many shortcuts the QR bundle carries, alongside the app settings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shortcut & app settings} other{{count} shortcuts & app settings}}'**
  String bulkQrSubtitle(int count);

  /// Transfer estimate when the whole backup fits in one QR code.
  ///
  /// In en, this message translates to:
  /// **'< 1 sec (Instant)'**
  String get bulkQrInstantTime;

  /// Transfer estimate for an animated multi-frame QR bundle.
  ///
  /// In en, this message translates to:
  /// **'~{seconds} seconds'**
  String bulkQrSecondsTime(String seconds);

  /// Banner showing how long scanning the whole bundle should take.
  ///
  /// In en, this message translates to:
  /// **'Estimated Transfer Time: {estimate}'**
  String bulkQrEstimatedTime(String estimate);

  /// Warning shown when the backup needs many QR frames.
  ///
  /// In en, this message translates to:
  /// **'Large Backup Bundle ({frames} frames). For faster transfer of large data, use JSON File Export/Import instead.'**
  String bulkQrLargeWarning(int frames);

  /// Shows which QR frame of the animation is on screen.
  ///
  /// In en, this message translates to:
  /// **'Animated Frame {current} / {total}'**
  String bulkQrFrameCounter(int current, int total);

  /// Tooltip for the button that pauses the animated QR frames.
  ///
  /// In en, this message translates to:
  /// **'Pause stream'**
  String get bulkQrPauseTooltip;

  /// Tooltip for the button that resumes the animated QR frames.
  ///
  /// In en, this message translates to:
  /// **'Play stream'**
  String get bulkQrPlayTooltip;

  /// Instruction shown under an animated multi-frame QR bundle.
  ///
  /// In en, this message translates to:
  /// **'Hold the receiver device camera steady in front of this screen until all frame chunks are scanned.'**
  String get bulkQrAnimatedHint;

  /// Instruction shown under a single-frame QR bundle.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with SreerajP YouTube Shortcuts on another device to restore all shortcuts and app settings.'**
  String get bulkQrSingleHint;

  /// AppBar title of the shortcut details screen.
  ///
  /// In en, this message translates to:
  /// **'Shortcut details'**
  String get detailScreenTitle;

  /// Tooltip for the action that shows this shortcut as a QR code.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get detailShowQrTooltip;

  /// Tooltip for removing a shortcut from favorites.
  ///
  /// In en, this message translates to:
  /// **'Unpin favorite'**
  String get detailUnpinFavorite;

  /// Tooltip for marking a shortcut as a favorite.
  ///
  /// In en, this message translates to:
  /// **'Pin favorite'**
  String get detailPinFavorite;

  /// Tooltip for the action that edits this shortcut.
  ///
  /// In en, this message translates to:
  /// **'Edit shortcut'**
  String get detailEditTooltip;

  /// Tooltip for the action that deletes this shortcut.
  ///
  /// In en, this message translates to:
  /// **'Delete shortcut'**
  String get detailDeleteTooltip;

  /// Button label while the YouTube app is being launched.
  ///
  /// In en, this message translates to:
  /// **'Opening...'**
  String get detailOpening;

  /// Button that opens the shortcut in the YouTube app.
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get detailOpenInYoutube;

  /// Short button label that shows the shortcut as a QR code.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get detailQrCode;

  /// Button that copies the shortcut URL.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get detailCopyUrl;

  /// Short button label that opens the edit form.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get detailEdit;

  /// Section label above the shortcut URLs.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get detailDestinationSection;

  /// Label for the canonical URL the app actually launches.
  ///
  /// In en, this message translates to:
  /// **'Full URL'**
  String get detailFullUrlLabel;

  /// Label for the URL exactly as the user typed it.
  ///
  /// In en, this message translates to:
  /// **'Original input'**
  String get detailOriginalInputLabel;

  /// Confirmation after copying the originally entered URL.
  ///
  /// In en, this message translates to:
  /// **'Original input copied to clipboard.'**
  String get detailOriginalInputCopied;

  /// Confirmation after copying the canonical URL.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard.'**
  String get detailUrlCopied;

  /// Tooltip for the small copy button beside a URL.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get detailCopyTooltip;

  /// Section label above the launch statistics.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get detailActivitySection;

  /// Row label for when the shortcut was last opened.
  ///
  /// In en, this message translates to:
  /// **'Last launched'**
  String get detailLastLaunched;

  /// Shown when a shortcut has never been opened.
  ///
  /// In en, this message translates to:
  /// **'Never launched'**
  String get detailNeverLaunched;

  /// Row label for how many times the shortcut was opened.
  ///
  /// In en, this message translates to:
  /// **'Launch count'**
  String get detailLaunchCount;

  /// How many times a shortcut has been opened.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 launch} other{{count} launches}}'**
  String detailLaunchCountValue(int count);

  /// Row label for when the shortcut was created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get detailCreated;

  /// Row label for when the shortcut was last changed.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get detailUpdated;

  /// Shown when a shortcut has never been edited since creation.
  ///
  /// In en, this message translates to:
  /// **'Same as created'**
  String get detailSameAsCreated;

  /// Reassurance that launch statistics never leave the device.
  ///
  /// In en, this message translates to:
  /// **'Activity is tracked locally on this device only.'**
  String get detailActivityFootnote;

  /// Title of the delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete shortcut?'**
  String get detailDeleteConfirmTitle;

  /// Body of the delete confirmation dialog, naming the shortcut.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the local shortcut list?'**
  String detailDeleteConfirmBody(String name);

  /// Confirmation shown after a shortcut is deleted.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{name}\".'**
  String detailRemovedMessage(String name);

  /// Button that confirms deleting something.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// AppBar title when editing an existing shortcut.
  ///
  /// In en, this message translates to:
  /// **'Edit shortcut'**
  String get addEditTitle;

  /// AppBar title when creating a new shortcut.
  ///
  /// In en, this message translates to:
  /// **'Add shortcut'**
  String get addNewTitle;

  /// Hero heading shown when editing a shortcut.
  ///
  /// In en, this message translates to:
  /// **'Update this shortcut'**
  String get addEditHeroTitle;

  /// Hero heading shown when creating a shortcut.
  ///
  /// In en, this message translates to:
  /// **'Create a quick-launch card'**
  String get addNewHeroTitle;

  /// Hero description shown when editing a shortcut.
  ///
  /// In en, this message translates to:
  /// **'Change the shortcut name, handle, tags, or favorite status.'**
  String get addEditHeroBody;

  /// Hero description shown when creating a shortcut.
  ///
  /// In en, this message translates to:
  /// **'Enter a channel handle or paste a YouTube URL. Add custom tags to categorize and mark as favorite to pin to top.'**
  String get addNewHeroBody;

  /// Button that saves edits to an existing shortcut.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get addSaveChanges;

  /// Button that saves a newly created shortcut.
  ///
  /// In en, this message translates to:
  /// **'Save shortcut'**
  String get addSaveShortcut;

  /// Button label while an edited shortcut is being saved.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get addUpdating;

  /// Button label while a new shortcut is being saved.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get addSaving;

  /// Label of the shortcut name field.
  ///
  /// In en, this message translates to:
  /// **'Shortcut name'**
  String get addNameLabel;

  /// Hint text for the shortcut name field.
  ///
  /// In en, this message translates to:
  /// **'Example: Morning Mix'**
  String get addNameHint;

  /// Label of the field where the handle or link is typed.
  ///
  /// In en, this message translates to:
  /// **'Channel handle or YouTube URL'**
  String get addUrlLabel;

  /// Hint showing the two accepted input shapes. Not translated.
  ///
  /// In en, this message translates to:
  /// **'@MyChannel or https://www.youtube.com/@MyChannel/live'**
  String get addUrlHint;

  /// Tooltip for the button that opens the QR scanner from the URL field.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get addScanQrTooltip;

  /// Live preview of the canonical URL the shortcut will launch.
  ///
  /// In en, this message translates to:
  /// **'Full URL: {url}'**
  String addFullUrlPreview(String url);

  /// Switch that pins the shortcut to the top of the list.
  ///
  /// In en, this message translates to:
  /// **'Pin as Favorite'**
  String get addFavoriteTitle;

  /// Explanation of the favorite switch.
  ///
  /// In en, this message translates to:
  /// **'Keep this shortcut pinned to the top of your list'**
  String get addFavoriteSubtitle;

  /// Switch that marks the shortcut as private.
  ///
  /// In en, this message translates to:
  /// **'Private Shortcut'**
  String get addPrivateTitle;

  /// Explanation of the private shortcut switch.
  ///
  /// In en, this message translates to:
  /// **'Hide when private vault is locked'**
  String get addPrivateSubtitle;

  /// Heading of the accent colour picker.
  ///
  /// In en, this message translates to:
  /// **'Custom Card Accent Color'**
  String get addAccentColorSection;

  /// Choice that keeps the automatic card colour.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get addColorDefault;

  /// Heading of the card icon picker.
  ///
  /// In en, this message translates to:
  /// **'Custom Card Icon'**
  String get addIconSection;

  /// Choice that shows the shortcut initials instead of an icon.
  ///
  /// In en, this message translates to:
  /// **'Default Initials'**
  String get addIconDefault;

  /// Heading of the tag editor.
  ///
  /// In en, this message translates to:
  /// **'Custom Tags'**
  String get addTagsSection;

  /// Label of the field and button that add a tag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTagLabel;

  /// Hint text for the tag entry field.
  ///
  /// In en, this message translates to:
  /// **'e.g. #Tech or Personal'**
  String get addTagHint;

  /// Heading above the ready-made tag chips.
  ///
  /// In en, this message translates to:
  /// **'Suggested Tags'**
  String get addSuggestedTags;

  /// Reassurance under the save button that nothing is uploaded.
  ///
  /// In en, this message translates to:
  /// **'The app stores the shortcut locally and does not request internet access.'**
  String get addOfflineFootnote;

  /// Confirmation after an existing shortcut is saved.
  ///
  /// In en, this message translates to:
  /// **'Shortcut updated.'**
  String get addShortcutUpdated;

  /// Confirmation after a new shortcut is saved.
  ///
  /// In en, this message translates to:
  /// **'Shortcut saved.'**
  String get addShortcutSaved;

  /// Heading of the banner offering to paste a YouTube link from the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste this link?'**
  String get addPasteSuggestionTitle;

  /// Button that hides the clipboard paste suggestion.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get addPasteDismiss;

  /// Button that fills the URL field from the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get addPasteAction;

  /// Name of the crimson accent colour.
  ///
  /// In en, this message translates to:
  /// **'Crimson'**
  String get colorCrimson;

  /// Name of the orange accent colour.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// Name of the amber accent colour.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get colorAmber;

  /// Name of the emerald accent colour.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get colorEmerald;

  /// Name of the teal accent colour.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// Name of the cyan accent colour.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get colorCyan;

  /// Name of the blue accent colour.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// Name of the indigo accent colour.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// Name of the purple accent colour.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// Name of the pink accent colour.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// Name of the slate accent colour.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get colorSlate;

  /// AppBar title of the QR scanner screen.
  ///
  /// In en, this message translates to:
  /// **'Offline QR Scanner'**
  String get scannerScreenTitle;

  /// Tooltip for the camera flash button.
  ///
  /// In en, this message translates to:
  /// **'Toggle Flash'**
  String get scannerTorchTooltip;

  /// Tooltip for the front/rear camera button.
  ///
  /// In en, this message translates to:
  /// **'Switch Camera'**
  String get scannerSwitchCameraTooltip;

  /// Tooltip for the button that scans a QR code from a saved image.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get scannerGalleryTooltip;

  /// Overlay hint telling the user where to point the camera.
  ///
  /// In en, this message translates to:
  /// **'Align QR code within frame'**
  String get scannerAlignHint;

  /// Floating button that picks a QR image from the gallery.
  ///
  /// In en, this message translates to:
  /// **'Scan Image from Gallery'**
  String get scannerGalleryButton;

  /// Heading shown when the camera cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Camera Access Unavailable'**
  String get scannerCameraUnavailableTitle;

  /// Advice shown when the camera cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Ensure camera permission is enabled in Android settings, or select a QR code image from gallery.'**
  String get scannerCameraUnavailableBody;

  /// Button offering the gallery as a fallback when the camera fails.
  ///
  /// In en, this message translates to:
  /// **'Select Image from Gallery'**
  String get scannerSelectImageButton;

  /// Error shown when a scanned code holds no usable data.
  ///
  /// In en, this message translates to:
  /// **'Scanned QR code is empty or unreadable.'**
  String get scannerUnreadableCode;

  /// Error shown when a scanned code is not a YouTube link.
  ///
  /// In en, this message translates to:
  /// **'Scanned QR code is not a valid YouTube link.'**
  String get scannerNotYoutubeLink;

  /// Error shown when a picked image has no QR code.
  ///
  /// In en, this message translates to:
  /// **'No readable QR code found in selected image.'**
  String get scannerNoCodeInImage;

  /// Error shown when a picked image has a code but no YouTube link.
  ///
  /// In en, this message translates to:
  /// **'No readable YouTube QR code found in image.'**
  String get scannerNoYoutubeCodeInImage;

  /// Error shown when a picked image cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Failed to read image from gallery.'**
  String get scannerImageReadFailed;

  /// Error shown when the scanned QR frames do not form a complete backup.
  ///
  /// In en, this message translates to:
  /// **'Failed to assemble full backup payload from QR frames.'**
  String get scannerAssembleFailed;

  /// Progress message while scanning a multi-frame animated QR bundle.
  ///
  /// In en, this message translates to:
  /// **'Scanning Animated QR: Frame {current}/{total} ({collected}/{total} frames)'**
  String scannerFrameProgress(int current, int total, int collected);

  /// Error shown when the scanned link cannot be handed to YouTube.
  ///
  /// In en, this message translates to:
  /// **'Failed to open YouTube app.'**
  String get scannerLaunchFailed;

  /// Heading of the sheet shown after a whole backup is scanned.
  ///
  /// In en, this message translates to:
  /// **'Full Backup Received!'**
  String get scannerBackupReceivedTitle;

  /// Says how many shortcuts the scanned backup carries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shortcut & app settings} other{{count} shortcuts & app settings}}'**
  String scannerBackupSubtitle(int count);

  /// Asks the user whether to merge or replace when a backup is scanned.
  ///
  /// In en, this message translates to:
  /// **'Choose how to apply this backup payload to your local SreerajP YouTube Shortcuts repository:'**
  String get scannerBackupPrompt;

  /// Button that adds the scanned backup alongside existing shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Merge with Existing Shortcuts'**
  String get scannerMergeButton;

  /// Button that wipes existing shortcuts and loads the scanned backup.
  ///
  /// In en, this message translates to:
  /// **'Replace All Shortcuts'**
  String get scannerReplaceButton;

  /// Confirmation after merging a scanned backup.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 shortcut and applied settings.} other{Imported {count} shortcuts and applied settings.}}'**
  String scannerMergedMessage(int count);

  /// Confirmation after replacing everything with a scanned backup.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Replaced repository with 1 shortcut and applied settings.} other{Replaced repository with {count} shortcuts and applied settings.}}'**
  String scannerReplacedMessage(int count);

  /// Heading of the sheet shown after one shortcut is scanned.
  ///
  /// In en, this message translates to:
  /// **'Shortcut Received!'**
  String get scannerShortcutReceivedTitle;

  /// Subtitle when the scanned code was made by this app.
  ///
  /// In en, this message translates to:
  /// **'Air-Gapped Shortcut Payload'**
  String get scannerStructuredPayload;

  /// Subtitle when the scanned code was a plain YouTube link.
  ///
  /// In en, this message translates to:
  /// **'Scanned YouTube QR Link'**
  String get scannerPlainLinkPayload;

  /// Fallback name for a scanned shortcut that carried no name.
  ///
  /// In en, this message translates to:
  /// **'Scanned YouTube Link'**
  String get scannerDefaultShortcutName;

  /// Button that saves the scanned shortcut locally.
  ///
  /// In en, this message translates to:
  /// **'Save to SreerajP YouTube Shortcuts'**
  String get scannerSaveButton;

  /// Button that opens the scanned link in the YouTube app.
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get scannerOpenButton;

  /// Button that dismisses the sheet and resumes scanning.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Code'**
  String get scannerScanAnotherButton;

  /// Tooltip for the button that leaves drag-to-reorder mode.
  ///
  /// In en, this message translates to:
  /// **'Exit reorder mode'**
  String get homeExitReorderTooltip;

  /// AppBar title while the user is reordering shortcuts by hand.
  ///
  /// In en, this message translates to:
  /// **'Reorder shortcuts'**
  String get homeReorderTitle;

  /// Menu entry shown greyed out because reordering needs manual sort.
  ///
  /// In en, this message translates to:
  /// **'Reorder shortcuts (manual sort only)'**
  String get homeReorderDisabled;

  /// Subtitle shown when no shortcuts exist yet.
  ///
  /// In en, this message translates to:
  /// **'Save the links you open often. Each shortcut stays local on this device.'**
  String get homeSubtitleEmpty;

  /// Subtitle shown while reordering.
  ///
  /// In en, this message translates to:
  /// **'Long-press and drag cards to reorder them. Tap Done when finished.'**
  String get homeSubtitleReorder;

  /// Subtitle shown while selecting several shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Tap to toggle selection. Press back to exit.'**
  String get homeSubtitleSelection;

  /// Subtitle shown during normal browsing.
  ///
  /// In en, this message translates to:
  /// **'Tap a shortcut to open it. Long-press to select multiple.'**
  String get homeSubtitleNormal;

  /// Heading above the shortcut list.
  ///
  /// In en, this message translates to:
  /// **'Shortcut Sections'**
  String get homeSectionsHeading;

  /// Badge showing how many shortcuts pass the current filter out of the total.
  ///
  /// In en, this message translates to:
  /// **'{visible}/{total}'**
  String homeFilteredCount(int visible, int total);

  /// Badge showing the total number of saved shortcuts.
  ///
  /// In en, this message translates to:
  /// **'{total}'**
  String homeTotalCount(int total);

  /// Tooltip for the button that opens the QR scanner.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get homeScanQrTooltip;

  /// Tooltip for switching the home screen to a list layout.
  ///
  /// In en, this message translates to:
  /// **'Switch to list view'**
  String get homeSwitchToList;

  /// Tooltip for switching the home screen to a grid layout.
  ///
  /// In en, this message translates to:
  /// **'Switch to grid view'**
  String get homeSwitchToGrid;

  /// Tooltip for the sort menu.
  ///
  /// In en, this message translates to:
  /// **'Sort shortcuts'**
  String get homeSortTooltip;

  /// Sort menu option that lifts favorites to the top.
  ///
  /// In en, this message translates to:
  /// **'Favorites first'**
  String get homeFavoritesFirst;

  /// Tooltip for the overflow menu on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get homeOptionsTooltip;

  /// Menu entry that deletes every saved shortcut.
  ///
  /// In en, this message translates to:
  /// **'Clear all shortcuts'**
  String get homeClearAllAction;

  /// Tooltip for the button that opens Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// Tooltip for the button that creates a new shortcut.
  ///
  /// In en, this message translates to:
  /// **'Add shortcut'**
  String get homeAddTooltip;

  /// Tooltip for the button that leaves selection mode.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get homeClearSelectionTooltip;

  /// How many shortcuts are currently selected.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String homeSelectionCount(int count);

  /// Tooltip for showing the selected shortcut as a QR code.
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get homeShowQrTooltip;

  /// Tooltip for opening the selected shortcut's detail screen.
  ///
  /// In en, this message translates to:
  /// **'Shortcut details'**
  String get homeDetailsTooltip;

  /// Tooltip for editing the selected shortcut.
  ///
  /// In en, this message translates to:
  /// **'Edit shortcut'**
  String get homeEditTooltip;

  /// Tooltip for copying the selected shortcut's URL.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get homeCopyUrlTooltip;

  /// Tooltip for exporting the selected shortcuts to a file.
  ///
  /// In en, this message translates to:
  /// **'Export selected'**
  String get homeExportSelectedTooltip;

  /// Tooltip for deleting the selected shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get homeDeleteSelectedTooltip;

  /// Tooltip for the extra actions menu in selection mode.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get homeMoreTooltip;

  /// Menu entry that selects every visible shortcut.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get homeSelectAll;

  /// Title of the confirmation dialog for deleting everything.
  ///
  /// In en, this message translates to:
  /// **'Clear all shortcuts?'**
  String get homeClearAllTitle;

  /// Warning text of the clear-all confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This removes every saved shortcut from the app. The YouTube links themselves are not deleted.'**
  String get homeClearAllBody;

  /// Button confirming deletion of every shortcut.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get homeClearAllConfirm;

  /// Confirmation shown after every shortcut is deleted.
  ///
  /// In en, this message translates to:
  /// **'All shortcuts cleared.'**
  String get homeClearedMessage;

  /// Confirmation after copying a shortcut URL from the home screen.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard.'**
  String get homeUrlCopied;

  /// Title of the delete dialog, matching how many shortcuts were selected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete shortcut?} other{Delete {count} shortcuts?}}'**
  String homeDeleteManyTitle(int count);

  /// Delete confirmation naming the single shortcut being removed.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the local shortcut list?'**
  String homeDeleteOneBody(String name);

  /// Delete confirmation for several shortcuts at once.
  ///
  /// In en, this message translates to:
  /// **'Remove {count} shortcuts from the local shortcut list?'**
  String homeDeleteManyBody(int count);

  /// Confirmation after removing one shortcut.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{name}\".'**
  String homeRemovedOne(String name);

  /// Confirmation after removing several shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Removed {count} shortcuts.'**
  String homeRemovedMany(int count);

  /// Placeholder text of the search box.
  ///
  /// In en, this message translates to:
  /// **'Search shortcuts'**
  String get homeSearchHint;

  /// Tooltip for the button that empties the search box.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get homeClearSearchTooltip;

  /// Heading shown when the filters exclude everything.
  ///
  /// In en, this message translates to:
  /// **'No matching shortcuts'**
  String get homeNoMatchTitle;

  /// Advice shown when the filters exclude everything.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or clear the filters.'**
  String get homeNoMatchBody;

  /// Button that resets the search and type filters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get homeClearFilters;

  /// Heading of the welcome banner on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Build your quick-launch shelf'**
  String get homeHeroTitle;

  /// Body of the welcome banner on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Save the YouTube links you open most often and hand them off to the installed YouTube app with one tap.'**
  String get homeHeroBody;

  /// Pill in the welcome banner showing how many shortcuts are saved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved shortcut} other{{count} saved shortcuts}}'**
  String homeHeroSavedCount(int count);

  /// Heading of the empty state.
  ///
  /// In en, this message translates to:
  /// **'No shortcuts yet'**
  String get homeEmptyTitle;

  /// Body of the empty state.
  ///
  /// In en, this message translates to:
  /// **'Start with one link you open often. The app stores it locally and formats it for direct YouTube-app launch.'**
  String get homeEmptyBody;

  /// Button in the empty state that opens the add form.
  ///
  /// In en, this message translates to:
  /// **'Create first shortcut'**
  String get homeCreateFirst;

  /// Tooltip for removing a card from favorites.
  ///
  /// In en, this message translates to:
  /// **'Unpin favorite'**
  String get homeUnpinFavorite;

  /// Tooltip for marking a card as a favorite.
  ///
  /// In en, this message translates to:
  /// **'Pin favorite'**
  String get homePinFavorite;

  /// Confirmation after exporting the selected shortcuts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 shortcut to \"{destination}\".} other{Exported {count} shortcuts to \"{destination}\".}}'**
  String homeExportedMessage(int count, String destination);

  /// Shown when the platform channel for file access is missing.
  ///
  /// In en, this message translates to:
  /// **'Backup is not available on this device build.'**
  String get errBackupUnavailable;

  /// Shown when the picked backup file has no content.
  ///
  /// In en, this message translates to:
  /// **'The selected file is empty.'**
  String get errFileEmpty;

  /// Shown when the picked backup file is not valid JSON.
  ///
  /// In en, this message translates to:
  /// **'The selected file is not valid JSON.'**
  String get errFileNotJson;

  /// Shown when the picked file is JSON but not made by this app.
  ///
  /// In en, this message translates to:
  /// **'The selected file is not a SreerajP YouTube Shortcuts backup.'**
  String get errFileNotOurBackup;

  /// Shown when a backup file has no schema version field.
  ///
  /// In en, this message translates to:
  /// **'This backup file is missing a schema version.'**
  String get errSchemaVersionMissing;

  /// Shown when a backup came from a newer app version than this one.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer app version. Update the app and try again.'**
  String get errSchemaVersionTooNew;

  /// Shown when a backup file has no shortcut list.
  ///
  /// In en, this message translates to:
  /// **'The backup file is missing the shortcut list.'**
  String get errShortcutListMissing;

  /// Shown when one shortcut inside a backup cannot be read.
  ///
  /// In en, this message translates to:
  /// **'A shortcut entry inside the backup is malformed.'**
  String get errEntryMalformed;

  /// Shown when an encrypted backup has a broken envelope.
  ///
  /// In en, this message translates to:
  /// **'The encrypted backup file format is invalid.'**
  String get errEncryptedFormatInvalid;

  /// Shown when the backup password is wrong or the file is damaged.
  ///
  /// In en, this message translates to:
  /// **'Invalid password or corrupted backup file.'**
  String get errDecryptFailed;

  /// Shown when the shortcut name field is left blank.
  ///
  /// In en, this message translates to:
  /// **'Enter a shortcut name before saving.'**
  String get errNameEmpty;

  /// Shown when the handle/URL field is left blank.
  ///
  /// In en, this message translates to:
  /// **'Enter a channel handle or YouTube URL before saving.'**
  String get errUrlEmpty;

  /// Shown when a bare channel handle has an unusable shape.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid channel handle (for example: JanamTVMedia or @JanamTVMedia).'**
  String get errHandleInvalid;

  /// Shown when the input is neither a valid handle nor a valid URL.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid channel handle or YouTube URL.'**
  String get errHandleOrUrlInvalid;

  /// Shown when a youtu.be link carries no video id.
  ///
  /// In en, this message translates to:
  /// **'Short YouTube links must include a video id.'**
  String get errShortLinkMissingVideoId;

  /// Shown when the pasted link points at a different site.
  ///
  /// In en, this message translates to:
  /// **'Only YouTube links are supported in this app.'**
  String get errNotYoutubeLink;

  /// Shown when a /watch URL carries no video id.
  ///
  /// In en, this message translates to:
  /// **'Watch URLs must include a video id.'**
  String get errWatchMissingVideoId;

  /// Shown when a /live URL carries no video id.
  ///
  /// In en, this message translates to:
  /// **'Live stream URLs must include a video id.'**
  String get errLiveMissingVideoId;

  /// Shown when a /shorts URL carries no id.
  ///
  /// In en, this message translates to:
  /// **'Shorts URLs must include a shorts id.'**
  String get errShortsMissingId;

  /// Shown when a playlist URL carries no list id.
  ///
  /// In en, this message translates to:
  /// **'Playlist URLs must include a list id.'**
  String get errPlaylistMissingListId;

  /// Shown when a channel URL carries no channel identifier.
  ///
  /// In en, this message translates to:
  /// **'Channel links must include an identifier.'**
  String get errChannelMissingIdentifier;

  /// Shown when a YouTube URL uses a shape the app cannot handle.
  ///
  /// In en, this message translates to:
  /// **'This YouTube link format is not supported yet. Use watch, youtu.be, live, shorts, playlist, or channel links.'**
  String get errUnsupportedLinkFormat;

  /// Shown when the YouTube app cannot be launched.
  ///
  /// In en, this message translates to:
  /// **'The YouTube app could not be opened. Check that it is installed and enabled on this device.'**
  String get errYoutubeAppUnavailable;

  /// Shown when acting on a shortcut that was already deleted.
  ///
  /// In en, this message translates to:
  /// **'This shortcut no longer exists. Reload and try again.'**
  String get errShortcutMissing;

  /// Shown when the chosen shortcut name is already taken.
  ///
  /// In en, this message translates to:
  /// **'Choose a different shortcut name. Names must be unique.'**
  String get errDuplicateName;

  /// Shown when saved shortcuts cannot be read from local storage.
  ///
  /// In en, this message translates to:
  /// **'Saved shortcuts could not be read from local storage.'**
  String get errReadFailed;

  /// Shown when the platform refused to persist the shortcut list.
  ///
  /// In en, this message translates to:
  /// **'Local shortcut save was rejected.'**
  String get errWriteRejected;

  /// Shown when saving the shortcut list to local storage failed.
  ///
  /// In en, this message translates to:
  /// **'Local shortcut save failed. Please try again.'**
  String get errWriteFailed;

  /// Shown when the theme choice could not be persisted.
  ///
  /// In en, this message translates to:
  /// **'Theme preference could not be saved locally.'**
  String get errThemeSaveFailed;

  /// Shown when the grid/list choice could not be persisted.
  ///
  /// In en, this message translates to:
  /// **'Layout preference could not be saved locally.'**
  String get errLayoutSaveFailed;

  /// Shown when the sort choice could not be persisted.
  ///
  /// In en, this message translates to:
  /// **'Sort preference could not be saved locally.'**
  String get errSortSaveFailed;

  /// Shown when the favorites-first toggle could not be persisted.
  ///
  /// In en, this message translates to:
  /// **'Favorites-first preference could not be saved locally.'**
  String get errFavoritesFirstSaveFailed;

  /// Title of the Appearance card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// Subtitle of the Appearance card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Theme mode, color schemes, and visual preferences.'**
  String get settingsAppearanceSubtitle;

  /// Title of the Features card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get settingsFeaturesTitle;

  /// Subtitle of the Features card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Explore all features of SreerajP YouTube Shortcuts.'**
  String get settingsFeaturesSubtitle;

  /// Title of the Help card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Help & User Guides'**
  String get settingsHelpTitle;

  /// Subtitle of the Help card in Settings.
  ///
  /// In en, this message translates to:
  /// **'How to create shortcuts, QR transfers, and troubleshooting.'**
  String get settingsHelpSubtitle;

  /// AppBar title of the Appearance screen.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceScreenTitle;

  /// Hero title on the Appearance screen.
  ///
  /// In en, this message translates to:
  /// **'Visual Customization'**
  String get appearanceHeroTitle;

  /// Hero body on the Appearance screen.
  ///
  /// In en, this message translates to:
  /// **'Customize your app theme mode, color palettes, and visual presentation with curated contrast themes.'**
  String get appearanceHeroBody;

  /// Section header for Theme Mode on Appearance screen.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get appearanceThemeSectionTitle;

  /// Subtitle for Theme Mode section on Appearance screen.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred color scheme and contrast style'**
  String get appearanceThemeSectionSubtitle;

  /// AppBar title of the Features screen.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get featuresScreenTitle;

  /// Hero title on the Features screen.
  ///
  /// In en, this message translates to:
  /// **'SreerajP YouTube Shortcuts Features'**
  String get featuresHeroTitle;

  /// Hero body on the Features screen.
  ///
  /// In en, this message translates to:
  /// **'Explore every quick-launch tool, privacy safeguard, and air-gapped utility designed for you.'**
  String get featuresHeroBody;

  /// Category name for Quick-Launch & Playback features.
  ///
  /// In en, this message translates to:
  /// **'Quick-Launch & Playback'**
  String get featuresCatQuickLaunch;

  /// Category subtitle for Quick-Launch & Playback.
  ///
  /// In en, this message translates to:
  /// **'Instant YouTube launches, smart handle routing, and URL parsing'**
  String get featuresCatQuickLaunchSub;

  /// Feature title for instant intent launch.
  ///
  /// In en, this message translates to:
  /// **'Instant YouTube Launch Intent'**
  String get featureInstantLaunchTitle;

  /// Feature description for instant intent launch.
  ///
  /// In en, this message translates to:
  /// **'Launch directly into the official YouTube Android application with a single tap, bypassing browser overhead and redirects.'**
  String get featureInstantLaunchDesc;

  /// Feature title for canonical URL normalization.
  ///
  /// In en, this message translates to:
  /// **'Canonical URL Normalization'**
  String get featureCanonicalUrlTitle;

  /// Feature description for canonical URL normalization.
  ///
  /// In en, this message translates to:
  /// **'Converts messy desktop, mobile, tracking-parameter, or shortened links into clean canonical YouTube URLs.'**
  String get featureCanonicalUrlDesc;

  /// Feature title for handle routing.
  ///
  /// In en, this message translates to:
  /// **'Channel Handle @-Routing'**
  String get featureHandleRoutingTitle;

  /// Feature description for handle routing.
  ///
  /// In en, this message translates to:
  /// **'Enter bare handles like @ChannelName to automatically format and route to live streams or channel homepages.'**
  String get featureHandleRoutingDesc;

  /// Feature title for multi-type recognition.
  ///
  /// In en, this message translates to:
  /// **'Multi-Type Recognition'**
  String get featureMultiTypeTitle;

  /// Feature description for multi-type recognition.
  ///
  /// In en, this message translates to:
  /// **'Intelligently identifies and badges standard Videos, YouTube Shorts, Playlists, and Channel streams.'**
  String get featureMultiTypeDesc;

  /// Feature title for offline clipboard detection.
  ///
  /// In en, this message translates to:
  /// **'Offline Clipboard Detection'**
  String get featureClipboardPasteTitle;

  /// Feature description for offline clipboard detection.
  ///
  /// In en, this message translates to:
  /// **'Automatically detects valid YouTube links on your clipboard when opening the add screen for 1-tap pasting.'**
  String get featureClipboardPasteDesc;

  /// Category name for Organization & Visual Styling.
  ///
  /// In en, this message translates to:
  /// **'Organization & Visual Styling'**
  String get featuresCatOrganization;

  /// Category subtitle for Organization & Visual Styling.
  ///
  /// In en, this message translates to:
  /// **'Color themes, custom card icons, tags, and flexible layouts'**
  String get featuresCatOrganizationSub;

  /// Feature title for theme presets.
  ///
  /// In en, this message translates to:
  /// **'7 Curated Theme Palettes'**
  String get featureThemePresetsTitle;

  /// Feature description for theme presets.
  ///
  /// In en, this message translates to:
  /// **'Choose between Light, Dark, AMOLED Pure Black, Warm Sepia, Forest Dark, Cyberpunk Neon, or System default.'**
  String get featureThemePresetsDesc;

  /// Feature title for custom card accent colors.
  ///
  /// In en, this message translates to:
  /// **'Custom Card Accent Colors'**
  String get featureCustomColorsTitle;

  /// Feature description for custom card accent colors.
  ///
  /// In en, this message translates to:
  /// **'Pick vibrant custom color accents for individual shortcut cards so your favorite creators stand out.'**
  String get featureCustomColorsDesc;

  /// Feature title for custom card icons.
  ///
  /// In en, this message translates to:
  /// **'Custom Card Icons & Initials'**
  String get featureCustomIconsTitle;

  /// Feature description for custom card icons.
  ///
  /// In en, this message translates to:
  /// **'Assign distinct icons or initials to cards for immediate visual identification across your shelf.'**
  String get featureCustomIconsDesc;

  /// Feature title for custom tags and search.
  ///
  /// In en, this message translates to:
  /// **'Custom Tags & Instant Search'**
  String get featureTagsSearchTitle;

  /// Feature description for custom tags and search.
  ///
  /// In en, this message translates to:
  /// **'Add tags to categorize shortcuts by topic (Tech, Music, News) and filter in real-time with instant search.'**
  String get featureTagsSearchDesc;

  /// Feature title for drag-and-drop reorder and layouts.
  ///
  /// In en, this message translates to:
  /// **'Drag-and-Drop Reorder & Layouts'**
  String get featureReorderLayoutsTitle;

  /// Feature description for drag-and-drop reorder and layouts.
  ///
  /// In en, this message translates to:
  /// **'Manually reorder shortcut cards with fluid drag-and-drop, and switch between rich Grid and dense List views.'**
  String get featureReorderLayoutsDesc;

  /// Category name for Air-Gapped QR System.
  ///
  /// In en, this message translates to:
  /// **'Air-Gapped QR Code System'**
  String get featuresCatQrSystem;

  /// Category subtitle for Air-Gapped QR System.
  ///
  /// In en, this message translates to:
  /// **'Share and migrate shortcuts between devices with zero internet or cloud'**
  String get featuresCatQrSystemSub;

  /// Feature title for single shortcut QR.
  ///
  /// In en, this message translates to:
  /// **'Air-Gapped Single Shortcut QR'**
  String get featureAirGappedQrTitle;

  /// Feature description for single shortcut QR.
  ///
  /// In en, this message translates to:
  /// **'Generate instant offline QR codes for any shortcut that can be scanned by any standard QR reader or camera.'**
  String get featureAirGappedQrDesc;

  /// Feature title for animated backup QR.
  ///
  /// In en, this message translates to:
  /// **'Animated Multi-Frame Backup QR Streaming'**
  String get featureAnimatedQrBackupTitle;

  /// Feature description for animated backup QR.
  ///
  /// In en, this message translates to:
  /// **'Stream your entire shortcut collection and settings across devices using animated fountain QR frames with zero cables or network.'**
  String get featureAnimatedQrBackupDesc;

  /// Feature title for offline QR scanner.
  ///
  /// In en, this message translates to:
  /// **'Offline On-Device QR Scanner'**
  String get featureOfflineQrScannerTitle;

  /// Feature description for offline QR scanner.
  ///
  /// In en, this message translates to:
  /// **'Built-in offline camera scanner with torch controls, multi-camera toggle, and instant gallery image scanning.'**
  String get featureOfflineQrScannerDesc;

  /// Category name for Privacy, Vault & Security.
  ///
  /// In en, this message translates to:
  /// **'Privacy, Vault & Security'**
  String get featuresCatPrivacy;

  /// Category subtitle for Privacy, Vault & Security.
  ///
  /// In en, this message translates to:
  /// **'Biometric security, PIN lock, and strictly offline architecture'**
  String get featuresCatPrivacySub;

  /// Feature title for PIN & biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometric & App PIN Lock'**
  String get featurePinBiometricsTitle;

  /// Feature description for PIN & biometrics.
  ///
  /// In en, this message translates to:
  /// **'Gate app startup with your fingerprint, face unlock, or a secure 4–6 digit security PIN.'**
  String get featurePinBiometricsDesc;

  /// Feature title for private vault.
  ///
  /// In en, this message translates to:
  /// **'Private Shortcuts Vault'**
  String get featurePrivateVaultTitle;

  /// Feature description for private vault.
  ///
  /// In en, this message translates to:
  /// **'Mark sensitive shortcuts as private. They remain hidden until unlocked with your PIN or biometrics.'**
  String get featurePrivateVaultDesc;

  /// Feature title for strict offline architecture.
  ///
  /// In en, this message translates to:
  /// **'Strict Zero-Network Architecture'**
  String get featureStrictOfflineTitle;

  /// Feature description for strict offline architecture.
  ///
  /// In en, this message translates to:
  /// **'The app contains no INTERNET permission, no cloud SDKs, no analytics, and no telemetry. All data stays strictly on your device.'**
  String get featureStrictOfflineDesc;

  /// Category name for Backup & Portability.
  ///
  /// In en, this message translates to:
  /// **'Local Backup & Data Portability'**
  String get featuresCatBackup;

  /// Category subtitle for Backup & Portability.
  ///
  /// In en, this message translates to:
  /// **'Standard JSON exports, strong encryption, and seamless restore'**
  String get featuresCatBackupSub;

  /// Feature title for local JSON backup.
  ///
  /// In en, this message translates to:
  /// **'Local JSON Backup & Restore'**
  String get featureJsonExportImportTitle;

  /// Feature description for local JSON backup.
  ///
  /// In en, this message translates to:
  /// **'Export your shortcuts to a standardized JSON file using Android Storage Access Framework with zero broad storage permissions.'**
  String get featureJsonExportImportDesc;

  /// Feature title for encrypted backup.
  ///
  /// In en, this message translates to:
  /// **'AES-256 PBKDF2 Password Encryption'**
  String get featureEncryptedBackupTitle;

  /// Feature description for encrypted backup.
  ///
  /// In en, this message translates to:
  /// **'Protect exported backup files with industrial-grade AES-256-GCM encryption and PBKDF2 key derivation.'**
  String get featureEncryptedBackupDesc;

  /// Feature title for merge & replace modes.
  ///
  /// In en, this message translates to:
  /// **'Merge & Replace Restore Modes'**
  String get featureMergeReplaceModesTitle;

  /// Feature description for merge & replace modes.
  ///
  /// In en, this message translates to:
  /// **'Choose between safely merging imported shortcuts with existing ones or performing a clean full restore.'**
  String get featureMergeReplaceModesDesc;

  /// AppBar title of the Help hub screen.
  ///
  /// In en, this message translates to:
  /// **'Help & User Guides'**
  String get helpScreenTitle;

  /// Hero title on the Help hub screen.
  ///
  /// In en, this message translates to:
  /// **'SreerajP YouTube Shortcuts Help'**
  String get helpHeroTitle;

  /// Hero body on the Help hub screen.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to know about creating shortcuts, URL formats, offline QR sharing, and security.'**
  String get helpHeroBody;

  /// Category header for basics on Help screen.
  ///
  /// In en, this message translates to:
  /// **'Basics & Navigation'**
  String get helpCatGettingStarted;

  /// Category header for QR and Backups on Help screen.
  ///
  /// In en, this message translates to:
  /// **'QR Sharing & Backups'**
  String get helpCatAdvancedSharing;

  /// Category header for Privacy and Security on Help screen.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get helpCatPrivacySecurity;

  /// Category header for FAQ on Help screen.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpCatFaq;

  /// Title of the Getting Started help topic card.
  ///
  /// In en, this message translates to:
  /// **'Creating & Managing Shortcuts'**
  String get helpTopicGettingStartedTitle;

  /// Subtitle of the Getting Started help topic card.
  ///
  /// In en, this message translates to:
  /// **'How to add shortcuts, paste links, customize colors/icons, and launch directly.'**
  String get helpTopicGettingStartedSub;

  /// Title of the Handles help topic card.
  ///
  /// In en, this message translates to:
  /// **'Channel Handles & Live Streams'**
  String get helpTopicHandlesTitle;

  /// Subtitle of the Handles help topic card.
  ///
  /// In en, this message translates to:
  /// **'How \'@\' handle shortcuts work, /live stream routing, and fallback behavior.'**
  String get helpTopicHandlesSub;

  /// Title of the QR Sharing help topic card.
  ///
  /// In en, this message translates to:
  /// **'Air-Gapped QR Transfer'**
  String get helpTopicQrSharingTitle;

  /// Subtitle of the QR Sharing help topic card.
  ///
  /// In en, this message translates to:
  /// **'Sharing individual shortcuts and streaming entire backups with animated QR codes.'**
  String get helpTopicQrSharingSub;

  /// Title of the Vault help topic card.
  ///
  /// In en, this message translates to:
  /// **'PIN, Biometrics & Vault'**
  String get helpTopicVaultTitle;

  /// Subtitle of the Vault help topic card.
  ///
  /// In en, this message translates to:
  /// **'Setting up app lock, hiding private shortcuts, and offline security guarantees.'**
  String get helpTopicVaultSub;

  /// Title of the Backup help topic card.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Backup & Migration'**
  String get helpTopicBackupTitle;

  /// Subtitle of the Backup help topic card.
  ///
  /// In en, this message translates to:
  /// **'Exporting JSON backups, password encryption, and moving data to a new device.'**
  String get helpTopicBackupSub;

  /// Title of the FAQ help topic card.
  ///
  /// In en, this message translates to:
  /// **'FAQs & Troubleshooting Guide'**
  String get helpTopicFaqTitle;

  /// Subtitle of the FAQ help topic card.
  ///
  /// In en, this message translates to:
  /// **'Direct answers to common questions about permissions, launch issues, and offline storage.'**
  String get helpTopicFaqSub;

  /// AppBar title for the Getting Started help screen.
  ///
  /// In en, this message translates to:
  /// **'Creating & Managing Shortcuts'**
  String get helpGettingStartedTitle;

  /// Intro text for Getting Started help screen.
  ///
  /// In en, this message translates to:
  /// **'Learn how to create, customize, and organize your favorite YouTube shortcuts for rapid 1-tap launching.'**
  String get helpGettingStartedIntro;

  /// Section header for Adding Shortcuts in help guide.
  ///
  /// In en, this message translates to:
  /// **'Adding Shortcuts'**
  String get helpSecAddingShortcuts;

  /// FAQ question: How to add a shortcut.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new shortcut?'**
  String get helpFaqAddHow;

  /// FAQ answer: How to add a shortcut.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' floating action button on the home screen. Enter a memorable shortcut name, and paste any YouTube link or enter a channel handle. The app automatically cleans and formats the destination URL.'**
  String get helpFaqAddHowAns;

  /// FAQ question: Clipboard detection.
  ///
  /// In en, this message translates to:
  /// **'How does clipboard paste detection work?'**
  String get helpFaqClipboard;

  /// FAQ answer: Clipboard detection.
  ///
  /// In en, this message translates to:
  /// **'When you copy a YouTube link in your browser or YouTube app and open Add Shortcut, the app checks your clipboard locally and presents a 1-tap \'Paste\' button to fill the URL instantly.'**
  String get helpFaqClipboardAns;

  /// Section header for Customizing & Organizing in help guide.
  ///
  /// In en, this message translates to:
  /// **'Customizing & Organizing'**
  String get helpSecCustomizing;

  /// FAQ question: Colors and icons.
  ///
  /// In en, this message translates to:
  /// **'Can I customize card colors and icons?'**
  String get helpFaqColorsIcons;

  /// FAQ answer: Colors and icons.
  ///
  /// In en, this message translates to:
  /// **'Yes! When creating or editing a shortcut, expand the Custom Accent Color and Custom Icon sections to assign distinctive colors and icons (like Star, Play, Music, Gaming, Tech, and more).'**
  String get helpFaqColorsIconsAns;

  /// FAQ question: How tags work.
  ///
  /// In en, this message translates to:
  /// **'How do tags work?'**
  String get helpFaqTags;

  /// FAQ answer: How tags work.
  ///
  /// In en, this message translates to:
  /// **'Add tags like \'#Music\', \'#Tutorial\', or \'#News\' to categorize your shortcuts. You can tap on tags or use the search bar to filter your shortcut library in real time.'**
  String get helpFaqTagsAns;

  /// FAQ question: How to reorder.
  ///
  /// In en, this message translates to:
  /// **'How do I reorder shortcuts on the home screen?'**
  String get helpFaqReorder;

  /// FAQ answer: How to reorder.
  ///
  /// In en, this message translates to:
  /// **'Ensure your sort mode is set to \'Manual order\' (tap the sort icon in the app bar), then choose \'Reorder shortcuts\' from the overflow menu. Long-press and drag cards into your desired position.'**
  String get helpFaqReorderAns;

  /// AppBar title for Handles help screen.
  ///
  /// In en, this message translates to:
  /// **'Channel Handles & Live Streams'**
  String get helpHandlesTitle;

  /// Intro text for Handles help screen.
  ///
  /// In en, this message translates to:
  /// **'Understand how SreerajP YouTube Shortcuts formats channel handles and routes directly to live streams or channels.'**
  String get helpHandlesIntro;

  /// Section header for Handle Syntax in help guide.
  ///
  /// In en, this message translates to:
  /// **'Handle Syntax & Formatting'**
  String get helpSecHandleSyntax;

  /// FAQ question: Handle format.
  ///
  /// In en, this message translates to:
  /// **'What format should I use for handles?'**
  String get helpFaqHandleFormat;

  /// FAQ answer: Handle format.
  ///
  /// In en, this message translates to:
  /// **'You can enter either \'@ChannelHandle\' or simply \'ChannelHandle\'. The app validates the handle shape (3–30 letters, numbers, dots, dashes, underscores) and converts it to https://www.youtube.com/@handle/live.'**
  String get helpFaqHandleFormatAns;

  /// Section header for Live vs Non-Live in help guide.
  ///
  /// In en, this message translates to:
  /// **'Live vs Non-Live Channels'**
  String get helpSecHandleBehavior;

  /// FAQ question: Live routing behavior.
  ///
  /// In en, this message translates to:
  /// **'What happens if the channel is not live?'**
  String get helpFaqLiveRouting;

  /// FAQ answer: Live routing behavior.
  ///
  /// In en, this message translates to:
  /// **'Because the app operates 100% offline, it hands the URL directly to the YouTube app. If the channel is streaming, YouTube loads the stream. If not, YouTube will show scheduled streams, recent videos, or the channel\'s main tab.'**
  String get helpFaqLiveRoutingAns;

  /// FAQ question: Channel homepage link.
  ///
  /// In en, this message translates to:
  /// **'How do I link directly to a channel page instead of /live?'**
  String get helpFaqChannelHome;

  /// FAQ answer: Channel homepage link.
  ///
  /// In en, this message translates to:
  /// **'To open the channel home page rather than the live stream, enter the full URL: https://www.youtube.com/@ChannelHandle.'**
  String get helpFaqChannelHomeAns;

  /// AppBar title for QR Sharing help screen.
  ///
  /// In en, this message translates to:
  /// **'Air-Gapped QR Transfer'**
  String get helpQrSharingTitle;

  /// Intro text for QR Sharing help screen.
  ///
  /// In en, this message translates to:
  /// **'Share shortcuts and migrate your entire collection between devices with zero cables, internet, or cloud servers.'**
  String get helpQrSharingIntro;

  /// Section header for Single QR in help guide.
  ///
  /// In en, this message translates to:
  /// **'Sharing Individual Shortcuts'**
  String get helpSecSingleQr;

  /// FAQ question: Single QR sharing.
  ///
  /// In en, this message translates to:
  /// **'How do I share a single shortcut via QR code?'**
  String get helpFaqShareSingle;

  /// FAQ answer: Single QR sharing.
  ///
  /// In en, this message translates to:
  /// **'Open the shortcut\'s detail screen or long-press on a shortcut card and tap the QR icon. An air-gapped QR code containing the shortcut name and destination URL will appear. Any device can scan it to save or open the link.'**
  String get helpFaqShareSingleAns;

  /// Section header for Bulk QR in help guide.
  ///
  /// In en, this message translates to:
  /// **'Animated Multi-Frame Backup Streaming'**
  String get helpSecBulkQr;

  /// FAQ question: Animated QR backup.
  ///
  /// In en, this message translates to:
  /// **'How does animated QR backup work?'**
  String get helpFaqAnimatedQr;

  /// FAQ answer: Animated QR backup.
  ///
  /// In en, this message translates to:
  /// **'Under Settings → Backup & Restore, tap \'Export via QR code\'. The app chunks your entire shortcut collection and settings into an animated sequence of QR codes. On your new phone, open the Offline QR Scanner and hold the camera steady to assemble the full backup.'**
  String get helpFaqAnimatedQrAns;

  /// FAQ question: Gallery QR scanning.
  ///
  /// In en, this message translates to:
  /// **'Can I scan a QR code from a screenshot or photo?'**
  String get helpFaqGalleryScan;

  /// FAQ answer: Gallery QR scanning.
  ///
  /// In en, this message translates to:
  /// **'Yes! Open the in-app scanner and tap \'Scan Image from Gallery\' to select any screenshot or photo containing a YouTube QR code. The image is processed entirely on-device using local vision ML kit.'**
  String get helpFaqGalleryScanAns;

  /// AppBar title for Vault help screen.
  ///
  /// In en, this message translates to:
  /// **'PIN, Biometrics & Security'**
  String get helpVaultTitle;

  /// Intro text for Vault help screen.
  ///
  /// In en, this message translates to:
  /// **'Configure PIN protection, fingerprint authentication, and keep private shortcuts shielded from prying eyes.'**
  String get helpVaultIntro;

  /// Section header for PIN setup in help guide.
  ///
  /// In en, this message translates to:
  /// **'Security PIN & Biometrics'**
  String get helpSecPinSetup;

  /// FAQ question: How to setup PIN.
  ///
  /// In en, this message translates to:
  /// **'How do I set up a Security PIN?'**
  String get helpFaqPinSetup;

  /// FAQ answer: How to setup PIN.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings → Privacy & Security, tap \'Set PIN\', and enter a 4 to 6 digit security code. Once configured, you can enable App Lock and Private Shortcut Lock.'**
  String get helpFaqPinSetupAns;

  /// FAQ question: Biometric support.
  ///
  /// In en, this message translates to:
  /// **'Does the app support Fingerprint and Face Unlock?'**
  String get helpFaqBiometrics;

  /// FAQ answer: Biometric support.
  ///
  /// In en, this message translates to:
  /// **'Yes. When biometric hardware is available on your Android device, you can tap the fingerprint icon on the lock screen for instant authentication.'**
  String get helpFaqBiometricsAns;

  /// Section header for Private Vault in help guide.
  ///
  /// In en, this message translates to:
  /// **'Private Shortcuts Vault'**
  String get helpSecPrivateVault;

  /// FAQ question: Private shortcuts.
  ///
  /// In en, this message translates to:
  /// **'What does marking a shortcut as \'Private\' do?'**
  String get helpFaqPrivateShortcuts;

  /// FAQ answer: Private shortcuts.
  ///
  /// In en, this message translates to:
  /// **'When \'Lock Private Shortcuts\' is enabled, any shortcut flagged as private is hidden from the main list. You must authenticate to reveal and launch private shortcuts.'**
  String get helpFaqPrivateShortcutsAns;

  /// FAQ question: Cloud upload guarantee.
  ///
  /// In en, this message translates to:
  /// **'Are my shortcuts or PIN ever uploaded to the cloud?'**
  String get helpFaqOfflineGuarantee;

  /// FAQ answer: Cloud upload guarantee.
  ///
  /// In en, this message translates to:
  /// **'Never. SreerajP YouTube Shortcuts does not have the Android INTERNET permission. Your shortcuts, launch history, and cryptographic PIN hashes reside strictly in local on-device encrypted storage.'**
  String get helpFaqOfflineGuaranteeAns;

  /// AppBar title for Backup help screen.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Backup & Migration'**
  String get helpBackupTitle;

  /// Intro text for Backup help screen.
  ///
  /// In en, this message translates to:
  /// **'Learn how to export JSON backups, encrypt them with AES-256, and safely migrate your data to a new device.'**
  String get helpBackupIntro;

  /// Section header for JSON File Backup in help guide.
  ///
  /// In en, this message translates to:
  /// **'JSON File Backup'**
  String get helpSecExportImport;

  /// FAQ question: Exporting to file.
  ///
  /// In en, this message translates to:
  /// **'How do I export my shortcuts to a file?'**
  String get helpFaqExportFile;

  /// FAQ answer: Exporting to file.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Settings → Backup & Restore and tap \'Export to file\'. Android\'s system file picker opens, allowing you to choose any folder (Downloads, USB drive, SD card) to save the backup .json file.'**
  String get helpFaqExportFileAns;

  /// FAQ question: Backup encryption.
  ///
  /// In en, this message translates to:
  /// **'How does backup password encryption work?'**
  String get helpFaqEncryption;

  /// FAQ answer: Backup encryption.
  ///
  /// In en, this message translates to:
  /// **'When exporting, check \'Encrypt backup with password\'. The app uses AES-256-GCM authenticated encryption with a key derived via PBKDF2 (100,000 iterations). Without the password, no one can read the file.'**
  String get helpFaqEncryptionAns;

  /// Section header for Restoring & Merging in help guide.
  ///
  /// In en, this message translates to:
  /// **'Restoring & Merging'**
  String get helpSecRestoreModes;

  /// FAQ question: Merge vs Replace.
  ///
  /// In en, this message translates to:
  /// **'What is the difference between \'Merge\' and \'Replace\'?'**
  String get helpFaqMergeVsReplace;

  /// FAQ answer: Merge vs Replace.
  ///
  /// In en, this message translates to:
  /// **'\'Import & merge\' adds any new shortcuts from the backup file into your existing list while preserving your current shortcuts. \'Import & replace\' clears your existing library first and replaces it with the backup content.'**
  String get helpFaqMergeVsReplaceAns;

  /// AppBar title for FAQs & Troubleshooting screen.
  ///
  /// In en, this message translates to:
  /// **'FAQs & Troubleshooting'**
  String get helpFaqTitle;

  /// Intro text for FAQs & Troubleshooting screen.
  ///
  /// In en, this message translates to:
  /// **'Find fast answers to common questions, permissions, and troubleshooting tips.'**
  String get helpFaqIntro;

  /// Section header for General Questions in FAQ.
  ///
  /// In en, this message translates to:
  /// **'General Questions'**
  String get helpSecGeneralFaq;

  /// FAQ question: Why use this app.
  ///
  /// In en, this message translates to:
  /// **'Why use SreerajP YouTube Shortcuts instead of browser bookmarks?'**
  String get helpFaqWhyApp;

  /// FAQ answer: Why use this app.
  ///
  /// In en, this message translates to:
  /// **'Browser bookmarks open in mobile browsers where playback is often limited. SreerajP YouTube Shortcuts launches directly into the native YouTube app with custom tags, colors, offline QR sharing, privacy lock, and zero tracking.'**
  String get helpFaqWhyAppAns;

  /// FAQ question: Does app connect to internet.
  ///
  /// In en, this message translates to:
  /// **'Does this app connect to the internet?'**
  String get helpFaqInternet;

  /// FAQ answer: Does app connect to internet.
  ///
  /// In en, this message translates to:
  /// **'No. The app does not request or possess the Android INTERNET permission. It runs entirely on your device with 100% offline privacy and zero telemetry.'**
  String get helpFaqInternetAns;

  /// Section header for Troubleshooting in FAQ.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting & Permissions'**
  String get helpSecTroubleshooting;

  /// FAQ question: YouTube app launch error.
  ///
  /// In en, this message translates to:
  /// **'Why does tapping a shortcut say \'The YouTube app could not be opened\'?'**
  String get helpFaqLaunchError;

  /// FAQ answer: YouTube app launch error.
  ///
  /// In en, this message translates to:
  /// **'Ensure the official YouTube app is installed, updated, and enabled in your Android system app settings. If YouTube is disabled or restricted, enable it in Android Settings → Apps → YouTube.'**
  String get helpFaqLaunchErrorAns;

  /// FAQ question: Camera permission explanation.
  ///
  /// In en, this message translates to:
  /// **'Why does the QR Scanner request Camera permission?'**
  String get helpFaqCameraPermission;

  /// FAQ answer: Camera permission explanation.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is used exclusively for scanning QR codes locally using on-device vision processing. Camera feeds never leave your device and camera access is only active while the scanner screen is open.'**
  String get helpFaqCameraPermissionAns;

  /// FAQ question: Forgot PIN.
  ///
  /// In en, this message translates to:
  /// **'What should I do if I forget my Security PIN?'**
  String get helpFaqForgotPin;

  /// FAQ answer: Forgot PIN.
  ///
  /// In en, this message translates to:
  /// **'Because all cryptographic keys and hashes reside purely on-device with zero cloud backdoor, a forgotten PIN cannot be reset remotely. You can authenticate via Biometrics if enabled, or clear app storage in Android Settings.'**
  String get helpFaqForgotPinAns;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

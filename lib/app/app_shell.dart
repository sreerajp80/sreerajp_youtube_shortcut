import 'package:flutter/material.dart';
import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/app/theme/app_theme.dart';
import 'package:sreerajp_youtube_shortcut/core/config/app_config.dart';
import 'package:sreerajp_youtube_shortcut/state/privacy_lock_store.dart';
import 'package:sreerajp_youtube_shortcut/screens/fatal_error_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/home_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/privacy_lock_screen.dart';
import 'package:sreerajp_youtube_shortcut/services/share_intent_service.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';

class ShortcutApp extends StatelessWidget {
  const ShortcutApp({
    super.key,
    required this.store,
    this.privacyLockStore,
    this.appConfig = AppConfig.fallback,
    this.aboutInfo = const AboutInfo(
      author: 'SreerajP',
      version: '1.3.15',
      buildNumber: '1',
      buildDate: '2026-08-09',
      aiUsed: 'Google Gemini',
    ),
    this.sharedTextSource = const NoOpSharedTextSource(),
  });

  final ShortcutStore store;
  final PrivacyLockStore? privacyLockStore;
  final AppConfig appConfig;
  final AboutInfo aboutInfo;
  final SharedTextSource sharedTextSource;

  @override
  Widget build(BuildContext context) {
    final PrivacyLockStore lockStore =
        privacyLockStore ?? PrivacyLockStore(repository: store.repository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ShortcutStore>.value(value: store),
        ChangeNotifierProvider<PrivacyLockStore>.value(value: lockStore),
        Provider<AppConfig>.value(value: appConfig),
        Provider<AboutInfo>.value(value: aboutInfo),
        Provider<SharedTextSource>.value(value: sharedTextSource),
      ],
      child: Consumer<ShortcutStore>(
        builder: (BuildContext context, ShortcutStore store, Widget? child) {
          final ThemeData lightTheme = AppTheme.forPreference(
            store.themePreference,
            Brightness.light,
          );
          final ThemeData darkTheme = AppTheme.forPreference(
            store.themePreference,
            Brightness.dark,
          );

          return MaterialApp(
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: store.themePreference.themeMode,
            home: const _PrivacyLockGate(child: HomeScreen()),
          );
        },
      ),
    );
  }
}

class FatalApp extends StatelessWidget {
  const FatalApp({super.key, this.details});

  /// Optional extra detail. When null, a generic message is shown.
  final String? details;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FatalErrorScreen(details: details),
    );
  }
}

class _PrivacyLockGate extends StatefulWidget {
  const _PrivacyLockGate({required this.child});

  final Widget child;

  @override
  State<_PrivacyLockGate> createState() => _PrivacyLockGateState();
}

class _PrivacyLockGateState extends State<_PrivacyLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<PrivacyLockStore>().handleAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final PrivacyLockStore lockStore = context.watch<PrivacyLockStore>();
    if (lockStore.isAppLocked) {
      return const PrivacyLockScreen();
    }
    return widget.child;
  }
}

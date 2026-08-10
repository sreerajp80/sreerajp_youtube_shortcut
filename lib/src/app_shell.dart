import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import 'privacy_lock_store.dart';
import 'screens/fatal_error_screen.dart';
import 'screens/home_screen.dart';
import 'screens/privacy_lock_screen.dart';
import 'share_intent_service.dart';
import 'shortcut_models.dart';
import 'shortcut_store.dart';

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
          final ThemeData lightTheme = _buildThemeForPreference(
            store.themePreference,
            Brightness.light,
          );
          final ThemeData darkTheme = _buildThemeForPreference(
            store.themePreference,
            Brightness.dark,
          );

          return MaterialApp(
            title: appConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: store.themePreference.themeMode,
            home: const _PrivacyLockGate(child: HomeScreen()),
          );
        },
      ),
    );
  }

  ThemeData _buildThemeForPreference(
    AppThemePreference preference,
    Brightness systemBrightness,
  ) {
    switch (preference) {
      case AppThemePreference.system:
        return _buildTheme(
          brightness: systemBrightness,
          seedColor: const Color(0xFFD73A23),
          scaffoldColor: systemBrightness == Brightness.dark
              ? const Color(0xFF0A0E10)
              : const Color(0xFFFFF8F3),
          cardColor: systemBrightness == Brightness.dark
              ? const Color(0xFF12181A)
              : Colors.white,
          cardBorderColor: systemBrightness == Brightness.dark
              ? const Color(0xFF1F2A2E)
              : const Color(0xFFF1DED3),
          inputFillColor: systemBrightness == Brightness.dark
              ? const Color(0xFF161D20)
              : Colors.white,
          inputBorderColor: systemBrightness == Brightness.dark
              ? const Color(0xFF253238)
              : const Color(0xFFE4D4CB),
          focusedBorderColor: systemBrightness == Brightness.dark
              ? const Color(0xFF2DD4BF)
              : const Color(0xFFD73A23),
        );

      case AppThemePreference.light:
        return _buildTheme(
          brightness: Brightness.light,
          seedColor: const Color(0xFFD73A23),
          scaffoldColor: const Color(0xFFFFF8F3),
          cardColor: Colors.white,
          cardBorderColor: const Color(0xFFF1DED3),
          inputFillColor: Colors.white,
          inputBorderColor: const Color(0xFFE4D4CB),
          focusedBorderColor: const Color(0xFFD73A23),
        );

      case AppThemePreference.dark:
        return _buildTheme(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFD73A23),
          scaffoldColor: const Color(0xFF0A0E10),
          cardColor: const Color(0xFF12181A),
          cardBorderColor: const Color(0xFF1F2A2E),
          inputFillColor: const Color(0xFF161D20),
          inputBorderColor: const Color(0xFF253238),
          focusedBorderColor: const Color(0xFF2DD4BF),
        );

      case AppThemePreference.amoled:
        return _buildTheme(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFFF3B30),
          scaffoldColor: const Color(0xFF000000),
          cardColor: const Color(0xFF080808),
          cardBorderColor: const Color(0xFF222222),
          inputFillColor: const Color(0xFF121212),
          inputBorderColor: const Color(0xFF2C2C2E),
          focusedBorderColor: const Color(0xFFFF3B30),
        );

      case AppThemePreference.warmSepia:
        return _buildTheme(
          brightness: Brightness.light,
          seedColor: const Color(0xFF8C4327),
          scaffoldColor: const Color(0xFFFBF0D9),
          cardColor: const Color(0xFFFFF8EB),
          cardBorderColor: const Color(0xFFE6D7BD),
          inputFillColor: const Color(0xFFFFF3DF),
          inputBorderColor: const Color(0xFFDFCFB3),
          focusedBorderColor: const Color(0xFF8C4327),
          bodyTextColor: const Color(0xFF3A2417),
        );

      case AppThemePreference.forestDark:
        return _buildTheme(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF10B981),
          scaffoldColor: const Color(0xFF0B1A15),
          cardColor: const Color(0xFF12241E),
          cardBorderColor: const Color(0xFF1E3A30),
          inputFillColor: const Color(0xFF162D26),
          inputBorderColor: const Color(0xFF24493D),
          focusedBorderColor: const Color(0xFF10B981),
          bodyTextColor: const Color(0xFFE2F4EE),
        );

      case AppThemePreference.cyberpunkNeon:
        return _buildTheme(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF00E5FF),
          scaffoldColor: const Color(0xFF0A0915),
          cardColor: const Color(0xFF131126),
          cardBorderColor: const Color(0xFF2A244D),
          inputFillColor: const Color(0xFF1A1733),
          inputBorderColor: const Color(0xFF393166),
          focusedBorderColor: const Color(0xFF00E5FF),
          bodyTextColor: const Color(0xFFF0EEFF),
        );
    }
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color seedColor,
    required Color scaffoldColor,
    required Color cardColor,
    required Color cardBorderColor,
    required Color inputFillColor,
    required Color inputBorderColor,
    required Color focusedBorderColor,
    Color? bodyTextColor,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final Color resolvedBodyColor = bodyTextColor ??
        (isDark ? const Color(0xFFF6ECE6) : const Color(0xFF23130E));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
          .apply(
            bodyColor: resolvedBodyColor,
            displayColor: resolvedBodyColor,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: cardBorderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}

extension on AppThemePreference {
  ThemeMode get themeMode {
    switch (this) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
      case AppThemePreference.warmSepia:
        return ThemeMode.light;
      case AppThemePreference.dark:
      case AppThemePreference.amoled:
      case AppThemePreference.forestDark:
      case AppThemePreference.cyberpunkNeon:
        return ThemeMode.dark;
    }
  }
}

class FatalApp extends StatelessWidget {
  const FatalApp({super.key, required this.details});

  final String details;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      return const PrivacyLockScreen(title: 'YT Shortcuts Locked');
    }
    return widget.child;
  }
}

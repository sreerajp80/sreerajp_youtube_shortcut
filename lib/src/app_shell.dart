import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import 'screens/fatal_error_screen.dart';

import 'screens/home_screen.dart';
import 'share_intent_service.dart';
import 'shortcut_models.dart';
import 'shortcut_store.dart';

class ShortcutApp extends StatelessWidget {
  const ShortcutApp({
    super.key,
    required this.store,
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
  final AppConfig appConfig;
  final AboutInfo aboutInfo;
  final SharedTextSource sharedTextSource;

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = _buildTheme(Brightness.light);
    final ThemeData darkTheme = _buildTheme(Brightness.dark);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ShortcutStore>.value(value: store),
        Provider<AppConfig>.value(value: appConfig),
        Provider<AboutInfo>.value(value: aboutInfo),
        Provider<SharedTextSource>.value(value: sharedTextSource),
      ],
      child: Consumer<ShortcutStore>(
        builder: (BuildContext context, ShortcutStore store, Widget? child) {
          return MaterialApp(
            title: appConfig.appName,

            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: store.themePreference.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFD73A23),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0A0E10)
          : const Color(0xFFFFF8F3),
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
          .apply(
            bodyColor: isDark
                ? const Color(0xFFF6ECE6)
                : const Color(0xFF23130E),
            displayColor: isDark
                ? const Color(0xFFF6ECE6)
                : const Color(0xFF23130E),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF12181A) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? const Color(0xFF1F2A2E) : const Color(0xFFF1DED3),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF161D20) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF253238) : const Color(0xFFE4D4CB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF253238) : const Color(0xFFE4D4CB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2DD4BF) : colorScheme.primary,
            width: 1.5,
          ),
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
        return ThemeMode.light;
      case AppThemePreference.dark:
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

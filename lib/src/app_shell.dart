import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'about_constants.dart';
import 'screens/fatal_error_screen.dart';
import 'screens/home_screen.dart';
import 'shortcut_models.dart';
import 'shortcut_store.dart';

class ShortcutApp extends StatelessWidget {
  const ShortcutApp({super.key, required this.store, required this.aboutInfo});

  final ShortcutStore store;
  final AboutInfo aboutInfo;

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = _buildTheme(Brightness.light);
    final ThemeData darkTheme = _buildTheme(Brightness.dark);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ShortcutStore>.value(value: store),
        Provider<AboutInfo>.value(value: aboutInfo),
      ],
      child: Consumer<ShortcutStore>(
        builder: (BuildContext context, ShortcutStore store, Widget? child) {
          return MaterialApp(
            title: AboutConstants.appTitle,
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
          ? const Color(0xFF16110F)
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
        color: isDark ? const Color(0xFF251D19) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? const Color(0xFF3B2E28) : const Color(0xFFF1DED3),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A211D) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF4B3A33) : const Color(0xFFE4D4CB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF4B3A33) : const Color(0xFFE4D4CB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
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

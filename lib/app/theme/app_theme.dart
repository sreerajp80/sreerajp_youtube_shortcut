import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';

/// Builds the [ThemeData] for each [AppThemePreference].
///
/// This is the single source of truth for app colors and component styling.
/// Widgets read colors from `Theme.of(context)`, never from this class directly.
class AppTheme {
  const AppTheme._();

  /// Builds the theme for [preference], using [systemBrightness] only when the
  /// preference is [AppThemePreference.system].
  static ThemeData forPreference(
    AppThemePreference preference,
    Brightness systemBrightness,
  ) {
    switch (preference) {
      case AppThemePreference.system:
        return _build(
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
        return _build(
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
        return _build(
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
        return _build(
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
        return _build(
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
        return _build(
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
        return _build(
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

  static ThemeData _build({
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

    final Color resolvedBodyColor =
        bodyTextColor ??
        (isDark ? const Color(0xFFF6ECE6) : const Color(0xFF23130E));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
          .apply(bodyColor: resolvedBodyColor, displayColor: resolvedBodyColor),
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

/// Maps a stored theme preference onto the Flutter [ThemeMode] it implies.
extension AppThemePreferenceMode on AppThemePreference {
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

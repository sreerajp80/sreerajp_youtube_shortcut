import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';

/// Localized display names for the app's preference and target-type enums.
///
/// The enums themselves stay free of UI copy — a model must not decide what the
/// user reads. Screens call `value.label(l10n)` to get the text to show.

extension AppLayoutPreferenceLabel on AppLayoutPreference {
  String label(AppLocalizations l10n) {
    switch (this) {
      case AppLayoutPreference.grid:
        return l10n.layoutGrid;
      case AppLayoutPreference.list:
        return l10n.layoutList;
    }
  }
}

extension AppThemePreferenceLabel on AppThemePreference {
  String label(AppLocalizations l10n) {
    switch (this) {
      case AppThemePreference.system:
        return l10n.themeSystem;
      case AppThemePreference.light:
        return l10n.themeLight;
      case AppThemePreference.dark:
        return l10n.themeDark;
      case AppThemePreference.amoled:
        return l10n.themeAmoled;
      case AppThemePreference.warmSepia:
        return l10n.themeWarmSepia;
      case AppThemePreference.forestDark:
        return l10n.themeForestDark;
      case AppThemePreference.cyberpunkNeon:
        return l10n.themeCyberpunkNeon;
    }
  }
}

extension ShortcutSortPreferenceLabel on ShortcutSortPreference {
  String label(AppLocalizations l10n) {
    switch (this) {
      case ShortcutSortPreference.manual:
        return l10n.sortManual;
      case ShortcutSortPreference.alphabetical:
        return l10n.sortAlphabetical;
      case ShortcutSortPreference.newest:
        return l10n.sortNewest;
      case ShortcutSortPreference.recent:
        return l10n.sortRecent;
      case ShortcutSortPreference.mostUsed:
        return l10n.sortMostUsed;
    }
  }
}

extension ShortcutTargetTypeLabel on ShortcutTargetType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case ShortcutTargetType.video:
        return l10n.targetTypeVideo;
      case ShortcutTargetType.shortVideo:
        return l10n.targetTypeShorts;
      case ShortcutTargetType.playlist:
        return l10n.targetTypePlaylist;
      case ShortcutTargetType.channel:
        return l10n.targetTypeChannel;
    }
  }
}

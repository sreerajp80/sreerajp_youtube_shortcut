import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/l10n/error_messages.dart';
import 'package:sreerajp_youtube_shortcut/l10n/model_labels.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';

/// Appearance screen for selecting themes and visual preferences.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ShortcutStore store = context.watch<ShortcutStore>();
    final AppThemePreference selectedPreference = store.themePreference;
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          _buildHeroHeader(context, theme, l10n),
          const SizedBox(height: 20),
          _buildSectionHeader(theme, l10n),
          const SizedBox(height: 12),
          ...AppThemePreference.values.map((AppThemePreference pref) {
            final bool isSelected = pref == selectedPreference;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ThemePreferenceCard(
                preference: pref,
                isSelected: isSelected,
                swatches: _themeSwatchesFor(pref),
                onTap: () => _setThemePreference(context, pref),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: <Color>[
              primaryColor.withValues(alpha: 0.14),
              secondaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.palette_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.appearanceHeroTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appearanceHeroBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.color_lens_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.appearanceThemeSectionTitle.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.appearanceThemeSectionSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static List<Color> _themeSwatchesFor(AppThemePreference preference) {
    switch (preference) {
      case AppThemePreference.system:
        return const <Color>[Color(0xFF888888), Color(0xFFD73A23)];
      case AppThemePreference.light:
        return const <Color>[Color(0xFFFFF8F3), Color(0xFFD73A23)];
      case AppThemePreference.dark:
        return const <Color>[Color(0xFF0A0E10), Color(0xFF2DD4BF)];
      case AppThemePreference.amoled:
        return const <Color>[Color(0xFF000000), Color(0xFFFF3B30)];
      case AppThemePreference.warmSepia:
        return const <Color>[Color(0xFFFBF0D9), Color(0xFF8C4327)];
      case AppThemePreference.forestDark:
        return const <Color>[Color(0xFF0B1A15), Color(0xFF10B981)];
      case AppThemePreference.cyberpunkNeon:
        return const <Color>[Color(0xFF0A0915), Color(0xFF00E5FF)];
    }
  }

  Future<void> _setThemePreference(
    BuildContext context,
    AppThemePreference preference,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      await context.read<ShortcutStore>().setThemePreference(preference);
    } on ShortcutStorageException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.localized(l10n))));
    }
  }
}

class _ThemePreferenceCard extends StatelessWidget {
  const _ThemePreferenceCard({
    required this.preference,
    required this.isSelected,
    required this.swatches,
    required this.onTap,
  });

  final AppThemePreference preference;
  final bool isSelected;
  final List<Color> swatches;
  final VoidCallback onTap;

  String _descriptionFor(AppLocalizations l10n) {
    switch (preference) {
      case AppThemePreference.system:
        return l10n.themeDescSystem;
      case AppThemePreference.light:
        return l10n.themeDescLight;
      case AppThemePreference.dark:
        return l10n.themeDescDark;
      case AppThemePreference.amoled:
        return l10n.themeDescAmoled;
      case AppThemePreference.warmSepia:
        return l10n.themeDescWarmSepia;
      case AppThemePreference.forestDark:
        return l10n.themeDescForestDark;
      case AppThemePreference.cyberpunkNeon:
        return l10n.themeDescCyberpunkNeon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color primaryColor = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? primaryColor : theme.colorScheme.outlineVariant,
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : theme.cardTheme.color,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.18)
                      : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: swatches.map((Color c) {
                      return Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26, width: 0.5),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      preference.label(l10n),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? primaryColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _descriptionFor(l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected
                    ? primaryColor
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

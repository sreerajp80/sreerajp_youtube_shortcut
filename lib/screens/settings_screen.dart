import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/l10n/error_messages.dart';
import 'package:sreerajp_youtube_shortcut/l10n/model_labels.dart';
import 'package:sreerajp_youtube_shortcut/state/privacy_lock_store.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';
import 'package:sreerajp_youtube_shortcut/screens/about_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/backup_restore_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/permissions_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/shortcut_behavior_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ShortcutStore store = context.watch<ShortcutStore>();
    final AppThemePreference selectedPreference = store.themePreference;
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                l10n.settingsIntro,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.settingsAppearanceSection,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.settingsThemeSelection,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppThemePreference.values.map((
                      AppThemePreference pref,
                    ) {
                      final bool isSelected = pref == selectedPreference;
                      final List<Color> swatches = _themeSwatchesFor(pref);

                      return InkWell(
                        onTap: () => _setThemePreference(context, pref),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer.withValues(
                                    alpha: 0.4,
                                  )
                                : theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                children: swatches.map((Color c) {
                                  return Container(
                                    width: 14,
                                    height: 14,
                                    margin: const EdgeInsets.only(right: 3),
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 0.5,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                pref.label(l10n),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              if (isSelected) ...<Widget>[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _themePreferenceDescription(l10n, selectedPreference),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: l10n.settingsAboutTitle,
            subtitle: l10n.settingsAboutSubtitle,
            onTap: () => _openAbout(context),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.verified_user_outlined,
            title: l10n.settingsPermissionsTitle,
            subtitle: l10n.settingsPermissionsSubtitle,
            onTap: () => _openPermissions(context),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.alternate_email_rounded,
            title: l10n.settingsHandlesTitle,
            subtitle: l10n.settingsHandlesSubtitle,
            onTap: () => _openShortcutBehavior(context),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.import_export_rounded,
            title: l10n.settingsBackupTitle,
            subtitle: l10n.settingsBackupSubtitle,
            onTap: () => _openBackupRestore(context),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.settingsPrivacySection,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _PrivacySecurityCard(),
        ],
      ),
    );
  }

  String _themePreferenceDescription(
    AppLocalizations l10n,
    AppThemePreference preference,
  ) {
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

  List<Color> _themeSwatchesFor(AppThemePreference preference) {
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

  Future<void> _openAbout(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AboutScreen(),
      ),
    );
  }

  Future<void> _openPermissions(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PermissionsScreen(),
      ),
    );
  }

  Future<void> _openShortcutBehavior(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ShortcutBehaviorScreen(),
      ),
    );
  }

  Future<void> _openBackupRestore(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const BackupRestoreScreen(),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color iconBackground = isDark
        ? const Color(0xFF2DD4BF).withValues(alpha: 0.18)
        : theme.colorScheme.secondaryContainer;
    final Color iconColor = isDark
        ? const Color(0xFF2DD4BF)
        : theme.colorScheme.onSecondaryContainer;
    final Color iconBorder = isDark
        ? const Color(0xFF2DD4BF).withValues(alpha: 0.45)
        : Colors.transparent;

    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: iconBorder),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _PrivacySecurityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PrivacyLockStore lockStore = context.watch<PrivacyLockStore>();
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.pin),
              title: Text(
                lockStore.hasPinConfigured
                    ? l10n.pinChangeTitle
                    : l10n.pinSetTitle,
              ),
              subtitle: Text(
                lockStore.hasPinConfigured
                    ? l10n.pinConfiguredSubtitle
                    : l10n.pinNotConfiguredSubtitle,
              ),
              trailing: TextButton(
                onPressed: () => _showPinSetupDialog(context),
                child: Text(
                  lockStore.hasPinConfigured
                      ? l10n.pinChangeAction
                      : l10n.pinSetAction,
                ),
              ),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.appLockTitle),
              subtitle: Text(l10n.appLockSubtitle),
              value: lockStore.appLockEnabled,
              onChanged: lockStore.hasPinConfigured
                  ? (bool enabled) => lockStore.setAppLockEnabled(enabled)
                  : null,
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.privateLockTitle),
              subtitle: Text(l10n.privateLockSubtitle),
              value: lockStore.privateLockEnabled,
              onChanged: lockStore.hasPinConfigured
                  ? (bool enabled) => lockStore.setPrivateLockEnabled(enabled)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPinSetupDialog(BuildContext context) async {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    final PrivacyLockStore lockStore = context.read<PrivacyLockStore>();
    final AppLocalizations l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            lockStore.hasPinConfigured ? l10n.pinChangeTitle : l10n.pinSetTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: InputDecoration(labelText: l10n.pinEnterLabel),
              ),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: InputDecoration(labelText: l10n.pinConfirmLabel),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () async {
                final String pin = pinController.text.trim();
                final String confirm = confirmController.text.trim();
                if (pin.length < 4 || pin != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pinMismatchError)),
                  );
                  return;
                }
                final bool success = await lockStore.setupPin(pin);
                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? l10n.pinSavedMessage
                            : l10n.pinSaveFailedMessage,
                      ),
                    ),
                  );
                }
              },
              child: Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }
}

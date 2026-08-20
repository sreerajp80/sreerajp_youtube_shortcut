import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/state/privacy_lock_store.dart';
import 'package:sreerajp_youtube_shortcut/screens/about_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/appearance_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/backup_restore_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/features_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/help/help_home_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/permissions_screen.dart';
import 'package:sreerajp_youtube_shortcut/screens/shortcut_behavior_screen.dart';

/// Main settings hub for SreerajP YouTube Shortcuts.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          _SettingsCard(
            icon: Icons.palette_outlined,
            title: l10n.settingsAppearanceTitle,
            subtitle: l10n.settingsAppearanceSubtitle,
            onTap: () => _push(context, const AppearanceScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.stars_outlined,
            title: l10n.settingsFeaturesTitle,
            subtitle: l10n.settingsFeaturesSubtitle,
            onTap: () => _push(context, const FeaturesScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.alternate_email_rounded,
            title: l10n.settingsHandlesTitle,
            subtitle: l10n.settingsHandlesSubtitle,
            onTap: () => _push(context, const ShortcutBehaviorScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.import_export_rounded,
            title: l10n.settingsBackupTitle,
            subtitle: l10n.settingsBackupSubtitle,
            onTap: () => _push(context, const BackupRestoreScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.shield_outlined,
            title: l10n.settingsPermissionsTitle,
            subtitle: l10n.settingsPermissionsSubtitle,
            onTap: () => _push(context, const PermissionsScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.help_outline_rounded,
            title: l10n.settingsHelpTitle,
            subtitle: l10n.settingsHelpSubtitle,
            onTap: () => _push(context, const HelpHomeScreen()),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            icon: Icons.info_outline_rounded,
            title: l10n.settingsAboutTitle,
            subtitle: l10n.settingsAboutSubtitle,
            onTap: () => _push(context, const AboutScreen()),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.settingsPrivacySection.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _PrivacySecurityCard(),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
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
    final Color accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacySecurityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PrivacyLockStore lockStore = context.watch<PrivacyLockStore>();
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.pin, color: theme.colorScheme.primary),
              ),
              title: Text(
                lockStore.hasPinConfigured
                    ? l10n.pinChangeTitle
                    : l10n.pinSetTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                lockStore.hasPinConfigured
                    ? l10n.pinConfiguredSubtitle
                    : l10n.pinNotConfiguredSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: FilledButton.tonal(
                onPressed: () => _showPinSetupDialog(context),
                child: Text(
                  lockStore.hasPinConfigured
                      ? l10n.pinChangeAction
                      : l10n.pinSetAction,
                ),
              ),
            ),
            Divider(
              height: 24,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.appLockTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                l10n.appLockSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: lockStore.appLockEnabled,
              onChanged: lockStore.hasPinConfigured
                  ? (bool enabled) => lockStore.setAppLockEnabled(enabled)
                  : null,
            ),
            Divider(
              height: 24,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.privateLockTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                l10n.privateLockSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
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

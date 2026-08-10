import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../privacy_lock_store.dart';
import '../shortcut_models.dart';
import '../shortcut_store.dart';
import 'about_screen.dart';
import 'backup_restore_screen.dart';
import 'permissions_screen.dart';
import 'shortcut_behavior_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ShortcutStore store = context.watch<ShortcutStore>();
    final AppThemePreference selectedPreference = store.themePreference;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Manage app appearance, information, and Android manifest permissions.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Appearance',
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
                    'Theme Selection',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppThemePreference.values.map((AppThemePreference pref) {
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
                                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
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
                                pref.label,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
                    _themePreferenceDescription(selectedPreference),
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
            title: 'About',
            subtitle: 'App details, version, build metadata, and notes.',
            onTap: () => _openAbout(context),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.verified_user_outlined,
            title: 'Permissions',
            subtitle:
                'Explicit and implicit permission-related manifest declarations.',
            onTap: () => _openPermissions(context),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.alternate_email_rounded,
            title: 'Channel handles',
            subtitle: "How '@' shortcuts route to live streams.",
            onTap: () => _openShortcutBehavior(context),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.import_export_rounded,
            title: 'Backup & Restore',
            subtitle:
                'Export shortcuts to a JSON file you control, or import a previous backup.',
            onTap: () => _openBackupRestore(context),
          ),
          const SizedBox(height: 18),
          Text(
            'Privacy & Security',
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

  String _themePreferenceDescription(AppThemePreference preference) {
    switch (preference) {
      case AppThemePreference.system:
        return 'Follow your phone system settings.';
      case AppThemePreference.light:
        return 'Clean bright background with warm crimson accents.';
      case AppThemePreference.dark:
        return 'Classic dark mode with slate background and teal highlights.';
      case AppThemePreference.amoled:
        return 'Pure pitch black (#000000) for OLED displays and maximum power savings.';
      case AppThemePreference.warmSepia:
        return 'Cozy parchment cream tones with rich terracotta primary.';
      case AppThemePreference.forestDark:
        return 'Deep pine background with vibrant emerald and mint accents.';
      case AppThemePreference.cyberpunkNeon:
        return 'Futuristic dark synth palette with glowing cyan and neon magenta.';
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
    try {
      await context.read<ShortcutStore>().setThemePreference(preference);
    } on ShortcutStorageException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.pin),
              title: Text(
                lockStore.hasPinConfigured ? 'Change Security PIN' : 'Set Security PIN',
              ),
              subtitle: Text(
                lockStore.hasPinConfigured
                    ? '4–6 digit PIN configured'
                    : 'Set a PIN to enable app and private shortcut lock',
              ),
              trailing: TextButton(
                onPressed: () => _showPinSetupDialog(context),
                child: Text(lockStore.hasPinConfigured ? 'Change' : 'Set PIN'),
              ),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('App Lock'),
              subtitle: const Text('Require PIN or biometrics when launching the app'),
              value: lockStore.appLockEnabled,
              onChanged: lockStore.hasPinConfigured
                  ? (bool enabled) => lockStore.setAppLockEnabled(enabled)
                  : null,
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Lock Private Shortcuts'),
              subtitle: const Text('Gate access to shortcuts marked as private'),
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

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            lockStore.hasPinConfigured ? 'Change Security PIN' : 'Set Security PIN',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Enter 4–6 digit PIN'),
              ),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Confirm PIN'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final String pin = pinController.text.trim();
                final String confirm = confirmController.text.trim();
                if (pin.length < 4 || pin != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PINs do not match or are too short (min 4 digits).'),
                    ),
                  );
                  return;
                }
                final bool success = await lockStore.setupPin(pin);
                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Security PIN saved.' : 'Failed to set PIN.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
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
    final bool isDark = theme.brightness == Brightness.dark;
    final ShortcutStore store = context.watch<ShortcutStore>();
    final AppThemePreference selectedPreference = store.themePreference;
    const Color darkAccent = Color(0xFF2DD4BF);
    final ButtonStyle? segmentStyle = isDark
        ? ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return darkAccent.withValues(alpha: 0.20);
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return darkAccent;
              }
              return theme.colorScheme.onSurface;
            }),
            side: WidgetStateProperty.all<BorderSide>(
              BorderSide(color: darkAccent.withValues(alpha: 0.45)),
            ),
          )
        : null;

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
                  SegmentedButton<AppThemePreference>(
                    style: segmentStyle,
                    segments: AppThemePreference.values
                        .map(
                          (AppThemePreference preference) =>
                              ButtonSegment<AppThemePreference>(
                                value: preference,
                                label: Text(preference.label),
                              ),
                        )
                        .toList(growable: false),
                    selected: <AppThemePreference>{selectedPreference},
                    showSelectedIcon: false,
                    onSelectionChanged: (Set<AppThemePreference> selection) {
                      if (selection.isEmpty) {
                        return;
                      }
                      _setThemePreference(context, selection.first);
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _themePreferenceDescription(selectedPreference),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
        ],
      ),
    );
  }

  String _themePreferenceDescription(AppThemePreference preference) {
    switch (preference) {
      case AppThemePreference.system:
        return 'Follow your phone setting.';
      case AppThemePreference.light:
        return 'Always use the light palette.';
      case AppThemePreference.dark:
        return 'Always use the dark palette.';
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

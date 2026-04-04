import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shortcut_models.dart';
import '../shortcut_store.dart';
import 'about_screen.dart';
import 'permissions_screen.dart';

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
                  SegmentedButton<AppThemePreference>(
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

    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
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

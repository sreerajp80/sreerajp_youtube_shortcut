import 'package:flutter/material.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  static const List<_PermissionEntry> _explicitPermissions = <_PermissionEntry>[
    _PermissionEntry(
      title: 'None',
      scope: 'Release app on Android phones',
      details:
          'The released app declares no Android <uses-permission> entries and requests no runtime permissions.',
    ),
  ];

  static const List<_PermissionEntry> _implicitPermissions = <_PermissionEntry>[
    _PermissionEntry(
      title: 'Launcher visibility',
      scope: 'MainActivity exported with MAIN/LAUNCHER intent filter',
      details:
          'Lets Android show and start the app from the launcher. This does not request user permission.',
    ),
    _PermissionEntry(
      title: 'Package visibility query',
      scope: '<queries> for PROCESS_TEXT (text/plain)',
      details:
          'Declares app-lookup capability for matching text processors. This is a manifest declaration, not a runtime permission.',
    ),
    _PermissionEntry(
      title: 'Share-target intent filter',
      scope: 'MainActivity ACTION_SEND with text/plain',
      details:
          'Lets the app appear in the Android share sheet so a YouTube link shared from another app can pre-fill the Add Shortcut form. Only the shared text is read; no internet, storage, or runtime permission is requested.',
    ),
    _PermissionEntry(
      title: 'Clipboard read on Add Shortcut screen',
      scope: 'Clipboard.getData(text/plain) when opening the Add Shortcut form',
      details:
          'When the Add Shortcut screen opens for a new shortcut, the app reads the system clipboard once to offer a one-tap paste if it contains a YouTube link. The suggestion is dismissable and never sent off-device. No manifest permission is required, but Android 12 and newer show a brief system message when an app reads the clipboard.',
    ),
    _PermissionEntry(
      title: 'Backup & Restore via system file picker',
      scope:
          'ACTION_CREATE_DOCUMENT and ACTION_OPEN_DOCUMENT (Storage Access Framework)',
      details:
          'When you export or import a shortcut backup from Settings, the app launches the Android system file picker. You pick the destination or source file yourself, and Android grants the app one-time access to that single file. No storage permission is requested in the manifest, the app cannot browse other files, and no data leaves the device.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Permission prompts on Android',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'None. This app does not request runtime permission prompts.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Explicit Permissions'),
          const SizedBox(height: 10),
          ..._explicitPermissions.map(
            (_PermissionEntry entry) => _buildPermissionCard(context, entry),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Implicit Permissions / Declarations'),
          const SizedBox(height: 10),
          ..._implicitPermissions.map(
            (_PermissionEntry entry) => _buildPermissionCard(context, entry),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(BuildContext context, _PermissionEntry entry) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                entry.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.scope,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.details,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _PermissionEntry {
  const _PermissionEntry({
    required this.title,
    required this.scope,
    required this.details,
  });

  final String title;
  final String scope;
  final String details;
}

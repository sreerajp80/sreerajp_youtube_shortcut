import 'package:flutter/material.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  /// Permissions the user is actually prompted to grant.
  List<_PermissionEntry> _explicitPermissions(AppLocalizations l10n) {
    return <_PermissionEntry>[
      _PermissionEntry(
        title: l10n.permissionCameraTitle,
        scope: l10n.permissionCameraScope,
        details: l10n.permissionCameraDetails,
      ),
    ];
  }

  /// Manifest declarations and platform behaviours that need no user prompt.
  List<_PermissionEntry> _implicitPermissions(AppLocalizations l10n) {
    return <_PermissionEntry>[
      _PermissionEntry(
        title: l10n.permissionLauncherTitle,
        scope: l10n.permissionLauncherScope,
        details: l10n.permissionLauncherDetails,
      ),
      _PermissionEntry(
        title: l10n.permissionQueriesTitle,
        scope: l10n.permissionQueriesScope,
        details: l10n.permissionQueriesDetails,
      ),
      _PermissionEntry(
        title: l10n.permissionShareTargetTitle,
        scope: l10n.permissionShareTargetScope,
        details: l10n.permissionShareTargetDetails,
      ),
      _PermissionEntry(
        title: l10n.permissionClipboardTitle,
        scope: l10n.permissionClipboardScope,
        details: l10n.permissionClipboardDetails,
      ),
      _PermissionEntry(
        title: l10n.permissionBackupTitle,
        scope: l10n.permissionBackupScope,
        details: l10n.permissionBackupDetails,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.permissionsScreenTitle)),
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
                    l10n.permissionsIntroTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.permissionsIntroBody,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: l10n.permissionsExplicitSection),
          const SizedBox(height: 10),
          ..._explicitPermissions(l10n).map(
            (_PermissionEntry entry) => _buildPermissionCard(context, entry),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: l10n.permissionsImplicitSection),
          const SizedBox(height: 10),
          ..._implicitPermissions(l10n).map(
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

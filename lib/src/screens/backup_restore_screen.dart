import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../backup_service.dart';
import '../shortcut_store.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ShortcutStore store = context.watch<ShortcutStore>();
    final int entryCount = store.entries.length;
    final bool busy = _isExporting || _isImporting;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
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
                    'Move shortcuts between devices',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Export your saved shortcuts to a JSON file you control, then import the same file on another device or after reinstalling the app. Everything stays on-device — the file is written to a folder you pick using the system file picker.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: 'Export'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entryCount == 0
                        ? 'No shortcuts to export yet. Add at least one shortcut from the home screen, then return here.'
                        : 'Save all $entryCount shortcut${entryCount == 1 ? '' : 's'} to a JSON file. Android will let you choose the destination — local Files, an SD card folder, or a cloud-synced folder.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: (busy || entryCount == 0) ? null : _runExport,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_upload_outlined),
                    label: Text(_isExporting ? 'Exporting…' : 'Export to file'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: 'Import'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Pick a backup file you previously exported. You can either merge it with the current list (skipping shortcuts whose name is already in use) or replace everything currently saved.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      FilledButton.tonalIcon(
                        onPressed: busy
                            ? null
                            : () => _runImport(BackupImportMode.merge),
                        icon: _isImporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.merge_type_rounded),
                        label: const Text('Import & merge'),
                      ),
                      OutlinedButton.icon(
                        onPressed: busy ? null : _confirmAndReplace,
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: const Text('Import & replace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Replace removes every saved shortcut on this device first, then loads the file. There is no undo.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: 'What is in the file'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  _BulletLine(
                    text:
                        'Each saved shortcut: name, the URL you entered, the canonical YouTube URL the app launches, the target type, and the created/updated timestamps.',
                  ),
                  SizedBox(height: 8),
                  _BulletLine(
                    text:
                        'A schema version and an export timestamp so future app versions can read the file safely.',
                  ),
                  SizedBox(height: 8),
                  _BulletLine(
                    text:
                        'No theme or layout preferences, no analytics, and nothing about your device — only the shortcut entries you created.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runExport() async {
    final ShortcutStore store = context.read<ShortcutStore>();
    final String? passphrase = await _promptExportPassword();
    if (passphrase == null) return;

    setState(() => _isExporting = true);
    try {
      final BackupExportOutcome outcome = await store.exportShortcutsToFile(
        passphrase: passphrase,
      );
      if (!mounted) return;
      switch (outcome) {
        case BackupExportSuccess(
          :final int exportedCount,
          :final String destinationLabel,
        ):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Exported $exportedCount shortcut${exportedCount == 1 ? '' : 's'} to "$destinationLabel".',
              ),
            ),
          );
        case BackupExportCancelled():
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Export cancelled.')));
      }
    } on ShortcutBackupException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<String?> _promptExportPassword() async {
    final TextEditingController passController = TextEditingController();
    bool encrypt = false;

    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Export Backup'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CheckboxListTile(
                    title: const Text('Encrypt backup with password'),
                    subtitle: const Text('Uses AES-256 encryption with PBKDF2'),
                    value: encrypt,
                    onChanged: (bool? val) {
                      setDialogState(() => encrypt = val ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (encrypt)
                    TextField(
                      controller: passController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Enter Backup Password',
                        hintText: 'Minimum 4 characters',
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (encrypt && passController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a password.'),
                        ),
                      );
                      return;
                    }
                    Navigator.of(
                      dialogContext,
                    ).pop(encrypt ? passController.text.trim() : '');
                  },
                  child: const Text('Export'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _promptImportPassword() async {
    final TextEditingController passController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Encrypted Backup Detected'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'This backup file is encrypted. Enter the password used during export to decrypt it.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Backup Password',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(passController.text.trim());
              },
              child: const Text('Decrypt & Import'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAndReplace() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Replace all shortcuts?'),
          content: const Text(
            'Importing in replace mode removes every shortcut currently saved on this device, then loads the picked backup file. This cannot be undone. Continue?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Replace'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    await _runImport(BackupImportMode.replace);
  }

  Future<void> _runImport(BackupImportMode mode) async {
    setState(() => _isImporting = true);
    try {
      final ShortcutStore store = context.read<ShortcutStore>();
      final BackupFileReadResult? fileResult = await store.readBackupFromFile();
      if (fileResult == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Import cancelled.')));
        }
        return;
      }

      String? passphrase;
      if (store.backupService.isEncrypted(fileResult.contents)) {
        passphrase = await _promptImportPassword();
        if (passphrase == null) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Import cancelled.')));
          }
          return;
        }
      }

      final BackupImportOutcome outcome = await store.importShortcutsFromFile(
        mode: mode,
        fileResultOverride: fileResult,
        passphrase: passphrase,
      );
      if (!mounted) return;
      switch (outcome) {
        case BackupImportSuccess success:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_messageFor(success))));
        case BackupImportCancelled():
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Import cancelled.')));
      }
    } on ShortcutBackupException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on ShortcutStorageException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  String _messageFor(BackupImportSuccess result) {
    switch (result.mode) {
      case BackupImportMode.merge:
        if (result.added == 0) {
          return 'No new shortcuts added — the file matched names already saved.';
        }
        if (result.skipped == 0) {
          return 'Imported ${result.added} shortcut${result.added == 1 ? '' : 's'}.';
        }
        return 'Imported ${result.added} new shortcut${result.added == 1 ? '' : 's'}; skipped ${result.skipped} duplicate name${result.skipped == 1 ? '' : 's'}.';
      case BackupImportMode.replace:
        return 'Replaced local list with ${result.totalAfter} shortcut${result.totalAfter == 1 ? '' : 's'} from the file.';
    }
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

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 7, right: 10),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }
}

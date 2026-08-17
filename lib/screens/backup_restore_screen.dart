import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/l10n/error_messages.dart';
import 'package:sreerajp_youtube_shortcut/services/backup_service.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';
import 'package:sreerajp_youtube_shortcut/widgets/bulk_qr_dialog.dart';
import 'package:sreerajp_youtube_shortcut/screens/qr_scanner_screen.dart';

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
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupScreenTitle)),
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
                    l10n.backupIntroTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.backupIntroBody,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: l10n.backupExportSection),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entryCount == 0
                        ? l10n.backupNothingToExport
                        : l10n.backupExportCount(entryCount),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: (busy || entryCount == 0)
                            ? null
                            : _runExport,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.file_upload_outlined),
                        label: Text(
                          _isExporting
                              ? l10n.backupExporting
                              : l10n.backupExportToFile,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: (busy || entryCount == 0)
                            ? null
                            : () {
                                BulkQrDialog.show(
                                  context,
                                  entries: store.entries,
                                  settings: store.exportSettingsMap(),
                                );
                              },
                        icon: const Icon(Icons.qr_code_2_rounded),
                        label: Text(l10n.backupExportViaQr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: l10n.backupImportSection),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.backupImportIntro,
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
                        label: Text(l10n.backupImportMerge),
                      ),
                      OutlinedButton.icon(
                        onPressed: busy ? null : _confirmAndReplace,
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: Text(l10n.backupImportReplace),
                      ),
                      OutlinedButton.icon(
                        onPressed: busy
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        const QrScannerScreen(),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: Text(l10n.backupScanQr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.backupReplaceWarning,
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
          _SectionTitle(title: l10n.backupContentsSection),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _BulletLine(text: l10n.backupContentsShortcuts),
                  const SizedBox(height: 8),
                  _BulletLine(text: l10n.backupContentsSchema),
                  const SizedBox(height: 8),
                  _BulletLine(text: l10n.backupContentsExcluded),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
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
                l10n.backupExportedMessage(exportedCount, destinationLabel),
              ),
            ),
          );
        case BackupExportCancelled():
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.backupExportCancelled)));
      }
    } on ShortcutBackupException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.localized(l10n))));
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<String?> _promptExportPassword() async {
    final TextEditingController passController = TextEditingController();
    final AppLocalizations l10n = AppLocalizations.of(context);
    bool encrypt = false;

    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(l10n.backupExportDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CheckboxListTile(
                    title: Text(l10n.backupEncryptOption),
                    subtitle: Text(l10n.backupEncryptSubtitle),
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
                      decoration: InputDecoration(
                        labelText: l10n.backupPasswordEnterLabel,
                        hintText: l10n.backupPasswordHint,
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (encrypt && passController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.backupPasswordRequired)),
                      );
                      return;
                    }
                    Navigator.of(
                      dialogContext,
                    ).pop(encrypt ? passController.text.trim() : '');
                  },
                  child: Text(l10n.backupExportAction),
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
    final AppLocalizations l10n = AppLocalizations.of(context);

    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.backupEncryptedDetectedTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(l10n.backupEncryptedDetectedBody),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.backupPasswordLabel,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(passController.text.trim());
              },
              child: Text(l10n.backupDecryptImportAction),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAndReplace() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.backupReplaceConfirmTitle),
          content: Text(l10n.backupReplaceConfirmBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.backupReplaceAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    await _runImport(BackupImportMode.replace);
  }

  Future<void> _runImport(BackupImportMode mode) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _isImporting = true);
    try {
      final ShortcutStore store = context.read<ShortcutStore>();
      final BackupFileReadResult? fileResult = await store.readBackupFromFile();
      if (fileResult == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.backupImportCancelled)));
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
            ).showSnackBar(SnackBar(content: Text(l10n.backupImportCancelled)));
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
          ).showSnackBar(SnackBar(content: Text(_messageFor(l10n, success))));
        case BackupImportCancelled():
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.backupImportCancelled)));
      }
    } on ShortcutBackupException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.localized(l10n))));
    } on ShortcutStorageException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.localized(l10n))));
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  String _messageFor(AppLocalizations l10n, BackupImportSuccess result) {
    switch (result.mode) {
      case BackupImportMode.merge:
        if (result.added == 0) {
          return l10n.backupMergeNoneAdded;
        }
        if (result.skipped == 0) {
          return l10n.backupMergeAdded(result.added);
        }
        return l10n.backupMergeAddedSkipped(result.added, result.skipped);
      case BackupImportMode.replace:
        return l10n.backupReplaceResult(result.totalAfter);
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

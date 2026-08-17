import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/services/backup_service.dart';
import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/l10n/error_messages.dart';
import 'package:sreerajp_youtube_shortcut/models/qr_payload_parser.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/state/shortcut_store.dart';
import 'package:sreerajp_youtube_shortcut/services/youtube_launcher_service.dart';
import 'package:sreerajp_youtube_shortcut/services/youtube_url_formatter.dart';
import 'package:sreerajp_youtube_shortcut/screens/add_shortcut_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  final Map<int, String> _receivedChunks = <int, String>{};
  int? _expectedChunkTotal;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    _handleScannedText(rawValue.trim());
  }

  /// Placeholder name used only to run the URL through the formatter's
  /// validation path. Never shown to the user, so it stays a plain literal.
  static const String _validationProbeName = 'Test Validation';

  /// Localized strings for this screen.
  AppLocalizations get l10n => AppLocalizations.of(context);

  Future<void> _handleScannedText(String rawText) async {
    final ParsedQrPayload? payload = const QrPayloadParser().parse(rawText);
    if (payload == null) {
      _showErrorAndResume(l10n.scannerUnreadableCode);
      return;
    }

    if (payload.type == QrPayloadType.backupChunk) {
      _handleBackupChunk(payload);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _controller.stop();
    } catch (_) {}

    if (payload.type == QrPayloadType.fullBackup) {
      if (!mounted) return;
      _showFullBackupHandoffSheet(
        payload.backupEntries ?? const <ShortcutEntry>[],
        payload.backupSettings,
      );
      return;
    }

    final String? url = payload.url;
    if (url == null || url.isEmpty) {
      _showErrorAndResume(l10n.scannerUnreadableCode);
      return;
    }

    try {
      final YoutubeUrlFormatter formatter = const YoutubeUrlFormatter();
      final String? previewUrl = formatter.buildDisplayUrlPreview(url);
      final String urlToTest = previewUrl ?? url;

      // Validate URL format
      formatter.createEntry(
        nameInput: _validationProbeName,
        urlInput: urlToTest,
      );

      if (!mounted) return;
      _showReceiverHandoffSheet(payload);
    } on ShortcutValidationException catch (e) {
      _showErrorAndResume(e.localized(l10n));
    } catch (_) {
      _showErrorAndResume(l10n.scannerNotYoutubeLink);
    }
  }

  void _handleBackupChunk(ParsedQrPayload chunk) {
    if (chunk.chunkIndex == null ||
        chunk.chunkTotal == null ||
        chunk.chunkData == null) {
      return;
    }

    _expectedChunkTotal = chunk.chunkTotal;
    _receivedChunks[chunk.chunkIndex!] = chunk.chunkData!;

    final int collected = _receivedChunks.length;
    final int total = _expectedChunkTotal!;

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.scannerFrameProgress(
                  chunk.chunkIndex! + 1,
                  total,
                  collected,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (collected >= total) {
      final List<String> orderedData = <String>[];
      for (int i = 0; i < total; i++) {
        final String? piece = _receivedChunks[i];
        if (piece == null) {
          return;
        }
        orderedData.add(piece);
      }

      _receivedChunks.clear();
      _expectedChunkTotal = null;

      final String fullPayloadJson = orderedData.join('');
      final ParsedQrPayload? assembled = const QrPayloadParser().parse(
        fullPayloadJson,
      );

      if (assembled != null && assembled.type == QrPayloadType.fullBackup) {
        try {
          _controller.stop();
        } catch (_) {}
        setState(() {
          _isProcessing = true;
        });
        _showFullBackupHandoffSheet(
          assembled.backupEntries ?? const <ShortcutEntry>[],
          assembled.backupSettings,
        );
      } else {
        _showErrorAndResume(l10n.scannerAssembleFailed);
      }
    }
  }

  void _showFullBackupHandoffSheet(
    List<ShortcutEntry> entries,
    Map<String, dynamic>? settings,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);

        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(sheetContext).padding.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_backup_restore_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 28.0,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.scannerBackupReceivedTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.scannerBackupSubtitle(entries.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Text(l10n.scannerBackupPrompt, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20.0),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  final ShortcutStore store = context.read<ShortcutStore>();
                  final BackupImportOutcome outcome = await store
                      .importFullBackupPayload(
                        incomingEntries: entries,
                        mode: BackupImportMode.merge,
                        settings: settings,
                      );
                  final int addedCount = outcome is BackupImportSuccess
                      ? outcome.added
                      : entries.length;
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.scannerMergedMessage(addedCount)),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.merge_type_rounded),
                label: Text(l10n.scannerMergeButton),
              ),
              const SizedBox(height: 8.0),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  final ShortcutStore store = context.read<ShortcutStore>();
                  final BackupImportOutcome outcome = await store
                      .importFullBackupPayload(
                        incomingEntries: entries,
                        mode: BackupImportMode.replace,
                        settings: settings,
                      );
                  final int addedCount = outcome is BackupImportSuccess
                      ? outcome.added
                      : entries.length;
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.scannerReplacedMessage(addedCount)),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.swap_horiz_rounded),
                label: Text(l10n.scannerReplaceButton),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted && _isProcessing) {
        setState(() {
          _isProcessing = false;
        });
        try {
          _controller.start();
        } catch (_) {}
      }
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final BarcodeCapture? capture = await _controller.analyzeImage(file.path);

      if (capture == null || capture.barcodes.isEmpty) {
        _showErrorAndResume(l10n.scannerNoCodeInImage);
        return;
      }

      final String? rawValue = capture.barcodes.first.rawValue;
      if (rawValue == null || rawValue.trim().isEmpty) {
        _showErrorAndResume(l10n.scannerNoYoutubeCodeInImage);
        return;
      }

      _handleScannedText(rawValue.trim());
    } catch (_) {
      _showErrorAndResume(l10n.scannerImageReadFailed);
    }
  }

  void _showErrorAndResume(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _isProcessing = false;
    });

    try {
      _controller.start();
    } catch (_) {}
  }

  void _showReceiverHandoffSheet(ParsedQrPayload payload) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);
        final String displayUrl = payload.url ?? '';
        final String displayName =
            payload.name ?? l10n.scannerDefaultShortcutName;

        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(sheetContext).padding.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 28.0,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.scannerShortcutReceivedTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          payload.isStructuredJson
                              ? l10n.scannerStructuredPayload
                              : l10n.scannerPlainLinkPayload,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      SelectableText(
                        displayUrl,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (payload.tags.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 10.0),
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          children: payload.tags
                              .map(
                                (String tag) => Chip(
                                  label: Text(
                                    tag.startsWith('#') ? tag : '#$tag',
                                    style: const TextStyle(fontSize: 11.0),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => AddShortcutScreen(
                        initialNameInput: payload.name,
                        initialUrlInput: payload.url,
                        initialTags: payload.tags,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_add_rounded),
                label: Text(l10n.scannerSaveButton),
              ),
              const SizedBox(height: 8.0),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  try {
                    final YoutubeUrlFormatter formatter =
                        const YoutubeUrlFormatter();
                    final ShortcutEntry entry = formatter.createEntry(
                      nameInput: displayName,
                      urlInput: displayUrl,
                      tags: payload.tags,
                    );
                    await const YoutubeLauncherService().openShortcut(entry);
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  } on YoutubeLaunchException catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.localized(l10n))),
                      );
                      setState(() {
                        _isProcessing = false;
                      });
                      _controller.start();
                    }
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.scannerLaunchFailed)),
                      );
                      setState(() {
                        _isProcessing = false;
                      });
                      _controller.start();
                    }
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.scannerOpenButton),
              ),
              const SizedBox(height: 4.0),
              TextButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  setState(() {
                    _isProcessing = false;
                  });
                  _controller.start();
                },
                child: Text(l10n.scannerScanAnotherButton),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scannerScreenTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
            tooltip: l10n.scannerTorchTooltip,
          ),
          IconButton(
            icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
            onPressed: () async {
              await _controller.switchCamera();
              setState(() {
                _isFrontCamera = !_isFrontCamera;
              });
            },
            tooltip: l10n.scannerSwitchCameraTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _pickImageFromGallery,
            tooltip: l10n.scannerGalleryTooltip,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (BuildContext context, MobileScannerException error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 64.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        l10n.scannerCameraUnavailableTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        l10n.scannerCameraUnavailableBody,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      FilledButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: Text(l10n.scannerSelectImageButton),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Viewport scanner box overlay frame
          Center(
            child: Container(
              width: 260.0,
              height: 260.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 12.0,
                    left: 12.0,
                    right: 12.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0x99000000),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      child: Text(
                        l10n.scannerAlignHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom CTA instruction bar
          Positioned(
            left: 24.0,
            right: 24.0,
            bottom: 32.0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: Text(l10n.scannerGalleryButton),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

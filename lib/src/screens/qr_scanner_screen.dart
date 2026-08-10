import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/errors/app_exception.dart';
import '../qr_payload_parser.dart';
import '../shortcut_models.dart';
import '../youtube_launcher_service.dart';
import '../youtube_url_formatter.dart';
import 'add_shortcut_screen.dart';

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

  Future<void> _handleScannedText(String rawText) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _controller.stop();
    } catch (_) {}

    final ParsedQrPayload? payload = const QrPayloadParser().parse(rawText);
    if (payload == null || payload.url.isEmpty) {
      _showErrorAndResume('Scanned QR code is empty or unreadable.');
      return;
    }

    try {
      final YoutubeUrlFormatter formatter = const YoutubeUrlFormatter();
      final String? previewUrl = formatter.buildDisplayUrlPreview(payload.url);
      final String urlToTest = previewUrl ?? payload.url;

      // Validate URL format
      formatter.createEntry(
        nameInput: 'Test Validation',
        urlInput: urlToTest,
      );

      if (!mounted) return;
      _showReceiverHandoffSheet(payload);
    } on ShortcutValidationException catch (e) {
      _showErrorAndResume(e.message);
    } catch (_) {
      _showErrorAndResume('Scanned QR code is not a valid YouTube link.');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final BarcodeCapture? capture =
          await _controller.analyzeImage(file.path);

      if (capture == null || capture.barcodes.isEmpty) {
        _showErrorAndResume(
          'No readable QR code found in selected image.',
        );
        return;
      }

      final String? rawValue = capture.barcodes.first.rawValue;
      if (rawValue == null || rawValue.trim().isEmpty) {
        _showErrorAndResume(
          'No readable YouTube QR code found in image.',
        );
        return;
      }

      _handleScannedText(rawValue.trim());
    } catch (_) {
      _showErrorAndResume('Failed to read image from gallery.');
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
        final String displayUrl = payload.url;
        final String displayName = payload.name ?? 'Scanned YouTube Link';

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
                          'Shortcut Received!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          payload.isStructuredJson
                              ? 'Air-Gapped Shortcut Payload'
                              : 'Scanned YouTube QR Link',
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
                label: const Text('Save to YT Shortcuts'),
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
                        SnackBar(content: Text(e.message)),
                      );
                      setState(() {
                        _isProcessing = false;
                      });
                      _controller.start();
                    }
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to open YouTube app.'),
                        ),
                      );
                      setState(() {
                        _isProcessing = false;
                      });
                      _controller.start();
                    }
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Open in YouTube'),
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
                child: const Text('Scan Another Code'),
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
        title: const Text('Offline QR Scanner'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            icon: Icon(
              _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
            ),
            onPressed: () async {
              await _controller.switchCamera();
              setState(() {
                _isFrontCamera = !_isFrontCamera;
              });
            },
            tooltip: 'Switch Camera',
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _pickImageFromGallery,
            tooltip: 'Pick from Gallery',
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (
              BuildContext context,
              MobileScannerException error,
            ) {
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
                        'Camera Access Unavailable',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Ensure camera permission is enabled in Android settings, or select a QR code image from gallery.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      FilledButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Select Image from Gallery'),
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
                      child: const Text(
                        'Align QR code within frame',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
                label: const Text('Scan Image from Gallery'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:sreerajp_youtube_shortcut/l10n/app_localizations.dart';
import 'package:sreerajp_youtube_shortcut/models/qr_payload_parser.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';

class BulkQrDialog extends StatefulWidget {
  const BulkQrDialog({
    required this.entries,
    required this.settings,
    super.key,
  });

  final List<ShortcutEntry> entries;
  final Map<String, dynamic> settings;

  static Future<void> show(
    BuildContext context, {
    required List<ShortcutEntry> entries,
    required Map<String, dynamic> settings,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          BulkQrDialog(entries: entries, settings: settings),
    );
  }

  @override
  State<BulkQrDialog> createState() => _BulkQrDialogState();
}

class _BulkQrDialogState extends State<BulkQrDialog> {
  late final List<String> _frames;
  int _currentFrameIndex = 0;
  Timer? _timer;
  bool _isPlaying = true;
  final int _speedMs = 350;

  @override
  void initState() {
    super.initState();
    final String fullPayload = const QrPayloadParser().encodeFullBackup(
      entries: widget.entries,
      settings: widget.settings,
    );
    _frames = const QrPayloadParser().createChunkFrames(fullPayload);
    if (_frames.length > 1) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _speedMs), (Timer timer) {
      if (mounted) {
        setState(() {
          _currentFrameIndex = (_currentFrameIndex + 1) % _frames.length;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getEstimatedTimeText(AppLocalizations l10n) {
    if (_frames.length <= 1) {
      return l10n.bulkQrInstantTime;
    }
    final double totalSeconds = (_frames.length * _speedMs) / 1000.0;
    return l10n.bulkQrSecondsTime(totalSeconds.toStringAsFixed(1));
  }

  bool _isHugeData() {
    return _frames.length > 15 || widget.entries.length > 50;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isAnimated = _frames.length > 1;
    final bool isHuge = _isHugeData();
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 24.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    isAnimated ? Icons.animation : Icons.qr_code_2,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.bulkQrTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          l10n.bulkQrSubtitle(widget.entries.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: l10n.qrDialogCloseTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Estimated Transfer Time Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        l10n.bulkQrEstimatedTime(_getEstimatedTimeText(l10n)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),

              // Huge Data Warning Banner
              if (isHuge) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade400),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade900,
                        size: 24,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          l10n.bulkQrLargeWarning(_frames.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
              ],

              if (isAnimated) ...<Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        l10n.bulkQrFrameCounter(
                          _currentFrameIndex + 1,
                          _frames.length,
                        ),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: _togglePlayPause,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: _isPlaying
                            ? l10n.bulkQrPauseTooltip
                            : l10n.bulkQrPlayTooltip,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _frames[_currentFrameIndex],
                    version: QrVersions.auto,
                    size: 240.0,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                isAnimated ? l10n.bulkQrAnimatedHint : l10n.bulkQrSingleHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

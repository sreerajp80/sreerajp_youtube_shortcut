import 'dart:convert';

import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';

enum QrPayloadType { shortcut, fullBackup, backupChunk, rawUrl }

class ParsedQrPayload {
  const ParsedQrPayload({
    required this.type,
    this.url,
    this.name,
    this.tags = const <String>[],
    this.isStructuredJson = false,
    this.backupEntries,
    this.backupSettings,
    this.chunkIndex,
    this.chunkTotal,
    this.chunkData,
  });

  final QrPayloadType type;
  final String? url;
  final String? name;
  final List<String> tags;
  final bool isStructuredJson;

  final List<ShortcutEntry>? backupEntries;
  final Map<String, dynamic>? backupSettings;

  final int? chunkIndex;
  final int? chunkTotal;
  final String? chunkData;
}

class QrPayloadParser {
  const QrPayloadParser();

  static const String payloadTypeShortcut = 'yt_shortcut';
  static const String payloadTypeFullBackup = 'yt_shortcuts_backup';
  static const String payloadTypeLegacyBackup =
      'sreerajp_youtube_shortcuts_backup';
  static const String payloadTypeChunk = 'yt_shortcuts_chunk';

  ParsedQrPayload? parse(String rawContent) {
    final String trimmed = rawContent.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        final String? typeStr = decoded['type']?.toString().trim();

        // 1. Animated QR Chunk payload
        if (typeStr == payloadTypeChunk) {
          final int? idx = decoded['idx'] as int?;
          final int? total = decoded['total'] as int?;
          final String? data = decoded['data']?.toString();
          if (idx != null && total != null && data != null) {
            return ParsedQrPayload(
              type: QrPayloadType.backupChunk,
              chunkIndex: idx,
              chunkTotal: total,
              chunkData: data,
              isStructuredJson: true,
            );
          }
        }

        // 2. Full Backup payload (either yt_shortcuts_backup or sreerajp_youtube_shortcuts_backup)
        if (typeStr == payloadTypeFullBackup ||
            typeStr == payloadTypeLegacyBackup) {
          final dynamic listRaw = decoded['shortcuts'];
          if (listRaw is List) {
            final List<ShortcutEntry> entries = <ShortcutEntry>[];
            for (final dynamic item in listRaw) {
              if (item is Map<String, dynamic>) {
                try {
                  entries.add(ShortcutEntry.fromJson(item));
                } catch (_) {}
              }
            }
            final dynamic settingsRaw = decoded['settings'];
            final Map<String, dynamic>? settings =
                settingsRaw is Map<String, dynamic> ? settingsRaw : null;

            return ParsedQrPayload(
              type: QrPayloadType.fullBackup,
              backupEntries: List<ShortcutEntry>.unmodifiable(entries),
              backupSettings: settings,
              isStructuredJson: true,
            );
          }
        }

        // 3. Single Shortcut payload
        final String? url =
            (decoded['url'] ?? decoded['canonicalUrl'] ?? decoded['sourceUrl'])
                ?.toString()
                .trim();

        if (url != null && url.isNotEmpty) {
          final String? name = decoded['name']?.toString().trim();
          final List<dynamic>? rawTags = decoded['tags'] as List<dynamic>?;
          final List<String> tags = rawTags != null
              ? rawTags
                    .map((dynamic e) => e.toString().trim())
                    .where((String element) => element.isNotEmpty)
                    .toList(growable: false)
              : const <String>[];

          return ParsedQrPayload(
            type: QrPayloadType.shortcut,
            url: url,
            name: (name != null && name.isNotEmpty) ? name : null,
            tags: tags,
            isStructuredJson: true,
          );
        }
      }
    } catch (_) {
      // Not a valid JSON payload; fall back to URL extraction logic.
    }

    // Try extracting explicit HTTP/HTTPS URL from raw text
    final RegExp urlRegExp = RegExp(r'https?://[^\s]+');
    final Match? match = urlRegExp.firstMatch(trimmed);
    if (match != null) {
      String extractedUrl = match.group(0)!;
      extractedUrl = extractedUrl.replaceAll(RegExp(r'[.,;:!?)]+$'), '');
      return ParsedQrPayload(
        type: QrPayloadType.shortcut,
        url: extractedUrl,
        isStructuredJson: false,
      );
    }

    // Fall back to returning raw trimmed text (e.g. handle or scheme-less URL)
    return ParsedQrPayload(
      type: QrPayloadType.shortcut,
      url: trimmed,
      isStructuredJson: false,
    );
  }

  String encodeShortcut(ShortcutEntry entry) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'type': payloadTypeShortcut,
      'name': entry.name,
      'url': entry.canonicalUrl,
      if (entry.tags.isNotEmpty) 'tags': entry.tags,
    };
    return jsonEncode(payload);
  }

  String encodeFullBackup({
    required List<ShortcutEntry> entries,
    Map<String, dynamic>? settings,
  }) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'type': payloadTypeFullBackup,
      'schemaVersion': 1,
      'exportedAtIso': DateTime.now().toUtc().toIso8601String(),
      'shortcutCount': entries.length,
      'shortcuts': entries
          .map((ShortcutEntry entry) => entry.toJson())
          .toList(growable: false),
    };
    if (settings != null) {
      payload['settings'] = settings;
    }
    return jsonEncode(payload);
  }

  List<String> createChunkFrames(
    String fullPayloadJson, {
    int maxChunkLength = 500,
  }) {
    if (fullPayloadJson.length <= maxChunkLength) {
      return <String>[fullPayloadJson];
    }

    final List<String> chunks = <String>[];
    final int totalLength = fullPayloadJson.length;
    final int totalFrames = (totalLength / maxChunkLength).ceil();

    for (int i = 0; i < totalFrames; i++) {
      final int start = i * maxChunkLength;
      final int end = (start + maxChunkLength < totalLength)
          ? start + maxChunkLength
          : totalLength;
      final String slice = fullPayloadJson.substring(start, end);

      final Map<String, dynamic> chunkFrame = <String, dynamic>{
        'type': payloadTypeChunk,
        'idx': i,
        'total': totalFrames,
        'data': slice,
      };
      chunks.add(jsonEncode(chunkFrame));
    }

    return chunks;
  }
}

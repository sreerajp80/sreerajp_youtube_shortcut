import 'dart:convert';

import 'shortcut_models.dart';

class ParsedQrPayload {
  const ParsedQrPayload({
    required this.url,
    this.name,
    this.tags = const <String>[],
    this.isStructuredJson = false,
  });

  final String url;
  final String? name;
  final List<String> tags;
  final bool isStructuredJson;
}

class QrPayloadParser {
  const QrPayloadParser();

  static const String payloadType = 'yt_shortcut';

  ParsedQrPayload? parse(String rawContent) {
    final String trimmed = rawContent.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        final String? url = (decoded['url'] ??
                decoded['canonicalUrl'] ??
                decoded['sourceUrl'])
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
        url: extractedUrl,
        isStructuredJson: false,
      );
    }

    // Fall back to returning raw trimmed text (e.g. handle or scheme-less URL)
    return ParsedQrPayload(
      url: trimmed,
      isStructuredJson: false,
    );
  }

  String encodeShortcut(ShortcutEntry entry) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'type': payloadType,
      'name': entry.name,
      'url': entry.canonicalUrl,
      if (entry.tags.isNotEmpty) 'tags': entry.tags,
    };
    return jsonEncode(payload);
  }
}

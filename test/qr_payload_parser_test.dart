import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_youtube_shortcut/src/qr_payload_parser.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_models.dart';

void main() {
  group('QrPayloadParser', () {
    const QrPayloadParser parser = QrPayloadParser();

    test('encodes shortcut entry to structured JSON payload', () {
      const ShortcutEntry entry = ShortcutEntry(
        id: '123',
        name: 'Test Shortcut',
        sourceUrl: 'https://youtube.com/watch?v=abc',
        canonicalUrl: 'https://www.youtube.com/watch?v=abc',
        targetType: ShortcutTargetType.video,
        createdAtIso: '2026-08-10T00:00:00Z',
        updatedAtIso: '2026-08-10T00:00:00Z',
        tags: <String>['#Tech', '#Music'],
      );

      final String encoded = parser.encodeShortcut(entry);
      expect(encoded, contains('"type":"yt_shortcut"'));
      expect(encoded, contains('"name":"Test Shortcut"'));
      expect(encoded, contains('"url":"https://www.youtube.com/watch?v=abc"'));
      expect(encoded, contains('"tags":["#Tech","#Music"]'));
    });

    test('parses structured JSON QR payload', () {
      const String jsonPayload = '''
      {
        "type": "yt_shortcut",
        "name": "My Favorite Channel",
        "url": "https://www.youtube.com/@JanamTVMedia",
        "tags": ["#News", "#Media"]
      }
      ''';

      final ParsedQrPayload? parsed = parser.parse(jsonPayload);
      expect(parsed, isNotNull);
      expect(parsed!.name, 'My Favorite Channel');
      expect(parsed.url, 'https://www.youtube.com/@JanamTVMedia');
      expect(parsed.tags, <String>['#News', '#Media']);
      expect(parsed.isStructuredJson, isTrue);
    });

    test('parses plain URL string QR payload', () {
      const String plainUrl = 'https://youtu.be/dQw4w9WgXcQ';

      final ParsedQrPayload? parsed = parser.parse(plainUrl);
      expect(parsed, isNotNull);
      expect(parsed!.name, isNull);
      expect(parsed.url, 'https://youtu.be/dQw4w9WgXcQ');
      expect(parsed.isStructuredJson, isFalse);
    });

    test('parses plain channel handle QR payload', () {
      const String handlePayload = '@JanamTVMedia';

      final ParsedQrPayload? parsed = parser.parse(handlePayload);
      expect(parsed, isNotNull);
      expect(parsed!.name, isNull);
      expect(parsed.url, '@JanamTVMedia');
      expect(parsed.isStructuredJson, isFalse);
    });

    test('returns null for empty or whitespace content', () {
      expect(parser.parse(''), isNull);
      expect(parser.parse('   '), isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_youtube_shortcut/models/qr_payload_parser.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';

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

    test('encodes and parses full backup QR payload with settings', () {
      const ShortcutEntry entry = ShortcutEntry(
        id: '123',
        name: 'Test Shortcut',
        sourceUrl: 'https://youtube.com/watch?v=abc',
        canonicalUrl: 'https://www.youtube.com/watch?v=abc',
        targetType: ShortcutTargetType.video,
        createdAtIso: '2026-08-10T00:00:00Z',
        updatedAtIso: '2026-08-10T00:00:00Z',
        tags: <String>['#Tech'],
      );
      final Map<String, dynamic> settings = <String, dynamic>{
        'theme': 'dark',
        'layout': 'grid',
        'sort': 'name',
        'favoritesFirst': true,
      };

      final String fullJson = parser.encodeFullBackup(
        entries: <ShortcutEntry>[entry],
        settings: settings,
      );

      final ParsedQrPayload? parsed = parser.parse(fullJson);
      expect(parsed, isNotNull);
      expect(parsed!.type, QrPayloadType.fullBackup);
      expect(parsed.backupEntries?.length, 1);
      expect(parsed.backupEntries?.first.name, 'Test Shortcut');
      expect(parsed.backupSettings?['theme'], 'dark');
      expect(parsed.backupSettings?['favoritesFirst'], isTrue);
    });

    test('creates and parses animated QR chunk frames', () {
      const String longPayload =
          '{"type":"yt_shortcuts_backup","shortcuts":[{"id":"1","name":"A"},{"id":"2","name":"B"}]}';
      final List<String> frames = parser.createChunkFrames(
        longPayload,
        maxChunkLength: 30,
      );
      expect(frames.length, greaterThan(1));

      final List<String> reassembledPieces = <String>[];
      for (int i = 0; i < frames.length; i++) {
        final ParsedQrPayload? chunkParsed = parser.parse(frames[i]);
        expect(chunkParsed, isNotNull);
        expect(chunkParsed!.type, QrPayloadType.backupChunk);
        expect(chunkParsed.chunkIndex, i);
        expect(chunkParsed.chunkTotal, frames.length);
        reassembledPieces.add(chunkParsed.chunkData!);
      }

      final String reassembledJson = reassembledPieces.join('');
      expect(reassembledJson, longPayload);
    });
  });
}

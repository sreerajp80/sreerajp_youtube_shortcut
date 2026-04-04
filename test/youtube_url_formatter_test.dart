import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_youtube_shortcut/src/shortcut_models.dart';
import 'package:sreerajp_youtube_shortcut/src/shortcut_services.dart';

void main() {
  const YoutubeUrlFormatter formatter = YoutubeUrlFormatter();

  test('normalizes bare handle input to a channel live url', () {
    final ShortcutEntry entry = formatter.createEntry(
      nameInput: 'Janam Live',
      urlInput: 'JanamTVMedia',
    );

    expect(entry.sourceUrl, 'JanamTVMedia');
    expect(entry.canonicalUrl, 'https://www.youtube.com/@JanamTVMedia/live');
    expect(entry.targetType, ShortcutTargetType.channel);
  });

  test('normalizes @handle input to a channel live url', () {
    final ShortcutEntry entry = formatter.createEntry(
      nameInput: 'Janam Live',
      urlInput: '@JanamTVMedia',
    );

    expect(entry.sourceUrl, '@JanamTVMedia');
    expect(entry.canonicalUrl, 'https://www.youtube.com/@JanamTVMedia/live');
    expect(entry.targetType, ShortcutTargetType.channel);
  });
  test('builds full-url preview for bare handle input', () {
    final String? preview = formatter.buildDisplayUrlPreview('JanamTVMedia');

    expect(preview, 'https://www.youtube.com/@JanamTVMedia/live');
  });

  test('does not build preview when input already has a URL scheme', () {
    final String? preview = formatter.buildDisplayUrlPreview(
      'https://www.youtube.com/@JanamTVMedia/live',
    );

    expect(preview, isNull);
  });

  test('normalizes youtu.be links to canonical watch urls', () {
    final ShortcutEntry entry = formatter.createEntry(
      nameInput: 'Launch video',
      urlInput: 'https://youtu.be/abc123xyz',
    );

    expect(entry.canonicalUrl, 'https://www.youtube.com/watch?v=abc123xyz');
    expect(entry.targetType, ShortcutTargetType.video);
  });

  test('normalizes shorts links', () {
    final ShortcutEntry entry = formatter.createEntry(
      nameInput: 'Short clip',
      urlInput: 'https://www.youtube.com/shorts/short987',
    );

    expect(entry.canonicalUrl, 'https://www.youtube.com/shorts/short987');
    expect(entry.targetType, ShortcutTargetType.shortVideo);
  });

  test('rejects invalid handle input', () {
    expect(
      () => formatter.createEntry(
        nameInput: 'Bad handle',
        urlInput: '@@bad handle',
      ),
      throwsA(isA<ShortcutValidationException>()),
    );
  });

  test('rejects non-youtube hosts', () {
    expect(
      () => formatter.createEntry(
        nameInput: 'Bad link',
        urlInput: 'https://example.com/watch?v=123',
      ),
      throwsA(isA<ShortcutValidationException>()),
    );
  });
}

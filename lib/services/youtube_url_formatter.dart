import 'dart:math';

import 'package:sreerajp_youtube_shortcut/core/errors/app_exception.dart';
import 'package:sreerajp_youtube_shortcut/models/shortcut_models.dart';

class YoutubeUrlFormatter {
  const YoutubeUrlFormatter();

  static final Random _idRandom = Random();

  ShortcutEntry createEntry({
    required String nameInput,
    required String urlInput,
    List<String> tags = const <String>[],
    bool isFavorite = false,
    bool isPrivate = false,
    String? customColorHex,
    String? customIconName,
  }) {
    return _buildEntry(
      nameInput: nameInput,
      urlInput: urlInput,
      tags: tags,
      isFavorite: isFavorite,
      isPrivate: isPrivate,
      customColorHex: customColorHex,
      customIconName: customIconName,
    );
  }

  ShortcutEntry updateEntry({
    required ShortcutEntry existingEntry,
    required String nameInput,
    required String urlInput,
    List<String>? tags,
    bool? isFavorite,
    bool? isPrivate,
    String? customColorHex,
    bool clearCustomColorHex = false,
    String? customIconName,
    bool clearCustomIconName = false,
  }) {
    return _buildEntry(
      nameInput: nameInput,
      urlInput: urlInput,
      existingId: existingEntry.id,
      existingCreatedAtIso: existingEntry.createdAtIso,
      existingLastLaunchedAtIso: existingEntry.lastLaunchedAtIso,
      existingLaunchCount: existingEntry.launchCount,
      tags: tags ?? existingEntry.tags,
      isFavorite: isFavorite ?? existingEntry.isFavorite,
      isPrivate: isPrivate ?? existingEntry.isPrivate,
      customColorHex: clearCustomColorHex
          ? null
          : (customColorHex ?? existingEntry.customColorHex),
      customIconName: clearCustomIconName
          ? null
          : (customIconName ?? existingEntry.customIconName),
    );
  }

  String? buildDisplayUrlPreview(String input) {
    final String normalizedInput = input.trim();
    if (normalizedInput.isEmpty || _hasExplicitScheme(normalizedInput)) {
      return null;
    }

    final String normalizedUrlInput = _expandHandleInput(normalizedInput);
    final Uri inputUri = _normalizeInputUri(normalizedUrlInput);
    _parseTarget(inputUri);
    return inputUri.toString();
  }

  ShortcutEntry _buildEntry({
    required String nameInput,
    required String urlInput,
    String? existingId,
    String? existingCreatedAtIso,
    String? existingLastLaunchedAtIso,
    int existingLaunchCount = 0,
    List<String> tags = const <String>[],
    bool isFavorite = false,
    bool isPrivate = false,
    String? customColorHex,
    String? customIconName,
  }) {
    final String trimmedName = nameInput.trim();
    if (trimmedName.isEmpty) {
      throw const ShortcutValidationException(
        AppErrorCode.nameEmpty,
        'Enter a shortcut name before saving.',
      );
    }

    final String normalizedInput = urlInput.trim();
    if (normalizedInput.isEmpty) {
      throw const ShortcutValidationException(
        AppErrorCode.urlEmpty,
        'Enter a channel handle or YouTube URL before saving.',
      );
    }

    final String normalizedUrlInput = _expandHandleInput(normalizedInput);
    final Uri inputUri = _normalizeInputUri(normalizedUrlInput);
    final _ParsedYoutubeTarget parsedTarget = _parseTarget(inputUri);
    final DateTime now = DateTime.now().toUtc();
    final String nowIso = now.toIso8601String();

    return ShortcutEntry(
      id: existingId ?? _createEntryId(now),
      name: trimmedName,
      sourceUrl: normalizedInput,
      canonicalUrl: parsedTarget.canonicalUri.toString(),
      targetType: parsedTarget.targetType,
      createdAtIso: existingCreatedAtIso ?? nowIso,
      updatedAtIso: nowIso,
      lastLaunchedAtIso: existingLastLaunchedAtIso,
      launchCount: existingLaunchCount,
      isFavorite: isFavorite,
      isPrivate: isPrivate,
      tags: tags,
      customColorHex: customColorHex,
      customIconName: customIconName,
    );
  }

  String _createEntryId(DateTime now) {
    return '${now.microsecondsSinceEpoch}-${_idRandom.nextInt(1 << 32)}';
  }

  bool _hasExplicitScheme(String input) {
    final int schemeDividerIndex = input.indexOf('://');
    if (schemeDividerIndex <= 0) {
      return false;
    }

    final String scheme = input.substring(0, schemeDividerIndex);
    final RegExp schemePattern = RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*$');
    return schemePattern.hasMatch(scheme);
  }

  String _expandHandleInput(String input) {
    if (!_looksLikeHandleInput(input)) {
      return input;
    }

    final String handleWithoutPrefix = input.startsWith('@')
        ? input.substring(1)
        : input;
    final RegExp validHandlePattern = RegExp(r'^[A-Za-z0-9._-]{3,30}$');
    if (!validHandlePattern.hasMatch(handleWithoutPrefix)) {
      throw const ShortcutValidationException(
        AppErrorCode.handleInvalid,
        'Enter a valid channel handle (for example: JanamTVMedia or @JanamTVMedia).',
      );
    }

    return Uri.https(
      'www.youtube.com',
      '/@$handleWithoutPrefix/live',
    ).toString();
  }

  bool _looksLikeHandleInput(String input) {
    if (input.startsWith('@')) {
      return true;
    }

    if (input.contains('://') ||
        input.contains('/') ||
        input.contains('?') ||
        input.contains('&') ||
        input.contains('=')) {
      return false;
    }

    final RegExp bareHandlePattern = RegExp(r'^[A-Za-z0-9_-]{3,30}$');
    return bareHandlePattern.hasMatch(input);
  }

  Uri _normalizeInputUri(String input) {
    final String prepared = input.contains('://') ? input : 'https://$input';
    final Uri? uri = Uri.tryParse(prepared);
    if (uri == null || uri.host.isEmpty) {
      throw const ShortcutValidationException(
        AppErrorCode.handleOrUrlInvalid,
        'Enter a valid channel handle or YouTube URL.',
      );
    }
    return uri;
  }

  _ParsedYoutubeTarget _parseTarget(Uri uri) {
    final String host = uri.host.toLowerCase();
    final List<String> segments = uri.pathSegments
        .where((String value) => value.isNotEmpty)
        .toList();

    if (host == 'youtu.be') {
      if (segments.isEmpty) {
        throw const ShortcutValidationException(
          AppErrorCode.shortLinkMissingVideoId,
          'Short YouTube links must include a video id.',
        );
      }

      final String videoId = segments.first;
      return _ParsedYoutubeTarget(
        targetType: ShortcutTargetType.video,
        canonicalUri: Uri.https('www.youtube.com', '/watch', <String, String>{
          'v': videoId,
        }),
      );
    }

    if (!_isSupportedYoutubeHost(host)) {
      throw const ShortcutValidationException(
        AppErrorCode.notYoutubeLink,
        'Only YouTube links are supported in this app.',
      );
    }

    if (segments.isNotEmpty && segments.first == 'watch') {
      final String? videoId = uri.queryParameters['v'];
      if (videoId == null || videoId.isEmpty) {
        throw const ShortcutValidationException(
          AppErrorCode.watchMissingVideoId,
          'Watch URLs must include a video id.',
        );
      }

      return _ParsedYoutubeTarget(
        targetType: ShortcutTargetType.video,
        canonicalUri: Uri.https('www.youtube.com', '/watch', <String, String>{
          'v': videoId,
        }),
      );
    }

    if (segments.isNotEmpty && segments.first == 'live') {
      if (segments.length < 2 || segments[1].isEmpty) {
        throw const ShortcutValidationException(
          AppErrorCode.liveMissingVideoId,
          'Live stream URLs must include a video id.',
        );
      }

      return _ParsedYoutubeTarget(
        targetType: ShortcutTargetType.video,
        canonicalUri: Uri.https('www.youtube.com', '/watch', <String, String>{
          'v': segments[1],
        }),
      );
    }

    if (segments.isNotEmpty && segments.first == 'shorts') {
      if (segments.length < 2 || segments[1].isEmpty) {
        throw const ShortcutValidationException(
          AppErrorCode.shortsMissingId,
          'Shorts URLs must include a shorts id.',
        );
      }

      return _ParsedYoutubeTarget(
        targetType: ShortcutTargetType.shortVideo,
        canonicalUri: Uri.https('www.youtube.com', '/shorts/${segments[1]}'),
      );
    }

    if (segments.isNotEmpty && segments.first == 'playlist') {
      final String? listId = uri.queryParameters['list'];
      if (listId == null || listId.isEmpty) {
        throw const ShortcutValidationException(
          AppErrorCode.playlistMissingListId,
          'Playlist URLs must include a list id.',
        );
      }

      return _ParsedYoutubeTarget(
        targetType: ShortcutTargetType.playlist,
        canonicalUri: Uri.https(
          'www.youtube.com',
          '/playlist',
          <String, String>{'list': listId},
        ),
      );
    }

    if (segments.isNotEmpty) {
      final String firstSegment = segments.first;
      final bool channelLike =
          firstSegment.startsWith('@') ||
          firstSegment == 'channel' ||
          firstSegment == 'c' ||
          firstSegment == 'user';

      if (channelLike) {
        if (firstSegment == 'channel' ||
            firstSegment == 'c' ||
            firstSegment == 'user') {
          if (segments.length < 2 || segments[1].isEmpty) {
            throw const ShortcutValidationException(
              AppErrorCode.channelMissingIdentifier,
              'Channel links must include an identifier.',
            );
          }
        }

        return _ParsedYoutubeTarget(
          targetType: ShortcutTargetType.channel,
          canonicalUri: Uri.https('www.youtube.com', '/${segments.join('/')}'),
        );
      }
    }

    throw const ShortcutValidationException(
      AppErrorCode.unsupportedLinkFormat,
      'This YouTube link format is not supported yet. Use watch, youtu.be, live, shorts, playlist, or channel links.',
    );
  }

  bool _isSupportedYoutubeHost(String host) {
    return host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'music.youtube.com' ||
        host == 'youtube-nocookie.com' ||
        host == 'www.youtube-nocookie.com';
  }
}

class _ParsedYoutubeTarget {
  const _ParsedYoutubeTarget({
    required this.targetType,
    required this.canonicalUri,
  });

  final ShortcutTargetType targetType;
  final Uri canonicalUri;
}

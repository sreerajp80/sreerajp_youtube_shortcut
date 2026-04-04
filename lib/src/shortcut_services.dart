import 'dart:convert';
import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shortcut_models.dart';

abstract class ShortcutRepository {
  Future<List<ShortcutEntry>> loadShortcuts();

  Future<void> saveShortcuts(List<ShortcutEntry> entries);
}

class SharedPreferencesShortcutRepository implements ShortcutRepository {
  SharedPreferencesShortcutRepository(this._preferences);

  final SharedPreferences _preferences;

  static const String _storageKey = 'shortcut_entries_v1';

  @override
  Future<List<ShortcutEntry>> loadShortcuts() async {
    try {
      final String? raw = _preferences.getString(_storageKey);
      if (raw == null || raw.trim().isEmpty) {
        return const <ShortcutEntry>[];
      }

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (dynamic item) =>
                ShortcutEntry.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    } catch (_) {
      throw const ShortcutStorageException(
        'Saved shortcuts could not be read from local storage.',
      );
    }
  }

  @override
  Future<void> saveShortcuts(List<ShortcutEntry> entries) async {
    try {
      final String encoded = jsonEncode(
        entries
            .map((ShortcutEntry entry) => entry.toJson())
            .toList(growable: false),
      );
      final bool saved = await _preferences.setString(_storageKey, encoded);
      if (!saved) {
        throw const ShortcutStorageException(
          'Local shortcut save was rejected.',
        );
      }
    } catch (error) {
      if (error is ShortcutStorageException) {
        rethrow;
      }
      throw const ShortcutStorageException(
        'Local shortcut save failed. Please try again.',
      );
    }
  }
}

class MemoryShortcutRepository implements ShortcutRepository {
  MemoryShortcutRepository([List<ShortcutEntry>? initialEntries])
    : _entries = List<ShortcutEntry>.from(
        initialEntries ?? const <ShortcutEntry>[],
      );

  List<ShortcutEntry> _entries;

  @override
  Future<List<ShortcutEntry>> loadShortcuts() async {
    return List<ShortcutEntry>.from(_entries);
  }

  @override
  Future<void> saveShortcuts(List<ShortcutEntry> entries) async {
    _entries = List<ShortcutEntry>.from(entries);
  }
}

abstract class YoutubeLauncher {
  Future<void> openShortcut(ShortcutEntry entry);
}

class YoutubeLauncherService implements YoutubeLauncher {
  const YoutubeLauncherService();

  static const String _youtubePackage = 'com.google.android.youtube';

  @override
  Future<void> openShortcut(ShortcutEntry entry) async {
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: entry.canonicalUrl,
        package: _youtubePackage,
        flags: <int>[
          Flag.FLAG_ACTIVITY_NEW_TASK,
          Flag.FLAG_ACTIVITY_CLEAR_TASK,
        ],
      );
      await intent.launch();
    } catch (_) {
      throw const YoutubeLaunchException(
        'The YouTube app could not be opened. Check that it is installed and enabled on this device.',
      );
    }
  }
}

class YoutubeUrlFormatter {
  const YoutubeUrlFormatter();

  static final Random _idRandom = Random();

  ShortcutEntry createEntry({
    required String nameInput,
    required String urlInput,
  }) {
    return _buildEntry(nameInput: nameInput, urlInput: urlInput);
  }

  ShortcutEntry updateEntry({
    required ShortcutEntry existingEntry,
    required String nameInput,
    required String urlInput,
  }) {
    return _buildEntry(
      nameInput: nameInput,
      urlInput: urlInput,
      existingId: existingEntry.id,
      existingCreatedAtIso: existingEntry.createdAtIso,
    );
  }

  ShortcutEntry _buildEntry({
    required String nameInput,
    required String urlInput,
    String? existingId,
    String? existingCreatedAtIso,
  }) {
    final String trimmedName = nameInput.trim();
    if (trimmedName.isEmpty) {
      throw const ShortcutValidationException(
        'Enter a shortcut name before saving.',
      );
    }

    final String normalizedInput = urlInput.trim();
    if (normalizedInput.isEmpty) {
      throw const ShortcutValidationException(
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
    );
  }

  String _createEntryId(DateTime now) {
    return '${now.microsecondsSinceEpoch}-${_idRandom.nextInt(1 << 32)}';
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
        'Only YouTube links are supported in this app.',
      );
    }

    if (segments.isNotEmpty && segments.first == 'watch') {
      final String? videoId = uri.queryParameters['v'];
      if (videoId == null || videoId.isEmpty) {
        throw const ShortcutValidationException(
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

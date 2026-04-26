import 'dart:async';

import 'package:flutter/services.dart';

abstract class SharedTextSource {
  Future<String?> consumeInitialSharedText();

  Stream<String> get incomingSharedText;
}

class AndroidSharedTextSource implements SharedTextSource {
  AndroidSharedTextSource();

  static const MethodChannel _methodChannel = MethodChannel(
    'in.sreerajp.sreerajp_youtube_shortcut/share_intent',
  );
  static const EventChannel _eventChannel = EventChannel(
    'in.sreerajp.sreerajp_youtube_shortcut/share_intent_events',
  );

  Stream<String>? _broadcastStream;

  @override
  Future<String?> consumeInitialSharedText() async {
    try {
      return await _methodChannel.invokeMethod<String>(
        'consumeInitialSharedText',
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Stream<String> get incomingSharedText {
    return _broadcastStream ??= _eventChannel
        .receiveBroadcastStream()
        .map<String>((dynamic event) => event as String);
  }
}

class NoOpSharedTextSource implements SharedTextSource {
  const NoOpSharedTextSource();

  @override
  Future<String?> consumeInitialSharedText() async => null;

  @override
  Stream<String> get incomingSharedText => const Stream<String>.empty();
}

String? extractFirstUrlOrRaw(String input) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final RegExp urlPattern = RegExp(r'https?://\S+', caseSensitive: false);
  final RegExpMatch? match = urlPattern.firstMatch(trimmed);
  if (match == null) {
    return trimmed;
  }

  final String matchedUrl = match.group(0)!;
  return matchedUrl.replaceFirst(RegExp(r'[.,;:!?\)\]\}>]+$'), '');
}

bool looksLikeYoutubeUrl(String input) {
  final String lower = input.trim().toLowerCase();
  if (lower.isEmpty) {
    return false;
  }
  return lower.contains('youtube.com/') ||
      lower.contains('youtu.be/') ||
      lower.contains('youtube-nocookie.com/') ||
      lower.contains('music.youtube.com/');
}

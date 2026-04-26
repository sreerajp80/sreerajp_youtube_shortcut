import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import '../core/errors/app_exception.dart';
import 'shortcut_models.dart';

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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/about_constants.dart';
import 'src/app_shell.dart';
import 'src/backup_service.dart';
import 'src/share_intent_service.dart';
import 'src/shortcut_models.dart';
import 'src/shortcut_repository.dart';
import 'src/shortcut_store.dart';
import 'src/youtube_launcher_service.dart';
import 'src/youtube_url_formatter.dart';

const String _authorLabel = String.fromEnvironment(
  'APP_AUTHOR',
  defaultValue: AboutConstants.defaultAuthor,
);
const String _aiUsedLabel = String.fromEnvironment(
  'APP_AI_USED',
  defaultValue: AboutConstants.defaultAiUsed,
);

const MethodChannel _buildMetadataChannel = MethodChannel(
  'in.sreerajp.sreerajp_youtube_shortcut/build_metadata',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureGlobalErrorHandling();

  try {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final _BuildMetadata buildMetadata = await _readBuildMetadataFromPlatform();
    final ShortcutStore store = ShortcutStore(
      repository: SharedPreferencesShortcutRepository(preferences),
      formatter: const YoutubeUrlFormatter(),
      launcher: const YoutubeLauncherService(),
      backupService: const ShortcutBackupService(),
      backupGateway: AndroidBackupFileGateway(),
    );

    await store.load();

    final AboutInfo aboutInfo = AboutInfo(
      author: _authorLabel,
      version: packageInfo.version,
      buildNumber: _resolveBuildNumber(
        packageInfo: packageInfo,
        buildMetadata: buildMetadata,
      ),
      buildDate: _resolveBuildDateLabel(buildMetadata.buildDate),
      aiUsed: _aiUsedLabel,
    );

    runApp(
      ShortcutApp(
        store: store,
        aboutInfo: aboutInfo,
        sharedTextSource: AndroidSharedTextSource(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('Bootstrap failure: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(
      const FatalApp(
        details:
            'The app could not finish startup. Check local storage and package metadata.',
      ),
    );
  }
}

Future<_BuildMetadata> _readBuildMetadataFromPlatform() async {
  try {
    final Map<String, String>? metadata = await _buildMetadataChannel
        .invokeMapMethod<String, String>('getBuildMetadata');

    if (metadata == null) {
      return const _BuildMetadata(pubspecBuildNumber: '', buildDate: '');
    }

    return _BuildMetadata(
      pubspecBuildNumber: (metadata['pubspecBuildNumber'] ?? '').trim(),
      buildDate: (metadata['buildDate'] ?? '').trim(),
    );
  } on MissingPluginException {
    return const _BuildMetadata(pubspecBuildNumber: '', buildDate: '');
  } on PlatformException {
    return const _BuildMetadata(pubspecBuildNumber: '', buildDate: '');
  }
}

String _resolveBuildNumber({
  required PackageInfo packageInfo,
  required _BuildMetadata buildMetadata,
}) {
  final String buildNumberFromBuildSystem = buildMetadata.pubspecBuildNumber
      .trim();
  if (buildNumberFromBuildSystem.isNotEmpty) {
    return buildNumberFromBuildSystem;
  }

  return packageInfo.buildNumber;
}

String _resolveBuildDateLabel(String buildDateFromBuildSystem) {
  final String trimmedBuildDate = buildDateFromBuildSystem.trim();
  if (trimmedBuildDate.isNotEmpty) {
    return trimmedBuildDate;
  }

  return _formatDate(DateTime.now());
}

String _formatDate(DateTime date) {
  final String year = date.year.toString().padLeft(4, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

void _configureGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      debugPrint('Unhandled Flutter framework error.');
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    debugPrint('Unhandled async error: $error');
    debugPrintStack(stackTrace: stackTrace);
    return true;
  };
}

class _BuildMetadata {
  const _BuildMetadata({
    required this.pubspecBuildNumber,
    required this.buildDate,
  });

  final String pubspecBuildNumber;
  final String buildDate;
}

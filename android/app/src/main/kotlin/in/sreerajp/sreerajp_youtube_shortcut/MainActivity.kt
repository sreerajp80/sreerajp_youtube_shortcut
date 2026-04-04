package `in`.sreerajp.sreerajp_youtube_shortcut

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BUILD_METADATA_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method == "getBuildMetadata") {
                result.success(
                    mapOf(
                        "pubspecBuildNumber" to BuildConfig.PUBSPEC_BUILD_NUMBER,
                        "buildDate" to BuildConfig.APP_BUILD_DATE,
                    ),
                )
            } else {
                result.notImplemented()
            }
        }
    }

    companion object {
        private const val BUILD_METADATA_CHANNEL =
            "in.sreerajp.sreerajp_youtube_shortcut/build_metadata"
    }
}
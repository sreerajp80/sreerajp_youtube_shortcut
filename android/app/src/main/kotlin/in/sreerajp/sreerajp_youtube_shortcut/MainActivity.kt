package `in`.sreerajp.sreerajp_youtube_shortcut

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity : FlutterFragmentActivity() {

    private var pendingSharedText: String? = null
    private var sharedTextEventSink: EventChannel.EventSink? = null

    private var pendingBackupResult: MethodChannel.Result? = null
    private var pendingBackupContent: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingSharedText = extractSharedText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val sharedText = extractSharedText(intent) ?: return
        val sink = sharedTextEventSink
        if (sink != null) {
            sink.success(sharedText)
        } else {
            pendingSharedText = sharedText
        }
    }

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHARE_INTENT_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "consumeInitialSharedText" -> {
                    val text = pendingSharedText
                    pendingSharedText = null
                    result.success(text)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHARE_INTENT_EVENT_CHANNEL,
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                sharedTextEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                sharedTextEventSink = null
            }
        })

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BACKUP_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "exportJson" -> handleExportJson(call.argument<String>("filename"), call.argument<String>("content"), result)
                "importJson" -> handleImportJson(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun handleExportJson(
        suggestedFilename: String?,
        content: String?,
        result: MethodChannel.Result,
    ) {
        if (suggestedFilename.isNullOrBlank() || content == null) {
            result.error("INVALID_ARGUMENTS", "Filename and content are required.", null)
            return
        }
        if (pendingBackupResult != null) {
            result.error("BUSY", "Another backup operation is already in progress.", null)
            return
        }

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
            putExtra(Intent.EXTRA_TITLE, suggestedFilename)
        }

        try {
            pendingBackupResult = result
            pendingBackupContent = content
            startActivityForResult(intent, REQUEST_EXPORT_BACKUP)
        } catch (_: ActivityNotFoundException) {
            pendingBackupResult = null
            pendingBackupContent = null
            result.error(
                "NO_PICKER",
                "No system file picker is available on this device.",
                null,
            )
        }
    }

    private fun handleImportJson(result: MethodChannel.Result) {
        if (pendingBackupResult != null) {
            result.error("BUSY", "Another backup operation is already in progress.", null)
            return
        }

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(
                Intent.EXTRA_MIME_TYPES,
                arrayOf("application/json", "text/json", "text/plain", "application/octet-stream"),
            )
        }

        try {
            pendingBackupResult = result
            startActivityForResult(intent, REQUEST_IMPORT_BACKUP)
        } catch (_: ActivityNotFoundException) {
            pendingBackupResult = null
            result.error(
                "NO_PICKER",
                "No system file picker is available on this device.",
                null,
            )
        }
    }

    @Deprecated("Result delivery for SAF picker still uses onActivityResult on FlutterActivity.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            REQUEST_EXPORT_BACKUP -> finishExport(resultCode, data)
            REQUEST_IMPORT_BACKUP -> finishImport(resultCode, data)
        }
    }

    private fun finishExport(resultCode: Int, data: Intent?) {
        val pending = pendingBackupResult ?: return
        val content = pendingBackupContent
        pendingBackupResult = null
        pendingBackupContent = null

        if (resultCode != Activity.RESULT_OK || data?.data == null || content == null) {
            pending.success(null)
            return
        }

        val targetUri: Uri = data.data!!
        try {
            contentResolver.openOutputStream(targetUri, "wt")?.use { stream ->
                stream.write(content.toByteArray(Charsets.UTF_8))
                stream.flush()
            } ?: run {
                pending.error("WRITE_FAILED", "Could not open the selected file for writing.", null)
                return
            }
            pending.success(displayNameFor(targetUri))
        } catch (error: IOException) {
            pending.error("WRITE_FAILED", error.localizedMessage ?: "Backup file write failed.", null)
        } catch (error: SecurityException) {
            pending.error("WRITE_FAILED", error.localizedMessage ?: "Backup file write was blocked.", null)
        }
    }

    private fun finishImport(resultCode: Int, data: Intent?) {
        val pending = pendingBackupResult ?: return
        pendingBackupResult = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            pending.success(null)
            return
        }

        val sourceUri: Uri = data.data!!
        try {
            val contents = contentResolver.openInputStream(sourceUri)?.use { stream ->
                stream.bufferedReader(Charsets.UTF_8).readText()
            }
            if (contents == null) {
                pending.error("READ_FAILED", "Could not open the selected file for reading.", null)
                return
            }
            pending.success(
                mapOf(
                    "contents" to contents,
                    "displayName" to (displayNameFor(sourceUri) ?: ""),
                ),
            )
        } catch (error: IOException) {
            pending.error("READ_FAILED", error.localizedMessage ?: "Backup file read failed.", null)
        } catch (error: SecurityException) {
            pending.error("READ_FAILED", error.localizedMessage ?: "Backup file read was blocked.", null)
        }
    }

    private fun displayNameFor(uri: Uri): String? {
        return try {
            contentResolver.query(
                uri,
                arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst() && cursor.columnCount > 0) {
                    cursor.getString(0)
                } else {
                    null
                }
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun extractSharedText(intent: Intent?): String? {
        if (intent == null) return null
        if (intent.action != Intent.ACTION_SEND) return null
        if (intent.type != "text/plain") return null
        val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: return null
        return text.takeIf { it.isNotBlank() }
    }

    companion object {
        private const val BUILD_METADATA_CHANNEL =
            "in.sreerajp.sreerajp_youtube_shortcut/build_metadata"
        private const val SHARE_INTENT_CHANNEL =
            "in.sreerajp.sreerajp_youtube_shortcut/share_intent"
        private const val SHARE_INTENT_EVENT_CHANNEL =
            "in.sreerajp.sreerajp_youtube_shortcut/share_intent_events"
        private const val BACKUP_CHANNEL =
            "in.sreerajp.sreerajp_youtube_shortcut/backup_io"

        private const val REQUEST_EXPORT_BACKUP = 0xB1
        private const val REQUEST_IMPORT_BACKUP = 0xB2
    }
}

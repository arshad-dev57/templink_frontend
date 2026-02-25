// android/app/src/main/kotlin/com/example/templink/MainActivity.kt

package com.example.templink

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.templink/media_store"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSdkVersion" -> {
                    result.success(Build.VERSION.SDK_INT)
                }

                "saveToDownloads" -> {
                    try {
                        val fileName = call.argument<String>("fileName") ?: "resume.pdf"
                        val mimeType = call.argument<String>("mimeType") ?: "application/pdf"
                        val bytes = call.argument<ByteArray>("bytes") ?: ByteArray(0)

                        val savedPath = saveToDownloads(fileName, mimeType, bytes)
                        result.success(savedPath)
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", e.message, null)
                    }
                }

                "mediaScan" -> {
                    try {
                        val filePath = call.argument<String>("filePath") ?: ""
                        mediaScan(filePath)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SCAN_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun saveToDownloads(
        fileName: String,
        mimeType: String,
        bytes: ByteArray
    ): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+ (MediaStore)
            val contentValues = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, mimeType)
                put(MediaStore.Downloads.IS_PENDING, 1)
                put(
                    MediaStore.Downloads.RELATIVE_PATH,
                    Environment.DIRECTORY_DOWNLOADS + File.separator + "Templink"
                )
            }

            val resolver = contentResolver
            val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            val itemUri = resolver.insert(collection, contentValues)
                ?: throw Exception("Failed to create MediaStore entry")

            resolver.openOutputStream(itemUri)?.use { outputStream ->
                outputStream.write(bytes)
            }

            contentValues.clear()
            contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(itemUri, contentValues, null, null)

            itemUri.toString()
        } else {
            // Android 9 and below
            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!downloadsDir.exists()) {
                downloadsDir.mkdirs()
            }

            val file = File(downloadsDir, fileName)
            FileOutputStream(file).use { outputStream ->
                outputStream.write(bytes)
            }

            mediaScan(file.absolutePath)
            file.absolutePath
        }
    }

    private fun mediaScan(filePath: String) {
        val file = File(filePath)
        val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
        intent.data = Uri.fromFile(file)
        sendBroadcast(intent)
    }
}
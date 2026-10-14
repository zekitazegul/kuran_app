package com.zekitazegul.kuranapp

import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private val storageExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val storage = ReadingStorage(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.zekitazegul.kuranapp/reading").setMethodCallHandler { call, result ->
            storageExecutor.execute {
                try {
                    val value: Any? = when (call.method) {
                        "load" -> storage.load()
                        "savePage" -> storage.savePage(requireNotNull(call.argument<Int>("page"))).let { null }
                        "saveBookmarks" -> storage.saveBookmarks(requireNotNull(call.argument<List<Int>>("pages"))).let { null }
                        "acknowledge" -> storage.acknowledge().let { null }
                        "downloadPage" -> storage.downloadPage(requireNotNull(call.argument<Int>("page"))).let { null }
                        else -> {
                            runOnUiThread { result.notImplemented() }
                            return@execute
                        }
                    }
                    runOnUiThread { result.success(value) }
                } catch (error: Exception) {
                    runOnUiThread { result.error("READING_ERROR", error.message, null) }
                }
            }
        }
    }

    override fun onDestroy() {
        storageExecutor.shutdown()
        super.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        // Keep the screen awake while the app is in the foreground for reading.
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun onPause() {
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        super.onPause()
    }
}

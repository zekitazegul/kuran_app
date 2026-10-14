package com.zekitazegul.kuranapp

import android.view.WindowManager
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private val storageExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.zekitazegul.kuranapp/reading").setMethodCallHandler { call, result ->
            if (call.method == "openSupport") {
                try {
                    val uri = Uri.parse(requireNotNull(call.argument<String>("url")))
                    require(uri.scheme == "https" && uri.host in setOf(
                        "buymeacoffee.com", "www.buymeacoffee.com", "ko-fi.com", "www.ko-fi.com"
                    )) { "Destek bağlantısı geçerli değil." }
                    startActivity(Intent(Intent.ACTION_VIEW, uri))
                    result.success(null)
                } catch (error: Exception) {
                    result.error("SUPPORT_ERROR", "Destek bağlantısı açılamadı.", null)
                }
                return@setMethodCallHandler
            }
            storageExecutor.execute {
                try {
                    val storage = ReadingStorage(applicationContext, call.argument<String>("edition"))
                    val value: Any? = when (call.method) {
                        "selectEdition" -> storage.selectEdition(requireNotNull(call.argument<String>("id")))
                        "load" -> storage.load()
                        "savePage" -> storage.savePage(requireNotNull(call.argument<Int>("page"))).let { null }
                        "saveBookmarks" -> storage.saveBookmarks(requireNotNull(call.argument<List<Int>>("pages"))).let { null }
                        "acknowledgeGuide" -> storage.acknowledgeGuide().let { null }
                        "setPageAnimations" -> storage.setPageAnimations(requireNotNull(call.argument<Boolean>("enabled"))).let { null }
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

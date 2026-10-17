package com.zekitazegul.kuranapp

import android.os.Handler
import android.os.HandlerThread
import android.view.WindowManager
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var prayerSpeech: android.speech.tts.TextToSpeech? = null
    private var prayerResult: MethodChannel.Result? = null
    private fun stopPrayer() {
        prayerSpeech?.stop()
        prayerSpeech?.shutdown()
        prayerSpeech = null
        prayerResult?.success(null)
        prayerResult = null
    }
    private val audioThread = HandlerThread("quran-audio").apply { start() }
    private val audioHandler = Handler(audioThread.looper)
    private var audioStorage: QuranAudioStorage? = null
    private var mealPdf: MealPdf? = null
    private val storageExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mealPdf = MealPdf(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.zekitazegul.kuranapp/meal", MealWebViewFactory(flutterEngine.dartExecutor.binaryMessenger))
        val readingChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.zekitazegul.kuranapp/reading")
        readingChannel.setMethodCallHandler { call, result ->
            if (call.method == "loadMealPreferences" || call.method == "saveMealPreferences") {
                try {
                    val prefs = getSharedPreferences("meal-v1", MODE_PRIVATE)
                    if (call.method == "saveMealPreferences") {
                        val surah = requireNotNull(call.argument<Int>("surah"))
                        val verse = requireNotNull(call.argument<Int>("verse"))
                        val zoom = requireNotNull(call.argument<Int>("zoom"))
                        require(surah in 1..114 && verse in 0..286 && zoom in 80..200)
                        check(prefs.edit().putInt("surah", surah).putInt("verse", verse).putInt("zoom", zoom).commit())
                    }
                    result.success(mapOf("surah" to prefs.getInt("surah", 1),
                        "verse" to prefs.getInt("verse", 0), "zoom" to prefs.getInt("zoom", 110)))
                } catch (error: Exception) { result.error("MEAL_ERROR", error.message, null) }
                return@setMethodCallHandler
            }
            if (call.method == "stopHatimPrayer") {
                stopPrayer()
                result.success(null)
                return@setMethodCallHandler
            }
            if (call.method == "speakHatimPrayer") {
                stopPrayer()
                prayerResult = result
                val text = call.argument<String>("text") ?: ""
                prayerSpeech = android.speech.tts.TextToSpeech(applicationContext) { status ->
                    runOnUiThread {
                        val speech = prayerSpeech
                        if (speech != null && prayerResult != null) {
                            val language = if (status == android.speech.tts.TextToSpeech.SUCCESS)
                                speech.setLanguage(java.util.Locale.forLanguageTag("tr-TR")) else -1
                            if (language < 0) {
                                prayerResult?.error("SPEECH_ERROR", "Türkçe ses kullanılamıyor.", null)
                                prayerResult = null
                                stopPrayer()
                            } else {
                                speech.setOnUtteranceProgressListener(object : android.speech.tts.UtteranceProgressListener() {
                                    override fun onStart(id: String?) {}
                                    override fun onDone(id: String?) { runOnUiThread { stopPrayer() } }
                                    @Deprecated("Deprecated in Java")
                                    override fun onError(id: String?) { runOnUiThread {
                                        prayerResult?.error("SPEECH_ERROR", "Dua okunamadı.", null)
                                        prayerResult = null
                                        stopPrayer()
                                    } }
                                })
                                if (speech.speak(text, android.speech.tts.TextToSpeech.QUEUE_FLUSH, null, "hatim") == android.speech.tts.TextToSpeech.ERROR) {
                                    prayerResult?.error("SPEECH_ERROR", "Dua okunamadı.", null)
                                    prayerResult = null
                                    stopPrayer()
                                }
                            }
                        }
                    }
                }
                return@setMethodCallHandler
            }
            if (call.method in setOf("loadAudio", "downloadAudio", "playAudio", "stopAudio", "removeAudio", "selectAudioReciter")) {
                audioHandler.post {
                    try {
                        val audio = audioStorage ?: QuranAudioStorage(applicationContext).also { audioStorage = it }
                        val value: Any? = when (call.method) {
                            "loadAudio" -> audio.load()
                            "selectAudioReciter" -> audio.selectReciter(requireNotNull(call.argument<String>("id"))).let { null }
                            "downloadAudio" -> audio.download(requireNotNull(call.argument<String>("id"))).let { null }
                            "playAudio" -> audio.play(requireNotNull(call.argument<String>("id"))).let { null }
                            "removeAudio" -> audio.remove(requireNotNull(call.argument<String>("id"))).let { null }
                            else -> audio.requestStop().let { null }
                        }
                        runOnUiThread { result.success(value) }
                    } catch (error: Exception) {
                        runOnUiThread { result.error("AUDIO_ERROR", error.message, null) }
                    }
                }
                return@setMethodCallHandler
            }
            if (call.method == "openSupport") {
                try {
                    val uri = Uri.parse(requireNotNull(call.argument<String>("url")))
                    require(uri.scheme == "https" && uri.host in setOf(
                        "buymeacoffee.com", "www.buymeacoffee.com", "ko-fi.com", "www.ko-fi.com",
                        "zekitazegul.github.io"
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
                    val storage = ReadingStorage(applicationContext, call.argument<String>("edition")) { id, bytes, total ->
                        runOnUiThread {
                            readingChannel.invokeMethod("downloadProgress", mapOf(
                                "edition" to id, "bytes" to bytes, "total" to total))
                        }
                    }
                    val value: Any? = when (call.method) {
                        "selectEdition" -> storage.selectEdition(requireNotNull(call.argument<String>("id")))
                        "load" -> storage.load()
                        "saveReadingHistory" -> storage.saveReadingHistory(requireNotNull(call.argument<List<Map<String, Any?>>>("entries"))).let { null }
                        "saveUiPreferences" -> storage.saveUiPreferences(requireNotNull(call.argument<Map<String, Any?>>("preferences"))).let { null }
                        "findDownloadedEdition" -> storage.findDownloadedEdition()
                        "setLanguage" -> storage.setLanguage(requireNotNull(call.argument<String>("language"))).let { null }
                        "saveHatim" -> storage.saveHatim(requireNotNull(call.argument<List<Int>>("pages")), requireNotNull(call.argument<Int>("resume"))).let { null }
                        "savePage" -> storage.savePage(requireNotNull(call.argument<Int>("page"))).let { null }
                        "saveBookmarks" -> storage.saveBookmarks(requireNotNull(call.argument<List<Int>>("pages"))).let { null }
                        "acknowledgeUpdate" -> storage.acknowledgeUpdate().let { null }
                        "acknowledgeGuide" -> storage.acknowledgeGuide().let { null }
                        "setPageEffect" -> storage.setPageEffect(requireNotNull(call.argument<String>("effect"))).let { null }
                        "setPageAnimations" -> storage.setPageAnimations(requireNotNull(call.argument<Boolean>("enabled"))).let { null }
                        "acknowledge" -> storage.acknowledge().let { null }
                        "removeDownload" -> storage.removeDownload().let { null }
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
        mealPdf?.close()
        stopPrayer()
        audioHandler.post { audioStorage?.closeAfterVerse { audioThread.quitSafely() } ?: audioThread.quitSafely() }
        storageExecutor.shutdown()
        super.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        // Keep the screen awake while the app is in the foreground for reading.
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun onPause() {
        stopPrayer()
        audioHandler.post { audioStorage?.requestStop() }
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        super.onPause()
    }
}

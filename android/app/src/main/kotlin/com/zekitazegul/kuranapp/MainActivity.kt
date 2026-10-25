package com.zekitazegul.kuranapp

import android.os.Handler
import android.os.HandlerThread
import android.view.WindowManager
import android.content.Intent
import android.net.Uri
import android.speech.RecognizerIntent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var voiceResult: MethodChannel.Result? = null
    private val voiceRequest = 8401
    fun installUpdate(apk: java.io.File) {
        val uri = androidx.core.content.FileProvider.getUriForFile(this, "$packageName.apkshare", apk)
        startActivityForResult(Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }, 7402)
    }
    private lateinit var updater: AppUpdater
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == voiceRequest) {
            val reply = voiceResult; voiceResult = null
            reply?.success(if (resultCode == RESULT_OK)
                data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS) ?: arrayListOf<String>()
                else arrayListOf<String>())
            return
        }
        if (::updater.isInitialized) updater.onActivityResult(requestCode)
    }

    private val prayerPlayer by lazy { HatimPrayerPlayer(this) }
    private fun stopPrayer() = prayerPlayer.stop()
    private val audioThread = HandlerThread("quran-audio").apply { start() }
    private val audioHandler = Handler(audioThread.looper)
    private var audioStorage: QuranAudioStorage? = null
    private var mealPdf: MealPdf? = null
    private val storageExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        updater = AppUpdater(this, MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.zekitazegul.kuranapp/update"))
        ApkSharing(this, MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.zekitazegul.kuranapp/share"))
        mealPdf = MealPdf(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.zekitazegul.kuranapp/meal", MealWebViewFactory(flutterEngine.dartExecutor.binaryMessenger))
        val readingChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.zekitazegul.kuranapp/reading")
        readingChannel.setMethodCallHandler { call, result ->
            if (call.method == "recognizeVoice") {
                if (voiceResult != null) { result.error("VOICE_BUSY", null, null); return@setMethodCallHandler }
                val language = call.argument<String>("language") ?: "tr-TR"
                val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE, language)
                    putExtra(RecognizerIntent.EXTRA_PROMPT, call.argument<String>("prompt"))
                    putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
                }
                voiceResult = result
                try { startActivityForResult(intent, voiceRequest) }
                catch (_: android.content.ActivityNotFoundException) {
                    voiceResult = null; result.error("VOICE_UNAVAILABLE", null, null)
                }
                catch (_: SecurityException) {
                    voiceResult = null; result.error("VOICE_UNAVAILABLE", null, null)
                }
                return@setMethodCallHandler
            }
            if (call.method == "setKeepScreenOn") {
                try {
                    val enabled = requireNotNull(call.argument<Boolean>("enabled"))
                    check(getSharedPreferences("reading-computer-v1", MODE_PRIVATE).edit().putBoolean("keepScreenOn", enabled).commit())
                    applyScreenPreference()
                    result.success(null)
                } catch (e: Exception) { result.error("PREFERENCE_ERROR", "Could not save preference", null) }
                return@setMethodCallHandler
            }
            if (call.method == "prayerAudioDirectory") {
                result.success(java.io.File(filesDir, "prayer-audio-v1").absolutePath)
                return@setMethodCallHandler
            }
            if (call.method == "isHatimPrayerDownloaded") {
                storageExecutor.execute {
                    val ready = HatimPrayerPlayer.isDownloaded(applicationContext)
                    runOnUiThread { result.success(ready) }
                }
                return@setMethodCallHandler
            }
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
            if (call.method == "playHatimPrayer") {
                prayerPlayer.play(result)
                return@setMethodCallHandler
            }
            if (call.method in setOf("pauseAudio", "resumeAudio", "replayAudio", "nextAudioVerse", "stopAudioImmediately", "loadAudio", "downloadAudio", "playAudio", "playAudioSelection", "playAudioRange", "advanceMemorization", "stopAudio", "removeAudio", "selectAudioReciter")) {
                audioHandler.post {
                    try {
                        val audio = audioStorage ?: QuranAudioStorage(applicationContext).also { audioStorage = it }
                        val value: Any? = when (call.method) {
                            "loadAudio" -> audio.load()
                            "selectAudioReciter" -> audio.selectReciter(requireNotNull(call.argument<String>("id"))).let { null }
                            "downloadAudio" -> audio.download(requireNotNull(call.argument<String>("id"))).let { null }
                            "pauseAudio" -> audio.pause().let { null }
                            "resumeAudio" -> audio.resume().let { null }
                            "replayAudio" -> audio.replay().let { null }
                            "nextAudioVerse" -> audio.nextVerse()
                            "stopAudioImmediately" -> audio.stopImmediately().let { null }
                            "playAudio" -> audio.play(requireNotNull(call.argument<String>("id")), call.argument<Int>("repetitions") ?: 1).let { null }
                            "playAudioSelection" -> audio.playSelection(requireNotNull(call.argument<List<String>>("ids")),
                                call.argument<Int>("repetitions") ?: 1, call.argument<Boolean>("cumulative") == true).let { null }
                            "playAudioRange" -> audio.playRange(
                                requireNotNull(call.argument<Int>("surah")), requireNotNull(call.argument<Int>("first")),
                                requireNotNull(call.argument<Int>("last")), requireNotNull(call.argument<Int>("repetitions")), call.argument<Boolean>("cumulative") == true).let { null }
                            "advanceMemorization" -> audio.advanceMemorization().let { null }
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
        voiceResult?.success(arrayListOf<String>()); voiceResult = null
        mealPdf?.close()
        stopPrayer()
        audioHandler.post { audioStorage?.closeAfterVerse { audioThread.quitSafely() } ?: audioThread.quitSafely() }
        storageExecutor.shutdown()
        super.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        applyScreenPreference()
    }

    private fun applyScreenPreference() {
        if (getSharedPreferences("reading-computer-v1", MODE_PRIVATE).getBoolean("keepScreenOn", true)) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun onPause() {
        stopPrayer()
        audioHandler.post { audioStorage?.requestStop() }
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        super.onPause()
    }
}

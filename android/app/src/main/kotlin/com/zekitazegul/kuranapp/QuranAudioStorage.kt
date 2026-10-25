package com.zekitazegul.kuranapp

import android.content.Context
import android.net.Uri
import android.os.Looper
import android.util.Log
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.PlaybackException
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.extractor.ExtractorsFactory
import androidx.media3.extractor.mp3.Mp3Extractor
import org.json.JSONObject
import java.io.File
import java.net.URL
import java.security.MessageDigest
import javax.net.ssl.HttpsURLConnection

/** Only recordings declared in the packaged catalog can be stored or played. */
class QuranAudioStorage(private val context: Context) {
    private val directory = File(context.filesDir, "audio-v1").apply { mkdirs() }
    private val definition = JSONObject(context.assets.open("flutter_assets/assets/audio.json")
        .bufferedReader().use { it.readText() })
    private val catalog = definition.getJSONArray("tracks")
    private val reciters = definition.getJSONArray("reciters")
    private val preferences = context.getSharedPreferences("quran-audio-v1", Context.MODE_PRIVATE)
    private val reciterIds = (0 until reciters.length()).map { reciters.getJSONObject(it).getString("id") }.toSet()
    private var reciter = AudioReciterSelection.restore(preferences.getString("reciter", null), reciterIds).also {
        if (preferences.getString("reciter", null) != it) check(preferences.edit().putString("reciter", it).commit())
    }
    fun selectReciter(id: String) {
        check(playing == null) { "Current verse must finish first" }
        require((0 until reciters.length()).any { reciters.getJSONObject(it).getString("id") == id })
        check(preferences.edit().putString("reciter", id).commit())
        reciter = id
    }
    private var player: ExoPlayer? = null
    private var queue: VersePlaybackQueue<JSONObject>? = null
    private var onStopped: (() -> Unit)? = null
    private var playbackError: String? = null
    private var playing: String? = null
    private val recordings by lazy { (0 until catalog.length()).map { catalog.getJSONObject(it) } }
    private val verses by lazy { recordings.filter { !it.isNull("verse") } }
    private val verseGroups by lazy { verses.groupBy { it.getString("reciter") + ":" + it.getInt("surah") } }
    private val expectedCounts by lazy { (0 until pageVerses.length()).flatMap { p ->
        val refs = pageVerses.getJSONArray(p)
        (0 until refs.length()).map { refs.getJSONObject(it) }
    }.groupBy { it.getInt("surah") }.mapValues { (_, refs) -> refs.maxOf { it.getInt("verse") } } }
    private val chapters by lazy { verseGroups.values.filter { entries ->
        entries.map { it.getInt("verse") }.toSet().size == expectedCounts[entries.first().getInt("surah")]
    }.map { entries ->
        val surah = entries.first().getInt("surah")
        val reader = entries.first().getString("reciter")
        JSONObject().put("id", reader + "_surah_" + surah.toString().padStart(3, '0'))
            .put("reciter", reader).put("surah", surah).put("verse", JSONObject.NULL)
            .put("bytes", entries.sumOf { it.getLong("bytes") })
    } + recordings.filter { it.isNull("verse") } }
    private val tracksById by lazy { (verses + chapters).associateBy { it.getString("id") } }
    private val pageVerses by lazy { JSONObject(context.assets.open("flutter_assets/assets/page_verses.json")
        .bufferedReader().use { it.readText() }).getJSONArray("pages") }
    private val pages by lazy { (0 until reciters.length()).flatMap { r ->
        val reader = reciters.getJSONObject(r).getString("id")
        (0 until pageVerses.length()).mapNotNull { page ->
            val refs = pageVerses.getJSONArray(page)
            val entries = (0 until refs.length()).mapNotNull { i -> tracksById[verseKey(reader, refs.getJSONObject(i))] }
            if (entries.size != refs.length()) return@mapNotNull null
            JSONObject().put("id", "${reader}_page_$page").put("reciter", reader).put("page", page)
                .put("surah", refs.getJSONObject(0).getInt("surah")).put("verse", JSONObject.NULL)
                .put("bytes", entries.sumOf { it.getLong("bytes") })
        }
    } }
    private fun verseKey(reader: String, ref: JSONObject): String =
        reader + "_" + ref.getInt("surah").toString().padStart(3, '0') + ref.getInt("verse").toString().padStart(3, '0')
    private fun verseFor(reader: String, ref: JSONObject): JSONObject = checkNotNull(tracksById[verseKey(reader, ref)])
    private fun track(id: String): JSONObject {
        require(id.matches(Regex("[a-z0-9_-]{1,80}")))
        return tracksById[id] ?: pages.firstOrNull { it.getString("id") == id } ?: error("Unknown audio")
    }
    private fun sequence(id: String): List<JSONObject> {
        val entry = track(id)
        if (entry.has("page")) {
            val refs = pageVerses.getJSONArray(entry.getInt("page"))
            return (0 until refs.length()).map { verseFor(entry.getString("reciter"), refs.getJSONObject(it)) }
        }
        if (entry.has("url")) return listOf(entry)
        return if (entry.isNull("verse")) checkNotNull(verseGroups[entry.getString("reciter") + ":" + entry.getInt("surah")])
            .sortedBy { it.getInt("verse") } else listOf(entry)
    }
    private fun file(id: String) = File(directory, "$id.audio")
    private fun downloaded(entry: JSONObject): Boolean = file(entry.getString("id")).let {
        it.isFile && it.length() == entry.getLong("bytes")
    }
    fun load(): Map<String, Any?> {
        val selectedVerses = recordings.filter { it.getString("reciter") == reciter }
        val selectedChapters = (chapters + pages).filter { it.getString("reciter") == reciter }
        val stored = selectedVerses.filter { downloaded(it) }.map { it.getString("id") }.toMutableSet()
        stored.addAll(selectedChapters.filter { entry -> sequence(entry.getString("id")).all { it.getString("id") in stored } }.map { it.getString("id") })
        return mapOf(
            "reciter" to reciter,
            "reciters" to (0 until reciters.length()).map { reciters.getJSONObject(it).let { r -> mapOf("id" to r.getString("id"), "name" to r.getString("name")) } },
            "tracks" to (selectedChapters + selectedVerses).distinctBy { it.getString("id") }.map { t -> mapOf("id" to t.getString("id"), "surah" to t.getInt("surah"),
                "verse" to if (t.isNull("verse")) null else t.getInt("verse"),
                "page" to if (t.has("page")) t.getInt("page") else null, "bytes" to t.getLong("bytes")) },
            "downloaded" to stored.toList(), "playing" to playing, "stopPending" to (queue?.stopPending == true),
            "memorizing" to (queue?.cumulative == true),
            "currentVerse" to queue?.current?.let { if (it.isNull("verse")) null else it.getInt("verse") }, "error" to playbackError
        )
    }
    fun download(id: String) {
        check(playing == null) { "Finish playback before downloading" }
        for (entry in sequence(id)) downloadVerse(entry)
    }
    private fun downloadVerse(entry: JSONObject) {
        val id = entry.getString("id")
        val target = file(id)
        val expected = entry.getLong("bytes")
        require(expected in 1L..500_000_000L)
        if (target.isFile && target.length() == expected) return
        val source = URL(entry.getString("url"))
        require(source.protocol == "https" && source.port in setOf(-1, 443))
        val algorithm = if (entry.has("md5")) "MD5" else "SHA-256"
        val hash = when { entry.has("sha256") -> entry.getString("sha256")
            entry.has("md5") -> entry.getString("md5"); else -> null }
        require(hash != null)
        require(hash.matches(Regex(if (algorithm == "SHA-256") "[a-f0-9]{64}" else "[a-f0-9]{32}")))
        var current = source
        var connection: HttpsURLConnection? = null
        val temp = File(directory, "$id.part")
        try {
            for (attempt in 0..4) {
                require(current.protocol == "https" && current.port in setOf(-1, 443) &&
                    (current.host == source.host || (source.host == "archive.org" && current.host.endsWith(".archive.org"))))
                val opened = current.openConnection() as HttpsURLConnection
                connection = opened
                opened.connectTimeout = 20_000; opened.readTimeout = 30_000
                opened.instanceFollowRedirects = false
                if (opened.responseCode !in setOf(301, 302, 303, 307, 308)) break
                val location = opened.getHeaderField("Location")
                opened.disconnect(); connection = null
                check(location != null)
                current = URL(current, location)
            }
            val active = checkNotNull(connection)
            check(active.responseCode == 200) { "Ses indirilemedi." }
            val digest = MessageDigest.getInstance(algorithm)
            var total = 0L
            active.inputStream.use { input -> temp.outputStream().use { output ->
                val buffer = ByteArray(65_536)
                while (true) {
                    val count = input.read(buffer)
                    if (count < 0) break
                    total += count; check(total <= expected)
                    digest.update(buffer, 0, count); output.write(buffer, 0, count)
                }
            } }
            val actual = digest.digest().joinToString("") { "%02x".format(it.toInt() and 255) }
            check(total == expected && actual == hash) { "Ses dosyası doğrulanamadı." }
            check(temp.renameTo(target))
        } finally { connection?.disconnect(); temp.delete() }
    }
    fun play(id: String) {
        check(playing == null) { "Current verse must finish first" }
        val selected = sequence(id)
        check(selected.isNotEmpty() && selected.all { downloaded(it) }) { "Download required" }
        queue = VersePlaybackQueue(selected); playing = id; playbackError = null
        try { playCurrent() } catch (error: Exception) { finish(); throw error }
    }
    fun playRange(surah: Int, first: Int, last: Int, repetitions: Int, cumulative: Boolean = false) {
        check(playing == null) { "Current verse must finish first" }
        require(surah in 1..114 && first in 1..286 && last in first..286 && repetitions in 1..999)
        val selected = (first..last).map { verse ->
            verseFor(reciter, JSONObject().put("surah", surah).put("verse", verse))
        }
        check(selected.all { downloaded(it) }) { "Download required" }
        queue = VersePlaybackQueue(selected, repetitions, cumulative)
        playing = "${reciter}_range_${surah}_${first}_${last}"
        playbackError = null
        try { playCurrent() } catch (error: Exception) { finish(); throw error }
    }
    fun playSelection(ids: List<String>, repetitions: Int = 1, cumulative: Boolean = false) {
        check(playing == null) { "Current verse must finish first" }
        require(ids.isNotEmpty() && ids.size <= 6236 && ids.distinct().size == ids.size)
        val selected = ids.map { id -> track(id).also {
            require(it.has("verse") && id.startsWith("${reciter}_"))
        } }
        check(selected.all { downloaded(it) }) { "Download required" }
        queue = VersePlaybackQueue(selected, repetitions, cumulative)
        playing = "${reciter}_selection"
        playbackError = null
        try { playCurrent() } catch (error: Exception) { finish(); throw error }
    }
    private fun playCurrent() {
        val entry = checkNotNull(queue).current
        val next = ExoPlayer.Builder(context).setLooper(checkNotNull(Looper.myLooper())).build()
        try {
            next.setAudioAttributes(AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_SPEECH)
                .setUsage(C.USAGE_MEDIA).build(), false)
            // Use only the MP3 extractor: some vendor sniffers mistake raw MP3 frames for MIDI.
            val source = ProgressiveMediaSource.Factory(DefaultDataSource.Factory(context),
                ExtractorsFactory { arrayOf(Mp3Extractor()) }).createMediaSource(
                    MediaItem.fromUri(Uri.fromFile(file(entry.getString("id")))))
            next.addListener(object : Player.Listener {
                override fun onPlaybackStateChanged(state: Int) {
                    if (player !== next) return
                    if (state == Player.STATE_READY) Log.i("QuranPlayback", "ready ${entry.getString("id")} duration=${next.duration}")
                    if (state != Player.STATE_ENDED) return
                    Log.i("QuranPlayback", "completed ${entry.getString("id")}")
                    player = null; next.release()
                    if (queue?.completeVerse() != true) finish()
                    else try { playCurrent() } catch (error: Exception) { playbackError = error.message; finish() }
                }
                override fun onPlayerError(error: PlaybackException) {
                    if (player !== next) return
                    Log.e("QuranPlayback", "failed ${entry.getString("id")}", error)
                    playbackError = "Playback failed"; finish()
                }
            })
            player = next
            next.setMediaSource(source)
            next.prepare(); next.play()
        } catch (error: Exception) { next.release(); throw error }
    }
    fun advanceMemorization() {
        val active = queue ?: return
        if (!active.cumulative || active.stopPending) return
        val old = player; player = null; old?.release()
        if (!active.advanceStage()) finish()
        else try { playCurrent() } catch (error: Exception) { playbackError = error.message; finish(); throw error }
    }
    fun requestStop() {
        if (queue?.current?.isNull("verse") == true) finish() else queue?.requestStop()
    }
    fun closeAfterVerse(callback: () -> Unit) {
        if (playing == null) callback() else { onStopped = callback; requestStop() }
    }
    private fun finish() {
        val old = player; player = null; playing = null; queue = null
        old?.release()
        val callback = onStopped; onStopped = null; callback?.invoke()
    }
    fun remove(id: String) {
        check(playing == null) { "Finish playback before deleting audio" }
        for (entry in sequence(id)) {
            val target = file(entry.getString("id"))
            check(!target.exists() || target.delete()) { "Audio could not be deleted" }
        }
    }
}

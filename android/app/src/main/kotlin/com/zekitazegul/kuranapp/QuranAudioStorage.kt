package com.zekitazegul.kuranapp

import android.content.Context
import android.media.MediaPlayer
import android.media.AudioAttributes
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
    private var reciter = preferences.getString("reciter", "shatri")!!
    fun selectReciter(id: String) {
        check(playing == null) { "Current verse must finish first" }
        require((0 until reciters.length()).any { reciters.getJSONObject(it).getString("id") == id })
        check(preferences.edit().putString("reciter", id).commit())
        reciter = id
    }
    private var player: MediaPlayer? = null
    private var queue: VersePlaybackQueue<JSONObject>? = null
    private var onStopped: (() -> Unit)? = null
    private var playbackError: String? = null
    private var playing: String? = null
    private val verses by lazy { (0 until catalog.length()).map { catalog.getJSONObject(it) } }
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
    } }
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
        return if (entry.isNull("verse")) checkNotNull(verseGroups[entry.getString("reciter") + ":" + entry.getInt("surah")])
            .sortedBy { it.getInt("verse") } else listOf(entry)
    }
    private fun file(id: String) = File(directory, "$id.audio")
    private fun downloaded(entry: JSONObject): Boolean = file(entry.getString("id")).let {
        it.isFile && it.length() == entry.getLong("bytes")
    }
    fun load(): Map<String, Any?> {
        val selectedVerses = verses.filter { it.getString("reciter") == reciter }
        val selectedChapters = (chapters + pages).filter { it.getString("reciter") == reciter }
        val stored = selectedVerses.filter { downloaded(it) }.map { it.getString("id") }.toMutableSet()
        stored.addAll(selectedChapters.filter { entry -> sequence(entry.getString("id")).all { it.getString("id") in stored } }.map { it.getString("id") })
        return mapOf(
            "reciter" to reciter,
            "reciters" to (0 until reciters.length()).map { reciters.getJSONObject(it).let { r -> mapOf("id" to r.getString("id"), "name" to r.getString("name")) } },
            "tracks" to (selectedChapters + selectedVerses).map { t -> mapOf("id" to t.getString("id"), "surah" to t.getInt("surah"),
                "verse" to if (t.isNull("verse")) null else t.getInt("verse"),
                "page" to if (t.has("page")) t.getInt("page") else null, "bytes" to t.getLong("bytes")) },
            "downloaded" to stored.toList(), "playing" to playing, "stopPending" to (queue?.stopPending == true),
            "currentVerse" to queue?.current?.getInt("verse"), "error" to playbackError
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
        require(hash != null || (entry.getString("reciter") == "mustafa_ismail" && source.host == "everyayah.com"))
        if (hash != null) require(hash.matches(Regex(if (algorithm == "SHA-256") "[a-f0-9]{64}" else "[a-f0-9]{32}")))
        var current = source
        var connection: HttpsURLConnection? = null
        val temp = File(directory, "$id.part")
        try {
            for (attempt in 0..4) {
                require(current.protocol == "https" && current.host == source.host && current.port in setOf(-1, 443))
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
            check(total == expected && (hash == null || actual == hash)) { "Ses dosyası doğrulanamadı." }
            if (hash == null) {
                val metadata = android.media.MediaMetadataRetriever()
                try {
                    metadata.setDataSource(temp.path)
                    check((metadata.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0) > 0)
                } finally { metadata.release() }
            }
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
    private fun playCurrent() {
        val entry = checkNotNull(queue).current
        val next = MediaPlayer()
        try {
            next.setAudioAttributes(AudioAttributes.Builder().setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                .setUsage(AudioAttributes.USAGE_MEDIA).build())
            next.setDataSource(file(entry.getString("id")).path)
            next.setOnCompletionListener {
                player?.release(); player = null
                if (queue?.completeVerse() != true) finish()
                else {
                    try { playCurrent() } catch (error: Exception) { playbackError = error.message; finish() }
                }
            }
            next.setOnErrorListener { _, _, _ -> playbackError = "Playback failed"; finish(); true }
            next.prepare()
            player = next; next.start()
        } catch (error: Exception) { next.release(); throw error }
    }
    fun requestStop() { queue?.requestStop() }
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

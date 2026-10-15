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
    private val catalog = JSONObject(context.assets.open("flutter_assets/assets/audio.json")
        .bufferedReader().use { it.readText() }).getJSONArray("tracks")
    private var player: MediaPlayer? = null
    @Volatile private var playing: String? = null

    private fun track(id: String): JSONObject {
        require(id.matches(Regex("[a-z0-9_-]{1,80}")))
        return (0 until catalog.length()).map { catalog.getJSONObject(it) }
            .firstOrNull { it.getString("id") == id } ?: error("Ses kaydı henüz eklenmedi.")
    }
    private fun file(id: String): File { track(id); return File(directory, "$id.audio") }
    fun load(): Map<String, Any?> = mapOf(
        "tracks" to (0 until catalog.length()).map { i ->
            val t = catalog.getJSONObject(i)
            mapOf("id" to t.getString("id"), "surah" to t.getInt("surah"),
                "verse" to if (t.isNull("verse")) null else t.getInt("verse"), "bytes" to t.getLong("bytes"))
        },
        "downloaded" to (0 until catalog.length()).map { catalog.getJSONObject(it) }
            .filter { file(it.getString("id")).length() == it.getLong("bytes") }.map { it.getString("id") },
        "playing" to playing
    )
    fun download(id: String) {
        stop()
        val entry = track(id)
        val target = file(id)
        val expected = entry.getLong("bytes")
        require(expected in 1L..500_000_000L)
        if (target.isFile && target.length() == expected) return
        val source = URL(entry.getString("url"))
        require(source.protocol == "https" && source.port in setOf(-1, 443))
        val hash = entry.getString("sha256")
        require(hash.matches(Regex("[a-f0-9]{64}")))
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
            val digest = MessageDigest.getInstance("SHA-256")
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
        val source = file(id)
        check(source.isFile && source.length() == track(id).getLong("bytes"))
        stop()
        val next = MediaPlayer()
        try {
            next.setAudioAttributes(AudioAttributes.Builder().setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                .setUsage(AudioAttributes.USAGE_MEDIA).build())
            next.setDataSource(source.path)
            next.setOnCompletionListener { stop() }
            next.setOnErrorListener { _, _, _ -> stop(); true }
            next.prepare()
            player = next; playing = id; next.start()
        } catch (error: Exception) { next.release(); player = null; playing = null; throw error }
    }
    fun stop() { val old = player; player = null; playing = null; old?.release() }
    fun remove(id: String) {
        val target = file(id)
        if (playing == id) stop()
        check(!target.exists() || target.delete()) { "Ses dosyası silinemedi." }
    }
}

package com.zekitazegul.kuranapp

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import io.flutter.plugin.common.MethodChannel

/** Plays the downloaded human recording. Never falls back to speech synthesis. */
class HatimPrayerPlayer(private val context: Context) {
    companion object {
        fun recording(context: Context) = java.io.File(context.filesDir, "prayer-audio-v1/hatim_sudais.mp3")
        fun isDownloaded(context: Context): Boolean {
            val file = recording(context)
            if (!file.isFile) return false
            val valid = try {
                val digest = java.security.MessageDigest.getInstance("SHA-256")
                file.inputStream().use { input ->
                    val buffer = ByteArray(65536)
                    while (true) {
                        val count = input.read(buffer)
                        if (count < 0) break
                        digest.update(buffer, 0, count)
                    }
                }
                file.length() == 2346176L && digest.digest().joinToString("") { "%02x".format(it) } == "8e84bfb0ffa4a1ed136f7cde3117d195e3946fa426bf022a6d913136ffa1c3dd"
            } catch (_: Exception) { false }
            if (!valid) file.delete()
            return valid
        }
    }
    private val manager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private var player: MediaPlayer? = null
    private var result: MethodChannel.Result? = null
    private var focus: AudioFocusRequest? = null
    private val listener = AudioManager.OnAudioFocusChangeListener { change ->
        if (change < 0) stop()
    }
    private val attributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build()

    @Suppress("DEPRECATION")
    fun play(reply: MethodChannel.Result) {
        stop()
        result = reply
        try {
            val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                    .setAudioAttributes(attributes).setOnAudioFocusChangeListener(listener).build()
                focus = request
                manager.requestAudioFocus(request)
            } else manager.requestAudioFocus(listener, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN)
            check(granted == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) { "Audio focus unavailable" }
            val next = MediaPlayer()
            player = next
            next.setAudioAttributes(attributes)
            check(isDownloaded(context)) { "Download required" }
            next.setDataSource(recording(context).absolutePath)
            next.setOnPreparedListener { if (player === it) it.start() }
            next.setOnCompletionListener { if (player === it) stop() }
            next.setOnErrorListener { media, _, _ ->
                if (player === media) fail()
                true
            }
            next.prepareAsync()
        } catch (_: Exception) { fail() }
    }

    private fun fail() {
        val pending = result
        result = null
        stop()
        pending?.error("PRAYER_AUDIO_ERROR", "Prayer recording could not be played", null)
    }

    @Suppress("DEPRECATION")
    fun stop() {
        val old = player
        player = null
        old?.setOnPreparedListener(null)
        old?.setOnCompletionListener(null)
        old?.setOnErrorListener(null)
        old?.release()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focus?.let { manager.abandonAudioFocusRequest(it) }
        } else manager.abandonAudioFocus(listener)
        focus = null
        val pending = result
        result = null
        pending?.success(null)
    }
}

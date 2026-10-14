package com.zekitazegul.kuranapp

import android.content.Context
import android.graphics.BitmapFactory
import java.io.File
import java.net.URL
import java.util.Locale
import javax.net.ssl.HttpsURLConnection

/** Private, local-only reading state and validated, resumable page downloads. */
class ReadingStorage(context: Context) {
    private val preferences = context.getSharedPreferences("reading", Context.MODE_PRIVATE)
    private val directory = File(context.filesDir, "madani-1024").apply { mkdirs() }

    private fun pageFile(page: Int) = File(directory, String.format(Locale.US, "page%03d.png", page))

    private fun validImage(file: File): Boolean {
        if (!file.isFile || file.length() !in 8..8_000_000) return false
        val expected = byteArrayOf(-119, 80, 78, 71, 13, 10, 26, 10)
        val signature = ByteArray(8)
        file.inputStream().use { if (it.read(signature) != 8) return false }
        if (!signature.contentEquals(expected)) return false
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(file.path, options)
        return options.outWidth in 500..4096 && options.outHeight in 500..8192
    }

    fun load(): Map<String, Any> = mapOf(
        "directory" to directory.path,
        "lastPage" to preferences.getInt("lastPage", 1),
        "informationSeen" to preferences.getBoolean("informationSeen", false),
        "bookmarks" to preferences.getStringSet("bookmarks", emptySet())!!.mapNotNull { it.toIntOrNull() },
        "downloaded" to (1..604).filter { validImage(pageFile(it)) }
    )

    fun savePage(page: Int) {
        require(page in 1..604)
        check(preferences.edit().putInt("lastPage", page).commit()) { "Okuma kaydı yazılamadı." }
    }

    fun saveBookmarks(pages: List<Int>) {
        require(pages.all { it in 1..604 })
        check(preferences.edit().putStringSet("bookmarks", pages.map { it.toString() }.toSet()).commit())
    }

    fun acknowledge() {
        check(preferences.edit().putBoolean("informationSeen", true).commit())
    }

    private fun openPage(url: URL): HttpsURLConnection {
        var current = url
        repeat(5) {
            require(current.protocol == "https" &&
                current.host in setOf("android.quran.com", "quran.app", "files.quran.app") &&
                current.port in setOf(-1, 443)) { "Güvenilmeyen indirme adresi." }
            val connection = current.openConnection() as HttpsURLConnection
            connection.connectTimeout = 20_000
            connection.readTimeout = 30_000
            connection.instanceFollowRedirects = false
            val status = connection.responseCode
            if (status !in setOf(301, 302, 303, 307, 308)) return connection
            val location = connection.getHeaderField("Location")
            connection.disconnect()
            check(location != null) { "Geçersiz indirme yönlendirmesi." }
            current = URL(current, location)
        }
        error("Çok fazla indirme yönlendirmesi.")
    }

    fun downloadPage(page: Int) {
        require(page in 1..604)
        val target = pageFile(page)
        if (validImage(target)) return
        val temp = File(directory, target.name + ".part")
        val connection = openPage(URL("https://files.quran.app/hafs/madani/width_1024/${target.name}"))
        try {
            check(connection.responseCode == 200) { "Sayfa $page indirilemedi (HTTP ${connection.responseCode})." }
            check(connection.contentLengthLong <= 8_000_000) { "Beklenmeyen sayfa boyutu." }
            connection.inputStream.use { input ->
                temp.outputStream().use { output ->
                    val buffer = ByteArray(16_384)
                    var total = 0L
                    while (true) {
                        val count = input.read(buffer)
                        if (count == -1) break
                        total += count
                        check(total <= 8_000_000) { "Sayfa boyutu sınırı aşıldı." }
                        output.write(buffer, 0, count)
                    }
                }
            }
            check(validImage(temp)) { "İndirilen sayfa geçerli bir PNG değil." }
            // Decode the complete image before accepting it (bounds alone are insufficient).
            val bitmap = BitmapFactory.decodeFile(temp.path)
            check(bitmap != null) { "Sayfa görüntüsü okunamadı." }
            bitmap.recycle()
            check(temp.renameTo(target)) { "Sayfa kaydedilemedi." }
        } finally {
            connection.disconnect()
            temp.delete()
        }
    }
}

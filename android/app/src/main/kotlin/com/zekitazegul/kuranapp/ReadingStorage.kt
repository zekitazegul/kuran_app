package com.zekitazegul.kuranapp

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import java.io.File
import java.net.URL
import java.util.Locale
import java.security.MessageDigest
import javax.net.ssl.HttpsURLConnection

/** Private, local-only reading state and validated, resumable page downloads. */
class ReadingStorage(context: Context) {
    private val preferences = context.getSharedPreferences("reading-computer-v1", Context.MODE_PRIVATE)
    private val directory = File(context.filesDir, "computer-script-v1").apply { mkdirs() }

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
        "lastPage" to preferences.getInt("lastPage", 0),
        "informationSeen" to preferences.getBoolean("informationSeen", false),
        "bookmarks" to preferences.getStringSet("bookmarks", emptySet())!!.mapNotNull { it.toIntOrNull() },
        "downloaded" to (0..604).filter { validImage(pageFile(it)) }
    )

    fun savePage(page: Int) {
        require(page in 0..604)
        check(preferences.edit().putInt("lastPage", page).commit()) { "Okuma kaydı yazılamadı." }
    }

    fun saveBookmarks(pages: List<Int>) {
        require(pages.all { it in 0..604 })
        check(preferences.edit().putStringSet("bookmarks", pages.map { it.toString() }.toSet()).commit())
    }

    fun acknowledge() {
        check(preferences.edit().putBoolean("informationSeen", true).commit())
    }

    private val sourceUrl = "https://raw.githubusercontent.com/zekitazegul/kuran_app/93f3416c2341a23589fe69a591e7d1f09135b3bf/content/kuran-bilgisayar-hatti.pdf"
    private val expectedSha256 = "fa88e87198fa9cadee797cd3ac1d3d41e4c4c7776d97b4fee02c32e0a14cb0f7"

    private fun openSource(): HttpsURLConnection {
        var current = URL(sourceUrl)
        repeat(5) {
            require(current.protocol == "https" &&
                current.host in setOf("raw.githubusercontent.com", "github.com") &&
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

    private fun sourcePdf(): File {
        val file = File(directory, "kuran.pdf")
        if (file.isFile) return file
        val temp = File(directory, "kuran.pdf.part")
        val connection = openSource()
        try {
            check(connection.responseCode == 200) { "Kur’an PDF’si indirilemedi (HTTP ${connection.responseCode})." }
            val digest = MessageDigest.getInstance("SHA-256")
            connection.inputStream.use { input ->
                temp.outputStream().use { output ->
                    val buffer = ByteArray(65_536)
                    var total = 0L
                    while (true) {
                        val count = input.read(buffer)
                        if (count == -1) break
                        total += count
                        check(total <= 32_000_000) { "Beklenmeyen PDF boyutu." }
                        digest.update(buffer, 0, count)
                        output.write(buffer, 0, count)
                    }
                }
            }
            val actual = digest.digest().joinToString("") { "%02x".format(it.toInt() and 255) }
            check(actual == expectedSha256) { "PDF doğrulaması başarısız; dosya kullanılmadı." }
            ParcelFileDescriptor.open(temp, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
                PdfRenderer(descriptor).use { renderer ->
                    check(renderer.pageCount == 616) { "PDF sayfa sayısı beklenenden farklı." }
                }
            }
            check(temp.renameTo(file)) { "PDF kaydedilemedi." }
            return file
        } finally {
            connection.disconnect()
            temp.delete()
        }
    }

    fun downloadPage(page: Int) {
        require(page in 0..604)
        val target = pageFile(page)
        if (validImage(target)) return
        val source = sourcePdf()
        val temp = File(directory, target.name + ".part")
        try {
            ParcelFileDescriptor.open(source, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
                PdfRenderer(descriptor).use { renderer ->
                    // PDF page 1 is blank. PDF 2 is unnumbered Fatiha; PDF 3
                    // is printed page 1. Printed page 604 is PDF page 606.
                    renderer.openPage(page + 1).use { pdfPage ->
                        val width = 1400
                        val height = (width.toDouble() * pdfPage.height / pdfPage.width).toInt()
                        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                        try {
                            bitmap.eraseColor(Color.WHITE)
                            pdfPage.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                            temp.outputStream().use { output ->
                                check(bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)) { "Sayfa oluşturulamadı." }
                            }
                        } finally { bitmap.recycle() }
                    }
                }
            }
            check(validImage(temp)) { "PDF sayfası görüntüye dönüştürülemedi." }
            check(temp.renameTo(target)) { "Sayfa kaydedilemedi." }
        } finally { temp.delete() }
    }
}

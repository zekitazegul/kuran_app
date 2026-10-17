package com.zekitazegul.kuranapp

import android.content.Context
import android.util.AtomicFile
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
import org.json.JSONArray
import org.json.JSONObject

/** Private, local-only reading state and validated, resumable page downloads. */
class ReadingStorage(private val context: Context, requestedEdition: String? = null,
    private val onDownloadProgress: ((String, Long, Long) -> Unit)? = null) {
    // Keep existing computer-script preferences/files intact during upgrades.
    private val global = context.getSharedPreferences("reading-computer-v1", Context.MODE_PRIVATE)
    private val catalog = JSONArray(context.assets.open("flutter_assets/assets/editions.json")
        .bufferedReader().use { it.readText() })
    private val edition = findEdition(requestedEdition ?: global.getString("selectedEdition", "computer")!!)
    private val preferences = context.getSharedPreferences(edition.getString("preferences"), Context.MODE_PRIVATE)
    private val directory = File(context.filesDir, edition.getString("directory")).apply { mkdirs() }
    private val firstPage = edition.getInt("firstPage")
    private val lastPage = edition.getInt("lastPage")
    private val historyFile = AtomicFile(File(context.filesDir, "reading-history.json"))

    private fun readingHistory(): JSONArray = try {
        JSONArray(historyFile.openRead().bufferedReader().use { it.readText() })
    } catch (_: java.io.FileNotFoundException) { JSONArray() }

    fun saveHatim(pages: List<Int>, resume: Int) {
        require(pages.all { it in firstPage..lastPage } && resume in firstPage..lastPage)
        check(preferences.edit().putStringSet("hatimPages", pages.map { it.toString() }.toSet())
            .putInt("hatimResume", resume).commit())
    }

    fun saveReadingHistory(entries: List<Map<String, Any?>>) {
        val array = JSONArray(entries)
        for (i in 0 until array.length()) {
            val item = array.getJSONObject(i)
            val source = findEdition(item.getString("edition"))
            require(item.getInt("firstPage") >= source.getInt("firstPage"))
            require(item.getInt("lastPage") in item.getInt("firstPage")..source.getInt("lastPage"))
            require(item.getLong("time") > 0 && item.getString("session").length <= 100)
            val surahs = item.getJSONArray("surahs")
            require(surahs.length() in 1..114)
            for (j in 0 until surahs.length()) require(surahs.getInt(j) in 1..114)
        }
        val output = historyFile.startWrite()
        try {
            output.write(array.toString().toByteArray(Charsets.UTF_8))
            historyFile.finishWrite(output)
        } catch (error: Exception) {
            historyFile.failWrite(output)
            throw error
        }
    }

    private fun findEdition(id: String): JSONObject = (0 until catalog.length())
        .map { catalog.getJSONObject(it) }.firstOrNull { it.getString("id") == id }
        ?: error("Bu hat henüz kullanıma sunulmadı.")

    private fun toCodec(value: Any?): Any? = when (value) {
        is JSONObject -> value.keys().asSequence().associateWith { toCodec(value.get(it)) }
        is JSONArray -> (0 until value.length()).map { toCodec(value.get(it)) }
        JSONObject.NULL -> null
        else -> value
    }

    fun saveUiPreferences(values: Map<String, Any?>) {
        val json = JSONObject(values)
        require(json.getString("theme") in setOf("system", "light", "dark"))
        require(json.getString("color") in setOf("green", "blue", "purple", "amber"))
        if (json.has("bottomShortcuts")) {
            val bottom = json.getJSONArray("bottomShortcuts")
            val destinations = (0 until bottom.length()).map { bottom.getString(it) }
            require(destinations.size in 0..6 && destinations.toSet().size == destinations.size)
            require(destinations.all { it in setOf("home", "bookmarks", "surahs", "history", "settings", "search", "hatim", "exit") })
        }
        val shortcuts = json.getJSONArray("shortcuts")
        require(shortcuts.length() <= 24)
        val ids = mutableSetOf<String>()
        for (i in 0 until shortcuts.length()) {
            val shortcut = shortcuts.getJSONObject(i)
            val kind = shortcut.getString("kind")
            val number = shortcut.getInt("number")
            require((kind == "surah" && number in 1..114) || (kind == "juz" && number in 1..30))
            require(ids.add("$kind:$number"))
        }
        if (json.has("dashboardCards")) {
            val cards = json.getJSONArray("dashboardCards")
            val order = (0 until cards.length()).map { cards.getString(it) }
            require(DashboardCardOrder.isValid(order, ids))
        }
        check(global.edit().putString("uiPreferences", json.toString()).commit())
    }

    fun selectEdition(id: String): Map<String, Any?> {
        findEdition(id)
        val state = ReadingStorage(context, id).load()
        check(global.edit().putString("selectedEdition", id).commit())
        return state
    }

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

    private fun downloadedEditionIds(): List<String> = (0 until catalog.length()).map { catalog.getJSONObject(it) }
        .filter { entry -> File(context.filesDir, entry.getString("directory")).listFiles()?.any { it.isFile } == true }
        .map { it.getString("id") }

    @Suppress("DEPRECATION")
    private fun appVersion(): String {
        val info = context.packageManager.getPackageInfo(context.packageName, 0)
        return "${info.versionName}+${info.versionCode}"
    }

    fun acknowledgeUpdate() {
        check(global.edit().putString("seenUpdateVersion", appVersion()).commit())
    }

    fun load(): Map<String, Any?> = mapOf(
        "appVersion" to appVersion(),
        "seenUpdateVersion" to global.getString("seenUpdateVersion", null),
        "readingHistory" to toCodec(readingHistory()),
        "hatimPages" to preferences.getStringSet("hatimPages", emptySet())!!.map { it.toInt() },
        "hatimResume" to preferences.getInt("hatimResume", firstPage),
        "uiPreferences" to toCodec(JSONObject(global.getString("uiPreferences", "{}")!!)),
        "edition" to toCodec(edition),
        "editions" to toCodec(catalog),
        "downloadedEditions" to downloadedEditionIds(),
        "directory" to directory.path,
        "downloadedBytes" to File(directory, "kuran.pdf").let { if (it.isFile) it.length() else 0L },
        "language" to global.getString("language", null),
        "edgeTapWidth" to (context.resources.displayMetrics.xdpi / 2.54 / context.resources.displayMetrics.density),
        "lastPage" to preferences.getInt("lastPage", firstPage),
        "informationSeen" to global.getBoolean("informationSeen", false),
        "guideSeen" to global.getBoolean("guideSeen", false),
        "pageAnimations" to global.getBoolean("pageAnimations", true),
        "pageEffect" to global.getString("pageEffect", "slide"),
        "bookmarkDates" to toCodec(JSONObject(preferences.getString("bookmarkDates", "{}")!!)),
        "bookmarks" to preferences.getStringSet("bookmarks", emptySet())!!.mapNotNull { it.toIntOrNull() },
        "downloaded" to (firstPage..lastPage).filter { validImage(pageFile(it)) }
    )

    fun findDownloadedEdition(): String? {
        val lastRead = global.getString("lastReadingEdition", null)
        val ids = (0 until catalog.length()).map { catalog.getJSONObject(it).getString("id") }
        return (listOfNotNull(lastRead) + ids).distinct().firstOrNull { id ->
            val candidate = ReadingStorage(context, id)
            (candidate.firstPage..candidate.lastPage).all { candidate.validImage(candidate.pageFile(it)) }
        }
    }

    fun savePage(page: Int) {
        require(page in firstPage..lastPage)
        check(global.edit().putString("lastReadingEdition", edition.getString("id")).commit())
        check(preferences.edit().putInt("lastPage", page).commit()) { "Okuma kaydı yazılamadı." }
    }

    fun saveBookmarks(pages: List<Int>) {
        require(pages.all { it in firstPage..lastPage })
        val previous = preferences.getStringSet("bookmarks", emptySet())!!
        val oldDates = JSONObject(preferences.getString("bookmarkDates", "{}")!!)
        val dates = JSONObject()
        val now = System.currentTimeMillis()
        for (page in pages) {
            val key = page.toString()
            if (oldDates.has(key)) dates.put(key, oldDates.getLong(key))
            else if (key !in previous) dates.put(key, now)
        }
        check(preferences.edit().putStringSet("bookmarks", pages.map { it.toString() }.toSet())
            .putString("bookmarkDates", dates.toString()).commit())
    }

    fun acknowledge() {
        check(global.edit().putBoolean("informationSeen", true).commit())
    }

    fun setLanguage(language: String) {
        require(language in setOf("tr", "en", "nl"))
        check(global.edit().putString("language", language).commit())
    }

    fun acknowledgeGuide() {
        check(global.edit().putBoolean("guideSeen", true).commit())
    }

    fun setPageEffect(effect: String) {
        require(effect in setOf("curl", "slide"))
        check(global.edit().putString("pageEffect", effect).commit())
    }

    fun setPageAnimations(enabled: Boolean) {
        check(global.edit().putBoolean("pageAnimations", enabled).commit())
    }

    private val sourceUrl = edition.getString("url")
    private val expectedSha256 = edition.getString("sha256")

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
        if (file.isFile) {
            onDownloadProgress?.invoke(edition.getString("id"), file.length(), edition.getLong("bytes"))
            return file
        }
        val temp = File(directory, "kuran.pdf.part")
        onDownloadProgress?.invoke(edition.getString("id"), 0L, edition.getLong("bytes"))
        val connection = openSource()
        try {
            check(connection.responseCode == 200) { "Kur’an PDF’si indirilemedi (HTTP ${connection.responseCode})." }
            val digest = MessageDigest.getInstance("SHA-256")
            connection.inputStream.use { input ->
                temp.outputStream().use { output ->
                    val buffer = ByteArray(65_536)
                    var total = 0L
                    var lastProgressAt = 0L
                    while (true) {
                        val count = input.read(buffer)
                        if (count == -1) break
                        total += count
                        check(total <= edition.getLong("bytes")) { "Beklenmeyen PDF boyutu." }
                        digest.update(buffer, 0, count)
                        output.write(buffer, 0, count)
                        val now = android.os.SystemClock.elapsedRealtime()
                        if (now - lastProgressAt >= 150L) {
                            onDownloadProgress?.invoke(edition.getString("id"), total, edition.getLong("bytes"))
                            lastProgressAt = now
                        }
                    }
                }
            }
            val actual = digest.digest().joinToString("") { "%02x".format(it.toInt() and 255) }
            check(temp.length() == edition.getLong("bytes")) { "PDF boyutu doğrulanamadı." }
            check(actual == expectedSha256) { "PDF doğrulaması başarısız; dosya kullanılmadı." }
            ParcelFileDescriptor.open(temp, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
                PdfRenderer(descriptor).use { renderer ->
                    check(renderer.pageCount == edition.getInt("pdfPages")) { "PDF sayfa sayısı beklenenden farklı." }
                }
            }
            onDownloadProgress?.invoke(edition.getString("id"), temp.length(), edition.getLong("bytes"))
            check(temp.renameTo(file)) { "PDF kaydedilemedi." }
            return file
        } finally {
            connection.disconnect()
            temp.delete()
        }
    }

    fun removeDownload() {
        // Only this edition's private content; preserve preferences and reading records.
        check(directory.canonicalFile.parentFile == context.filesDir.canonicalFile)
        check(directory.deleteRecursively()) { "Hat dosyaları kaldırılamadı." }
        check(directory.mkdirs()) { "Hat klasörü oluşturulamadı." }
    }

    fun downloadPage(page: Int) {
        require(page in firstPage..lastPage)
        val target = pageFile(page)
        if (validImage(target)) return
        val source = sourcePdf()
        val temp = File(directory, target.name + ".part")
        try {
            ParcelFileDescriptor.open(source, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
                PdfRenderer(descriptor).use { renderer ->
                    // Each edition defines its own offset. Hüsrev starts at
                    // physical PDF page 1; the other PDFs have a blank cover.
                    renderer.openPage(page - firstPage + edition.getInt("pdfOffset")).use { pdfPage ->
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

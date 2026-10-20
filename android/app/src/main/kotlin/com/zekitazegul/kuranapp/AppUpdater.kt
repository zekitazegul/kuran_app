package com.zekitazegul.kuranapp

import android.content.Intent
import android.app.AlertDialog
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.content.pm.PackageManager
import android.content.pm.PackageInfo
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.io.ByteArrayOutputStream
import java.net.URL
import java.security.MessageDigest
import java.util.concurrent.CountDownLatch
import java.util.Locale
import javax.net.ssl.HttpsURLConnection

/** User initiated updates; never reports success before the system installer runs. */
class AppUpdater(private val activity: MainActivity, private val channel: MethodChannel) {
    private var pending: MethodChannel.Result? = null
    private var apk: File? = null
    private val permissionRequest = 7401
    private val installerRequest = 7402

    init {
        channel.setMethodCallHandler { call, result ->
            if (call.method != "update") { result.notImplemented(); return@setMethodCallHandler }
            if (pending != null) { result.error("busy", "updateError", null); return@setMethodCallHandler }
            val manifestUrl = call.argument<String>("manifestUrl") ?: ""
            if (manifestUrl.isBlank()) {
                result.error("configuration", "updateError", null)
                return@setMethodCallHandler
            }
            pending = result
            val labels = call.argument<Map<String, String>>("labels") ?: emptyMap()
            Thread {
                try {
                    val metadata = connection(manifestUrl).let { conn ->
                        try {
                            conn.inputStream.use { input ->
                                val output = ByteArrayOutputStream()
                                val buffer = ByteArray(4096)
                                while (output.size() <= 65536) {
                                    val count = input.read(buffer, 0, minOf(buffer.size, 65537 - output.size()))
                                    if (count < 0) break
                                    output.write(buffer, 0, count)
                                }
                                val bytes = output.toByteArray()
                                require(bytes.size <= 65536) { "updateError" }
                                JSONObject(String(bytes, Charsets.UTF_8))
                            }
                        } finally { conn.disconnect() }
                    }
                    val installed = activity.packageManager.getPackageInfo(activity.packageName, signatureFlags())
                    val remoteVersion = metadata.getLong("versionCode")
                    if (remoteVersion <= versionCode(installed)) {
                        finish("current:${installed.versionName}")
                    } else {
                        val hash = metadata.getString("sha256").lowercase()
                        require(hash.matches(Regex("[a-f0-9]{64}"))) { "updateError" }
                        val address = metadata.getString("apkUrl")
                        val advertisedSize = metadata.optLong("sizeBytes", -1)
                        val size = if (advertisedSize > 0) advertisedSize else connection(address, "HEAD").let { conn ->
                            try { conn.contentLengthLong } finally { conn.disconnect() }
                        }
                        require(size in 1..(700L * 1024 * 1024)) { "updateError" }
                        val sizeText = String.format(Locale.US, "%.2f", size / (1024.0 * 1024))
                        if (!confirmDownload(size, sizeText, labels)) {
                            finish(labels["cancelled"] ?: "updateError")
                            return@Thread
                        }
                        val directory = File(activity.cacheDir, "updates").apply { mkdirs() }
                        val target = File(directory, "latest.apk")
                        target.delete()
                        val temporary = File(directory, "download.tmp")
                        val downloadLabel = labels["downloading"] ?: "updateError"
                        status("$downloadLabel · $sizeText MB")
                        try {
                            val conn = connection(address)
                            val digest = MessageDigest.getInstance("SHA-256")
                            try {
                                val length = conn.contentLengthLong
                                require(length <= 700L * 1024 * 1024) { "updateError" }
                                conn.inputStream.use { input ->
                                    temporary.outputStream().use { output ->
                                        val buffer = ByteArray(65536)
                                        var total = 0L
                                        var lastPercent = -1
                                        while (true) {
                                            val count = input.read(buffer)
                                            if (count < 0) break
                                            total += count
                                            require(total <= 700L * 1024 * 1024) { "updateError" }
                                            output.write(buffer, 0, count)
                                            digest.update(buffer, 0, count)
                                            val percent = if (length > 0) (total * 100 / length).toInt() else -1
                                            if (percent != lastPercent) {
                                                lastPercent = percent
                                                status("$downloadLabel %$percent · $sizeText MB")
                                            }
                                        }
                                        require(total == size && (length < 0 || total == length)) { "updateError" }
                                    }
                                }
                            } finally { conn.disconnect() }
                            require(digest.digest().joinToString("") { "%02x".format(it) } == hash) { "updateError" }
                            val archive = activity.packageManager.getPackageArchiveInfo(temporary.path, signatureFlags())
                                ?: error("updateError")
                            require(archive.packageName == activity.packageName && versionCode(archive) == remoteVersion) { "updateError" }
                            require(signatures(archive) == signatures(installed) && signatures(installed).isNotEmpty()) { "updateError" }
                            require(temporary.renameTo(target)) { "updateError" }
                            activity.runOnUiThread {
                                apk = target
                                try { installOrRequestPermission() } catch (_: Exception) { fail("updateError") }
                            }
                        } finally { temporary.delete() }
                    }
                } catch (e: Exception) {
                    fail(if (e is IllegalArgumentException || e is IllegalStateException) e.message ?: "updateError" else "updateError")
                }
            }.start()
        }
    }

    private fun signatureFlags() = if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
    @Suppress("DEPRECATION")
    private fun versionCode(info: PackageInfo): Long = if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
    @Suppress("DEPRECATION")
    private fun signatures(info: PackageInfo): Set<String> {
        val certs = if (Build.VERSION.SDK_INT >= 28) info.signingInfo?.apkContentsSigners else info.signatures
        return certs?.map { cert -> MessageDigest.getInstance("SHA-256").digest(cert.toByteArray()).joinToString("") { "%02x".format(it) } }?.toSet() ?: emptySet()
    }

    private fun confirmDownload(size: Long, sizeText: String, labels: Map<String, String>): Boolean {
        val latch = CountDownLatch(1)
        var accepted = false
        activity.runOnUiThread {
            if (activity.isFinishing || activity.isDestroyed) { latch.countDown(); return@runOnUiThread }
            val manager = activity.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val capabilities = manager.getNetworkCapabilities(manager.activeNetwork)
            val mobile = capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) != true
            val key = if (!mobile) "wifi" else if (size <= 2L * 1024 * 1024) "smallMobile" else "largeMobile"
            val fallback = if (mobile) "updateError" else "updateError"
            AlertDialog.Builder(activity)
                .setTitle(labels["title"] ?: "updateError")
                .setMessage((labels[key] ?: fallback).replace("{size}", sizeText))
                .setPositiveButton(labels["download"] ?: "updateError") { _, _ -> accepted = true; latch.countDown() }
                .setNegativeButton(labels["cancel"] ?: "updateError") { _, _ -> latch.countDown() }
                .setOnCancelListener { latch.countDown() }
                .setOnDismissListener { latch.countDown() }
                .show()
        }
        latch.await()
        return accepted
    }

    private fun connection(address: String, method: String = "GET"): HttpsURLConnection {
        var url = URL(address)
        repeat(6) {
            require(url.protocol == "https") { "updateError" }
            val conn = url.openConnection() as HttpsURLConnection
            conn.connectTimeout = 20000
            conn.readTimeout = 30000
            conn.instanceFollowRedirects = false
            conn.requestMethod = method
            conn.setRequestProperty("User-Agent", "KuranApp-Android")
            conn.setRequestProperty("Cache-Control", "no-cache")
            val code = conn.responseCode
            if (code in listOf(301, 302, 303, 307, 308)) {
                val location = conn.getHeaderField("Location")
                conn.disconnect()
                require(!location.isNullOrBlank()) { "updateError" }
                url = URL(url, location)
            } else {
                if (code != 200) { conn.disconnect(); error("updateError") }
                return conn
            }
        }
        error("updateError")
    }

    private fun installOrRequestPermission() {
        if (Build.VERSION.SDK_INT >= 26 && !activity.packageManager.canRequestPackageInstalls()) {
            status("updatePermission")
            activity.startActivityForResult(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:${activity.packageName}")), permissionRequest)
            return
        }
        val file = apk ?: error("updateError")
        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.apkshare", file)
        status("updateInstalling")
        activity.startActivityForResult(Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
            data = uri
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            putExtra(Intent.EXTRA_RETURN_RESULT, true)
        }, installerRequest)
    }

    fun onActivityResult(requestCode: Int) {
        if (pending == null) return
        if (requestCode == permissionRequest) {
            if (Build.VERSION.SDK_INT >= 26 && !activity.packageManager.canRequestPackageInstalls()) {
                finish("updatePermissionDenied")
            } else {
                try { installOrRequestPermission() } catch (_: Exception) { fail("updateError") }
            }
        } else if (requestCode == installerRequest) {
            finish("updateInstallerClosed")
        }
    }

    private fun status(message: String) = activity.runOnUiThread { channel.invokeMethod("status", message) }
    private fun finish(message: String) = activity.runOnUiThread { pending?.success(message); pending = null; apk = null }
    private fun fail(message: String) = activity.runOnUiThread { pending?.error("update", message, null); pending = null; apk = null }
}

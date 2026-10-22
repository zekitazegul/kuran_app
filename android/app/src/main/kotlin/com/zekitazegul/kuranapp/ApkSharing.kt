package com.zekitazegul.kuranapp
import android.content.Intent
import android.content.ClipData
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodChannel
import java.io.File

class ApkSharing(private val activity: MainActivity, channel: MethodChannel) {
    init {
        channel.setMethodCallHandler { call, result ->
                if (call.method == "shareInstaller") {
                    Thread {
                        try {
                            val folder = File(activity.cacheDir, "shared-apk").apply { mkdirs() }
                            val apk = File(folder, "Kuran-Installer.apk")
                            val temporary = File(folder, "preparing.tmp")
                            activity.assets.open("Kuran-Installer.apk").use { input ->
                                temporary.outputStream().use { output -> input.copyTo(output) }
                            }
                            if (apk.exists() && !apk.delete()) throw IllegalStateException("Old APK unavailable")
                            if (!temporary.renameTo(apk)) throw IllegalStateException("APK unavailable")
                            val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.apkshare", apk)
                            activity.runOnUiThread {
                                try {
                                    val intent = Intent(Intent.ACTION_SEND).apply {
                                        type = "application/vnd.android.package-archive"
                                        putExtra(Intent.EXTRA_STREAM, uri)
                                        putExtra(Intent.EXTRA_SUBJECT, "Kuran Installer")
                                        clipData = ClipData.newRawUri("Kuran Installer", uri)
                                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                    }
                                    activity.startActivity(Intent.createChooser(intent, (call.argument<String>("title") ?: "KuranApp")))
                                    result.success(null)
                                } catch (e: Exception) {
                                    result.error("share", "shareError", null)
                                }
                            }
                        } catch (e: Exception) {
                            activity.runOnUiThread { result.error("apk", "shareError", null) }
                        }
                    }.start()
                    return@setMethodCallHandler
                }
            result.notImplemented()
        }
    }
}

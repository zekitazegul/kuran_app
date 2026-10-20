package com.zekitazegul.kuranapp
import android.content.Intent
import android.content.ClipData
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodChannel
import java.io.File

class ApkSharing(private val activity: MainActivity, channel: MethodChannel) {
    init {
        channel.setMethodCallHandler { call, result ->
                if (call.method == "shareApk") {
                    if (!activity.applicationInfo.splitSourceDirs.isNullOrEmpty()) {
                        result.error("split", "shareError", null)
                        return@setMethodCallHandler
                    }
                    Thread {
                        try {
                            val folder = File(activity.cacheDir, "shared-apk").apply { mkdirs() }
                            val version = activity.packageManager.getPackageInfo(activity.packageName, 0).versionName ?: "1"
                            val safeVersion = version.replace(Regex("[^A-Za-z0-9._-]"), "_")
                            val apk = File(folder, "KuranApp-$safeVersion.apk")
                            val temporary = File(folder, "preparing.tmp")
                            File(activity.applicationInfo.sourceDir).copyTo(temporary, overwrite = true)
                            if (apk.exists() && !apk.delete()) throw IllegalStateException("Old APK unavailable")
                            if (!temporary.renameTo(apk)) throw IllegalStateException("APK unavailable")
                            val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.apkshare", apk)
                            activity.runOnUiThread {
                                try {
                                    val intent = Intent(Intent.ACTION_SEND).apply {
                                        type = "application/vnd.android.package-archive"
                                        putExtra(Intent.EXTRA_STREAM, uri)
                                        putExtra(Intent.EXTRA_SUBJECT, "KuranApp $version")
                                        clipData = ClipData.newRawUri("KuranApp APK", uri)
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

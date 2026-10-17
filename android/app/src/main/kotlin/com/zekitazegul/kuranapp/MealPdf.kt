package com.zekitazegul.kuranapp

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors

class MealPdf(private val context: Context, messenger: BinaryMessenger) {
    private val executor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val channel = MethodChannel(messenger, "com.zekitazegul.kuranapp/meal-pdf")
    private var renderer: PdfRenderer? = null
    private val prefs = context.getSharedPreferences("meal-pdf-v1", Context.MODE_PRIVATE)
    private fun document(): PdfRenderer {
        renderer?.let { return it }
        val file = File(context.filesDir, "ali-unal-meal-v1.pdf")
        if (!file.exists()) {
            val temporary = File(context.filesDir, "ali-unal-meal-v1.tmp")
            context.assets.open("flutter_assets/assets/meal/ali_unal.pdf").use { input ->
                temporary.outputStream().use { input.copyTo(it) }
            }
            check(temporary.renameTo(file))
        }
        return PdfRenderer(ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)).also { renderer = it }
    }
    init {
        channel.setMethodCallHandler { call, result ->
            executor.execute {
                try {
                    val value: Any? = when (call.method) {
                        "loadText" -> mapOf("textPage" to prefs.getInt("textPage", 0), "textOffset" to prefs.getInt("textOffset", 0), "surah" to prefs.getInt("textSurah", 1), "verse" to prefs.getInt("textVerse", 1), "fontSize" to prefs.getInt("fontSize", 22))
                        "saveText" -> {
                            val surah = requireNotNull(call.argument<Int>("surah"))
                            val verse = requireNotNull(call.argument<Int>("verse"))
                            val fontSize = requireNotNull(call.argument<Int>("fontSize"))
                            require(surah in 1..114 && verse in 1..286 && fontSize in 16..40)
                            val textPage = call.argument<Int>("textPage") ?: prefs.getInt("textPage", 0)
                            val textOffset = call.argument<Int>("textOffset") ?: prefs.getInt("textOffset", 0)
                            require(textPage >= 0 && textOffset >= -1)
                            check(prefs.edit().putInt("textPage", textPage).putInt("textOffset", textOffset).putInt("textSurah", surah).putInt("textVerse", verse).putInt("fontSize", fontSize).commit())
                            null
                        }
                        "load" -> mapOf("page" to prefs.getInt("page", 42), "zoom" to prefs.getInt("zoom", 100))
                        "save" -> {
                            val page = requireNotNull(call.argument<Int>("page"))
                            val zoom = requireNotNull(call.argument<Int>("zoom"))
                            require(page in 1..document().pageCount && zoom in 100..300)
                            check(prefs.edit().putInt("page", page).putInt("zoom", zoom).commit())
                            null
                        }
                        "render" -> {
                            val number = requireNotNull(call.argument<Int>("page"))
                            require(number in 1..document().pageCount)
                            val width = (call.argument<Int>("width") ?: 1600).coerceIn(600, 2400)
                            document().openPage(number - 1).use { page ->
                                val height = (width.toLong() * page.height / page.width).toInt().coerceIn(1, 4000)
                                val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                                try {
                                    bitmap.eraseColor(Color.WHITE)
                                    page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                                    ByteArrayOutputStream().use { output ->
                                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)
                                        output.toByteArray()
                                    }
                                } finally { bitmap.recycle() }
                            }
                        }
                        else -> throw IllegalArgumentException("Unknown PDF operation")
                    }
                    main.post { result.success(value) }
                } catch (error: Exception) {
                    main.post { result.error("MEAL_PDF_ERROR", error.message, null) }
                }
            }
        }
    }
    fun close() {
        channel.setMethodCallHandler(null)
        executor.execute { renderer?.close(); renderer = null }
        executor.shutdown()
    }
}

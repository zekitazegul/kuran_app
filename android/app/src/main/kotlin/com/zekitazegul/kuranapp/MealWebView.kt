package com.zekitazegul.kuranapp

import android.content.Context
import android.net.Uri
import android.view.View
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MealWebViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        MealWebView(context, messenger, viewId, args as Map<*, *>)
}

private class MealWebView(context: Context, messenger: BinaryMessenger, id: Int, args: Map<*, *>) : PlatformView {
    private val web = WebView(context)
    private val channel = MethodChannel(messenger, "com.zekitazegul.kuranapp/meal/$id")
    private fun allowed(url: String): Boolean = Uri.parse(url).let {
        it.scheme == "https" && it.host in setOf("www.kuranmealleri.net", "kuranmealleri.net") &&
            it.path?.contains("ali-unal-meali") == true
    }
    init {
        val url = args["url"] as String
        require(allowed(url))
        web.settings.apply {
            javaScriptEnabled = false
            allowFileAccess = false
            allowContentAccess = false
            domStorageEnabled = false
            textZoom = (args["zoom"] as Number).toInt().coerceIn(80, 200)
            useWideViewPort = true
            loadWithOverviewMode = true
        }
        web.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String) { channel.invokeMethod("loaded", null) }
            override fun onReceivedError(view: WebView, request: WebResourceRequest, error: WebResourceError) {
                if (request.isForMainFrame) channel.invokeMethod("error", null)
            }
            override fun onReceivedHttpError(view: WebView, request: WebResourceRequest, response: WebResourceResponse) {
                if (request.isForMainFrame && response.statusCode >= 400) channel.invokeMethod("error", null)
            }
            override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                val target = request.url.toString()
                if (target.trimEnd('/') == url.trimEnd('/')) return false
                if (allowed(target)) channel.invokeMethod("navigate", target)
                return true
            }
        }
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "zoom" -> { web.settings.textZoom = (call.arguments as Number).toInt().coerceIn(80, 200); result.success(null) }
                "reload" -> { web.reload(); result.success(null) }
                else -> result.notImplemented()
            }
        }
        web.loadUrl(url)
    }
    override fun getView(): View = web
    override fun dispose() { channel.setMethodCallHandler(null); web.stopLoading(); web.destroy() }
}

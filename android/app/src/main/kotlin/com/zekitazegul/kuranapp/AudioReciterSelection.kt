package com.zekitazegul.kuranapp

object AudioReciterSelection {
    fun restore(saved: String?, available: Set<String>): String =
        saved?.takeIf { it in available } ?: "shatri".also { require(it in available) }
}

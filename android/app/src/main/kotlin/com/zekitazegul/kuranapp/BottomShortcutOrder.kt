package com.zekitazegul.kuranapp

object BottomShortcutOrder {
    private val builtIn = setOf("home", "bookmarks", "surahs", "history", "settings", "search", "hatim", "exit", "meal", "listen", "support")
    fun isValid(order: List<String>, shortcuts: Set<String>): Boolean =
        order.size <= 6 && order.toSet().size == order.size && order.all { it in builtIn || it in shortcuts }
}

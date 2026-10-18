package com.zekitazegul.kuranapp

object DashboardCardOrder {
    private val builtIn = setOf("hatim", "meal", "history", "search", "bookmarks", "support", "settings")

    fun isValid(order: List<String>, shortcuts: Set<String>): Boolean {
        val allowed = builtIn + shortcuts
        return order.size <= allowed.size && order.toSet().size == order.size && order.all { it in allowed }
    }
}

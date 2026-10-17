package com.zekitazegul.kuranapp

/** A stop request never changes the current verse; only its completion can advance. */
class VersePlaybackQueue<T>(private val verses: List<T>) {
    init { require(verses.isNotEmpty()) }
    private var index = 0
    var stopPending = false
        private set
    val current: T get() = verses[index]
    fun requestStop() { stopPending = true }
    fun completeVerse(): Boolean {
        if (stopPending || index + 1 >= verses.size) return false
        index++
        return true
    }
}

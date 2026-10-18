package com.zekitazegul.kuranapp

/** A stop request never changes the current verse; only its completion can advance. */
class VersePlaybackQueue<T>(private val verses: List<T>, private val repetitions: Int = 1,
    val cumulative: Boolean = false) {
    init { require(verses.isNotEmpty()); require(repetitions in 1..999) }
    private var index = 0
    private var repetition = 0
    private var stage = if (cumulative) 0 else verses.lastIndex
    var stopPending = false
        private set
    val current: T get() = verses[index]
    fun requestStop() { stopPending = true }
    fun advanceStage(): Boolean {
        if (!cumulative || stopPending || stage == verses.lastIndex) return false
        stage++; index = 0; repetition = 0
        return true
    }
    fun completeVerse(): Boolean {
        if (stopPending) return false
        if (index < stage) { index++; return true }
        if (repetition + 1 < repetitions) { repetition++; index = 0; return true }
        return advanceStage()
    }
}

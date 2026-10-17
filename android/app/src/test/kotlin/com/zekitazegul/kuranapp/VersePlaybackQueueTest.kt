package com.zekitazegul.kuranapp

import org.junit.Assert.*
import org.junit.Test

class VersePlaybackQueueTest {
    @Test fun stopWaitsUntilCurrentVerseCompletes() {
        val queue = VersePlaybackQueue(listOf(1, 2, 3))
        queue.requestStop()
        assertEquals(1, queue.current)
        assertTrue(queue.stopPending)
        assertFalse(queue.completeVerse())
        assertEquals(1, queue.current)
    }
    @Test fun chapterAdvancesOneVerseAtATime() {
        val queue = VersePlaybackQueue(listOf(1, 2, 3))
        assertTrue(queue.completeVerse())
        assertEquals(2, queue.current)
        queue.requestStop()
        queue.requestStop()
        assertEquals(2, queue.current)
        assertFalse(queue.completeVerse())
    }
    @Test fun singleVerseFinishesNaturally() {
        val queue = VersePlaybackQueue(listOf(17))
        assertFalse(queue.stopPending)
        assertFalse(queue.completeVerse())
        assertEquals(17, queue.current)
    }
    @Test fun chapterStopsAfterItsLastVerse() {
        val queue = VersePlaybackQueue(listOf(1, 2))
        assertTrue(queue.completeVerse())
        assertFalse(queue.completeVerse())
    }
    @Test(expected = IllegalArgumentException::class)
    fun emptyQueueIsRejected() { VersePlaybackQueue(emptyList<Int>()) }
}

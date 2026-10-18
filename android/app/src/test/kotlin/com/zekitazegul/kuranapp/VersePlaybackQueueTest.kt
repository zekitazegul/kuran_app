package com.zekitazegul.kuranapp

import org.junit.Assert.*
import org.junit.Test

class VersePlaybackQueueTest {
    @Test fun cumulativeRangeIncludesBothEndpoints() {
        val queue = VersePlaybackQueue(listOf(1, 2, 3), 3, true)
        val played = mutableListOf(queue.current)
        while (queue.completeVerse()) played.add(queue.current)
        assertEquals(listOf(1,1,1, 1,2,1,2,1,2, 1,2,3,1,2,3,1,2,3), played)
    }
    @Test fun earlyAdvanceRestartsAtFirstVerseOfNextStage() {
        val queue = VersePlaybackQueue(listOf(5,6,7), 3, true)
        assertTrue(queue.advanceStage())
        assertEquals(5, queue.current)
        assertTrue(queue.completeVerse())
        assertEquals(6, queue.current)
        assertTrue(queue.advanceStage())
        assertEquals(5, queue.current)
        assertFalse(queue.advanceStage())
    }
    @Test fun oneRepeatStillVisitsEveryCumulativeStage() {
        val queue = VersePlaybackQueue(listOf(5,6,7), 1, true)
        val played = mutableListOf(queue.current)
        while (queue.completeVerse()) played.add(queue.current)
        assertEquals(listOf(5,5,6,5,6,7), played)
    }
    @Test fun stopPreventsEarlyAdvance() {
        val queue = VersePlaybackQueue(listOf(5,6), 3, true)
        queue.requestStop()
        assertFalse(queue.advanceStage())
        assertFalse(queue.completeVerse())
    }
    @Test fun memorizationRepeatsTheWholeRangeExactlyTenTimes() {
        val queue = VersePlaybackQueue(listOf(5, 6, 7), 10)
        val played = mutableListOf(queue.current)
        while (queue.completeVerse()) played.add(queue.current)
        assertEquals((1..10).flatMap { listOf(5, 6, 7) }, played)
    }
    @Test fun memorizationStopPreventsTheNextRepetition() {
        val queue = VersePlaybackQueue(listOf(5, 6), 10)
        assertTrue(queue.completeVerse())
        queue.requestStop()
        assertEquals(6, queue.current)
        assertFalse(queue.completeVerse())
    }
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

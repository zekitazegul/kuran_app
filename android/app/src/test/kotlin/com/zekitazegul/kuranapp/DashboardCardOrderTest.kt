package com.zekitazegul.kuranapp

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class DashboardCardOrderTest {
    @Test fun hatimCanBeSavedInAnyPosition() {
        assertTrue(DashboardCardOrder.isValid(listOf("hatim", "search", "support"), emptySet()))
        assertTrue(DashboardCardOrder.isValid(listOf("support", "search", "hatim"), emptySet()))
    }
    @Test fun allCardsAndTwentyFourShortcutsCanBeSaved() {
        val shortcuts = (1..24).map { "surah:$it" }.toSet()
        val cards = listOf("hatim", "meal", "history", "search", "bookmarks", "support", "settings")
        assertTrue(DashboardCardOrder.isValid(cards + shortcuts, shortcuts))
    }
    @Test fun rejectsDuplicatesAndUnknownCards() {
        assertFalse(DashboardCardOrder.isValid(listOf("hatim", "hatim"), emptySet()))
        assertFalse(DashboardCardOrder.isValid(listOf("unknown"), emptySet()))
        assertFalse(DashboardCardOrder.isValid(listOf("surah:1"), emptySet()))
        assertTrue(DashboardCardOrder.isValid(emptyList(), emptySet()))
    }
}

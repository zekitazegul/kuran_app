package com.zekitazegul.kuranapp
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
class BottomShortcutOrderTest {
    @Test fun acceptsHomeCardsAndPersonalShortcuts() {
        for (id in listOf("hatim", "meal", "history", "search", "bookmarks", "support", "settings", "surah:36", "juz:30")) {
            assertTrue(id, BottomShortcutOrder.isValid(listOf("home", id), setOf("surah:36", "juz:30")))
        }
        assertTrue(BottomShortcutOrder.isValid(emptyList(), emptySet()))
        assertTrue(BottomShortcutOrder.isValid(listOf("home", "meal", "support", "surah:36", "juz:30"), setOf("surah:36", "juz:30")))
    }
    @Test fun rejectsInvalidEntries() {
        assertFalse(BottomShortcutOrder.isValid(listOf("listen"), emptySet()))
        assertFalse(BottomShortcutOrder.isValid(listOf("unknown"), emptySet()))
        assertFalse(BottomShortcutOrder.isValid(listOf("surah:36"), emptySet()))
        assertFalse(BottomShortcutOrder.isValid(listOf("home", "home"), emptySet()))
        assertFalse(BottomShortcutOrder.isValid(listOf("home", "meal", "support", "hatim", "exit", "settings", "history"), emptySet()))
    }
}

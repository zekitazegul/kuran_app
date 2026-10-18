package com.zekitazegul.kuranapp

import org.junit.Assert.assertEquals
import org.junit.Test

class AudioReciterSelectionTest {
    private val available = setOf("shatri", "alafasy", "minshawi", "abdulbasit", "maher")
    @Test fun completeSavedReciterIsPreserved() {
        for (reciter in available) assertEquals(reciter, AudioReciterSelection.restore(reciter, available))
    }
    @Test fun removedRecitersMigrateToDefault() {
        for (removed in listOf("mehmet_emin_ay", "mustafa_ismail", "unknown"))
            assertEquals("shatri", AudioReciterSelection.restore(removed, available))
    }
    @Test fun firstLaunchUsesDefault() {
        assertEquals("shatri", AudioReciterSelection.restore(null, available))
    }
}

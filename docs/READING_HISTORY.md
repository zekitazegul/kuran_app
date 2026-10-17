# Reading history and app navigation — 1.0.1+15

Reading history is stored privately on the device in `reading-history.json` using
Android AtomicFile. Existing downloads, bookmarks and reading positions are retained.
History survives app updates and edition removal; uninstalling the app removes it.

A page is recorded after a two-second visibility check while the reader route is
current and the app is in the foreground. Fast page turns do not add entries.
Adjacent pages with the same surah labels, edition, session and local calendar date
merge into one range. Jumps, foreground sessions, surah changes, a gap of 30 minutes
and date changes create separate entries. On a surah start page the new surah names
are used. The displayed timestamp is the most recently recorded page in the range,
formatted with the device's local time. Entries appear newest first.

History rows open the original edition and first page of the range. An edition
removed from the device must be downloaded again before opening the page.

The app hides Android status and system navigation bars using immersive sticky
mode. Android can temporarily reveal its bars with a system gesture. App shortcuts
remain at the bottom in portrait. In landscape fullscreen/frame zoom, the bar
fades and slides downward over 320 ms, releasing its space to the reader. It
returns when leaving fullscreen or rotating back to portrait. Reduced-motion
settings disable the transition. Defaults: Home, Bookmarks,
Surahs, Reading history. Settings → Appearance and shortcuts allows reordering,
adding and removing destinations (2–5 total). Home remains available. Choices are
stored alongside existing global UI preferences; old installations receive defaults.

Device checks: read Yasin 439 and 440 for at least two seconds each; verify one
range, local date/time, newest-first ordering and persistence after relaunch.
Switch editions; check independent history labels and reopening. Verify no history
is created while backgrounded or covered by a settings route. Reorder the bottom
shortcuts, relaunch, try each destination and check portrait/landscape layouts.

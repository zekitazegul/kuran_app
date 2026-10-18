# Code, performance and stability review — 1.0.36+51

## Changes

- Release each delivered `ImageInfo` in `ReadingPage`; retain only the explicitly cloned image owned by the widget. Clear the previous image and error when resolving another page.
- Decode the 1.8 MB verse-region JSON in a Flutter background isolate. Preserve the existing single-flight load, cache and retry behavior.
- Remove the unused Cupertino icon package and its lockfile entry.
- Use an explicit meal asset list. The 1,945,138-byte extraction draft remains a development artifact and is no longer bundled. The extractor still uses it for diagnosing invalid verse ordering.
- Remove 12 root-level temporary screenshots, UI dumps and the obsolete `KuranApp-1.0.0.apk` (50,065,233 bytes altogether).
- Ignore recurring root-level device captures. Hide generated build, Dart and IDE files in VS Code and exclude them from searches. Keep SDK caches required for development, signing credentials, distribution material and source PDFs.
- Increment build to 51 and synchronize update notes in Turkish, English and Dutch.

## Further findings

- `home_pages.dart` and `listening_screen.dart` are absent from the production entry-point import graph but remain heavily used by historical widget tests. Remove them together with migration of those tests to the current single-home/shared-reader flow; deleting only the tests would discard useful behavior coverage. Flutter already excludes unreachable Dart code from release compilation.
- Native `ReadingStorage.load()` validates every downloaded page. This favors detection of damaged files but adds filesystem work at startup. A future optimization needs a persistent validation manifest with invalidation on file changes; blindly skipping validation weakens offline recovery.
- Audio refresh can return and reconstruct the track catalog. A separate playback-status response would reduce channel traffic while retaining the existing full response for initial load and reciter changes.
- Translation screens still parse larger text assets on the UI isolate. The same background-decoding approach can be extended after measuring those paths and checking text pagination memory.
- The application depends on native Android channels. Other platform directories are Flutter scaffolding, not verified working ports. They were retained rather than assuming Android-only support is a permanent product decision.

## Verification

- Full existing Flutter suite: 168 passed, including phone/tablet portrait/landscape and locale cases.
- Added regression: replacing a loaded page with a pending image clears the old image and displays loading until the new image arrives; passed.
- `flutter analyze`: no issues found after the new regression test.
- Final asset-list/update-dialog/meal regression and release/device verification are recorded in the build 51 delivery report.

No numerical speedup or long-term crash-rate reduction is claimed from static inspection and smoke tests.

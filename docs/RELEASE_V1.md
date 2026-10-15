# KuranApp v1

Saved checkpoint: 15 October 2026. Git tag: `v1`.
Visible version: 1.0.0. Android build/version code: 14.
The previous development build code was 13, so code 14 allows updating existing
installations despite resetting the public version name to 1.0.0.
The pre-existing historical `v1.0.0` tag is preserved; `v1` identifies this checkpoint.

Included: three Quran script editions, private offline downloads/removal,
page/surah/juz search, bookmarks and resume, realistic page turns, two-stage
frame zoom, fullscreen exit gestures, sajdah reminders, TR/EN/NL, themes,
custom shortcuts, optional coffee support and feedback. All features are free.
No advertisements, accounts, billing or subscription SDKs are included.

Listening screens and download/play/delete groundwork are included, but the
recording catalog is empty. There is no playable audio in v1. v2 is planned for
licensed recordings and tested surah/verse listening. Attribution is documented;
source distribution permissions still need verification before public release.

Validation on the Flutter workstation:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

This checkpoint is not a claim that the latest Flutter/device tests have passed.
The cloud environment performed syntax checks only. The Git tag does not publish
an app to Google Play or create an APK/GitHub Release automatically.

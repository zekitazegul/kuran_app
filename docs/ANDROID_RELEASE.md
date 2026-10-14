# Android development and release checks

Version 1.1.1+3 targets Android. No iOS distribution is prepared.

## Build on the existing Flutter workstation

```powershell
git pull origin main
flutter pub get
flutter analyze
flutter test
flutter run --release -d R5CXB20Q1CD
```

For a standalone APK: `flutter build apk --release`.
Output: `build/app/outputs/flutter-apk/app-release.apk`.
Use the existing signing key to update an installed APK.

## Source and numbering

The user supplied `content/kuran-bilgisayar-hatti.pdf` (24,129,254 bytes).
Colophon: Diyanet İşleri Başkanlığı, Kur’an-ı Kerim (Rahle Boy), computer
script by Süleyman Feyzullahoğlu, Ankara 2018. This is not a Diyanet-endorsed app.
Original PDF SHA-256:
`fa88e87198fa9cadee797cd3ac1d3d41e4c4c7776d97b4fee02c32e0a14cb0f7`.

The downloader retrieves this exact file from the immutable GitHub revision
recorded in ReadingStorage.kt, using HTTPS and verifying its SHA-256 before
opening it. Android PdfRenderer converts pages to PNG in private storage.
No image/font substitutions are made. PDF has 616 physical pages:
- PDF 1: blank; excluded.
- PDF 2: unnumbered Fatiha, represented as page 0 in the app.
- PDF 3–606: printed pages 1–604.
- PDF 607–616: approval, prayers, index/colophon; excluded from the reader.
- Yasin starts at printed page 439 (physical PDF 441).

All 114 surah starts were indexed from the PDF's surah banners, including
the smaller Sad banner. The index is specific to this edition, not Madani.
The supplied Yasin assets visually match physical PDF 441 onward.

The previous Madani download and reading records are left in their separate
private directory/preferences. They are not mixed with the new edition or
silently mapped to different verses. This edition starts with its own saved
page/bookmarks. Existing offline Yasin assets remain available until download.

## Required local/device verification

Flutter is unavailable in the cloud environment. Syntax parsing and PDF/index
checks passed there; actual Flutter tests/build and device rendering remain
required. Test:
- First launch disclosure, explicit download confirmation, and relaunch.
- Download the 24 MB PDF, verify progress through 605 prepared pages. Pause,
  restart and resume without downloading the PDF again. Check disk/network errors.
- Compare Fatiha, Bakara, Sad, Yasin 439, and final 604 against the PDF.
- Read in airplane mode; search/select surahs and jump to 439.
- Reject invalid input; allow 0 for Fatiha and 604 for the last page.
- Bookmarks/last page survive force-stop and APK update.
- Slowly drag a page at top/middle/bottom: fold tracks the finger. Short drags
  return to the original page; completed turns save the target page.
- Zoom, pinch, orientation, fast repeated gestures, and first/last boundaries.
- Screen stays on in foreground; normal timeout resumes in background.

## Google Play preparation (not publication)

Before public distribution, confirm the supplied PDF's applicable distribution
terms with the publisher. The uploaded file itself is not evidence of a license.
Use a signed tested APK first, then `flutter build appbundle --release`.
Preserve the production signing key and keep credentials out of Git.
Verify current Play target API policy, merged manifest and testing requirements.
Publish a privacy policy URL with developer identity/contact and complete
Data safety, content rating, store listing, and required account testing.
The in-app information screen is not a replacement for these Play requirements.

Only INTERNET is declared in the main manifest. No camera, microphone,
location, contacts, notification or broad storage permission is requested.
Reading state/pages remain in private storage; Android cloud backup is disabled.
There are no analytics/ads/accounts. GitHub receives network connection
information during downloads; privacy disclosures must describe this accurately.

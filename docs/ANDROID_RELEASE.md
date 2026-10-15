# Android development and release checks

Version 1.5.0+12 targets Android. No iOS distribution is prepared.

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

The original computer-script source is `content/kuran-bilgisayar-hatti.pdf` (24,129,254 bytes).
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
The original standalone Yasin images and their legacy reader have been removed.
Yasin now uses the selected complete PDF edition only.

The previous Madani download and reading records are left in their separate
private directory/preferences. They are not mixed with the new edition or
silently mapped to different verses. This edition starts with its own saved
page/bookmarks. There is no standalone Yasin fallback; the selected edition must be downloaded.

## Required local/device verification

Flutter is unavailable in the cloud environment. Syntax parsing and PDF/index
checks passed there; actual Flutter tests/build and device rendering remain
required. Test:
- First launch disclosure, explicit download confirmation, and relaunch.
- Download each selected PDF (computer ~24 MB, Hat 2 ~28 MB, Hüsrev ~74 MB),
  verify progress through 605 prepared pages. Pause,
  restart and resume without downloading the PDF again. Check disk/network errors.
- Compare Fatiha, Bakara, Sad, Yasin 439, and final 604 against the PDF.
- Read in airplane mode; search/select surahs and jump to 439.
- Reject invalid input; allow 0 for Fatiha and 604 for the last page.
- Bookmarks/last page survive force-stop and APK update.
- Slowly drag a page at top/middle/bottom: fold tracks the finger. Short drags
  return to the original page; completed turns save the target page.
- Tap left 40% for next page, right 40% for previous; central 20% toggles
  borderless reading. Verify no turn after a pinch or vertical pan, and check
  first/last boundaries. Existing downloaded images are kept unchanged.
- In borderless mode inspect all verse edges, including special Fatiha/Bakara
  title pages. Frames and outer headings/numbers should be absent. Wide screens
  allow vertical panning to avoid cutting off verses. Tap center to restore UI.
- Rotate to landscape: width-fitted page starts at top in normal and borderless
  modes. Swipe up to read; at the bottom continue the upward drag to turn once
  to the next page, which starts at the top. Final page must not advance.
  Pinching, inertial scrolling, and returning to portrait must not skip pages.
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


## Home, guide and preferences

First launch runs privacy information and a usage guide once; each is reachable
from Settings afterwards. The guide flag and animation toggle are persisted in
the existing computer-script preferences without resetting downloads/bookmarks.
Verify toggle off for tap, drag and bottom-pull navigation, then relaunch to check
persistence. Android reduced-motion settings also suppress page animations.
Check home tiles and Settings at large system font sizes and in landscape.

The edition catalog is `assets/editions.json`, bundled for both Flutter and the
native downloader. Computer script, supplied Hat 2 and Hüsrev are independently
selectable in Settings. Each has an immutable source URL, exact byte count,
SHA-256, own PDF offset, first/last page, 114-surah index and crop rectangles.
Hat 2 has different odd/even margins. Its footer metadata was indexed separately;
the unbracketed “86 TÂRIK” footer is accounted for explicitly.

Computer files/preferences keep their original names; no migration/reset occurs.
Selected edition, animation preference and first-use flags remain global. Each
edition retains separate downloads, bookmarks and last-read position. Changing
edition from the reader returns to Home if a download is needed. Settings are
unavailable during an active Home download to avoid mixing editions.

Hüsrev source is now present at `content/kuran-husrev-hatti.pdf`, added by the
user in commit 76729c0. File is 74,138,596 bytes, SHA-256
`c3f4173f8c410db4301f1c21152ff901c8323eb702971c6c8aab7f0ca51a7ba6`.
It has 605 scanned pages with no text layer, no blank cover and no end matter.
PDF index 0 = Fatiha (app page 0), index 439 = Yasin (app page 439).
All 114 surah panels were independently identified using their broad gold fill,
then checked against chronological order, page coverage and the known starts.
The resulting starts agree with the existing computer-script edition.
Individual physical page heights and crop bounds are supplied for all 605 pages;
Dart layout/cropping uses those instead of assuming one fixed PDF aspect ratio.
Opening pages have individually inspected text-area crops.

The original computer-script and Hat 2 entries, file directories/preferences,
source revisions and SHA-256 values remain unchanged. Hüsrev uses `husrev-v1`
and `reading-husrev-v1`. Switching must never reset another edition's records.

Local tests: `flutter analyze` and `flutter test` (including edition isolation).
On device, select Hat 2 and Hüsrev, download each, check navigation/crops, add a
bookmark and save a page, then switch back. Computer downloads/bookmarks must
remain unchanged. Repeat after relaunch; check Settings from both Home/reader.
The Flutter SDK is absent in the cloud, so these tests are not claimed passed.

Optional support: default builds use the developer-owned support page
https://zekitazegul.github.io/support/. Override it with another owned HTTPS profile using
`--dart-define=SUPPORT_URL=https://...` on the Flutter build/run command.
Native code validates HTTPS and an exact provider hostname; opening the browser
requires an explicit confirmation. There is no payment SDK, paid feature or
financial credential in the app. The missing-link state must not open a fake
checkout. Recheck current Google Play payment policy for the intended region
and the exact support flow before publication; do not assume external payment
links are universally permitted.


## Quran visual identity

`assets/branding/quran.png` is original generated Quran-on-rehal artwork with a
transparent background, used on Home, Settings and the first-use guide.
No scripture or invented lettering is included. Native Android uses the same
artwork in `drawable-nodpi/quran_launcher_foreground.png`, with adaptive icon
padding and an emerald background, plus a legacy layer-list fallback. Both
roundIcon and icon refer to the same adaptive resource. Old Flutter launcher
PNGs were removed. Pre-Android-12 launch backgrounds use the new artwork too.

Validate `flutter analyze`, `flutter test` and a signed release on device. Check
Samsung launcher masks, splash appearance, image transparency, large text,
landscape and narrow-screen Home layout. Visual resource/layout checks in the
cloud do not replace a Flutter build or an actual device screenshot.


## Languages and narrow tap regions

First launch chooses Türkçe, English or Nederlands before privacy/guide.
The top-right selector changes the entire UI immediately and stores the choice
in global preferences without changing the selected PDF, bookmarks or page.
Flutter SDK localization delegates also translate Material controls/tooltips.
The Arabic page images are never translated. Surah labels use the Turkish
names for Turkish and conventional transliterations (e.g. Al-Baqarah, Ali 'Imran)
for English and Dutch, not translated meanings such as “Cow”. Search indexes
both sets of names and removes accents, spaces, apostrophes and hyphens.

Page taps turn only inside approximately 1 cm left/right strips, estimated from
Android xdpi and density (reported physical DPI can vary by device). The broad
center toggles fullscreen with a single tap. Pulling down from the very top
exits fullscreen; ordinary downward scrolling within a page does not. Check
portrait/landscape, pinch zoom, short pages and bottom-pull advancement on S24+.
The two marketing slogans were removed. The shared artwork now depicts an open
Quran seated directly on the V-shaped wooden rehal rather than a closed book.

Run `flutter pub get`, `flutter analyze`, `flutter test` locally, then the signed
release on device. Flutter localization is an SDK dependency; commit the lockfile
produced by the same pinned Flutter toolchain when it is refreshed locally.

### Developer support link

The optional coffee support card defaults to https://zekitazegul.github.io/support/ in both
About and Settings. It opens externally after confirmation. No payment details
are handled by the app. `SUPPORT_URL` remains an optional build-time override.

The support page currently links to the developer-provided Tikkie request valid
through 27 October 2026 (Europe/Amsterdam). Its button is hidden after that date.
Renew the link and expiry in the website repository `support/index.html`; an app
update is not needed. Verify amount/recipient and bank handoff on a real device.

### Sources and advertising policy

KuranApp remains free and without ads; no advertising SDK is integrated.
About, Settings and Privacy link to Sources and copyright (TR/EN/NL).
Diyanet and Ahıska credits are taken from PDF page 616 of their respective
files. The Hüsrev Altınbaşak / Hayrat Neşriyat association is user supplied
and explicitly unverified for the particular 605-page scan. Attribution
is not a verified distribution licence; no publisher endorsement is claimed.

### 1.5.0+12 — home rows, personalization and free listening groundwork

Home now lists Search, Bookmarks, configured surah/juz shortcuts (default Al-Fath,
Ya-Sin), Support and Settings as compact full-width rows. The library heading is
removed. Settings → Appearance and shortcuts persists system/light/dark mode,
four accent colors, and up to 24 unique shortcuts with reorder/delete/reset.
Preferences are global across editions; Quran PDF colors/crops remain unchanged.

All features are free. No premium state, billing SDK, account flow or subscription
product exists. Coffee support remains optional and separate from feature access.

Reader → Listen and Settings → Listen offer a surah or a single verse selection.
The audio catalog `assets/audio.json` intentionally contains no recordings; the UI
explains unavailable recordings instead of enabling fake download/play buttons.
The Android audio channel provides private verified downloads, local playback,
stop and delete. A separate HandlerThread serializes MediaPlayer work. Playback
stops when leaving the listening screen or backgrounding the app; background
playback is not part of this release. No new Android permission was introduced.

Before adding a recording, obtain distribution permission and add a track:
`id` (lowercase letters/digits/underscore/hyphen, max 80), `surah` (1–114),
`verse` (null for complete surah, otherwise exact verse), `url` (HTTPS), `bytes`
(exact size, max 500 MB), and `sha256` (64 lowercase hex characters). All redirect
hops must remain on the declared source host. Files are stored only after size
and SHA-256 validation. Whole-surah recordings are not substituted for verse
recordings: single verses require separate files (or a future timing index).
Use `license` and `reciter` metadata to record provenance when populating the
catalog. Audio is not packaged in the APK and is downloaded only on user request.
Device checks with real licensed audio and audio-focus handling are required
before releasing actual recordings. The empty-catalog UI can be tested now.

Run `flutter analyze` and `flutter test`, then verify on phone and tablet: menu
order, dark/system theme, each accent, add/reorder/remove a surah and a juz shortcut,
relaunch persistence, independent edition bookmarks, reader Listen selection and
missing-audio message. Cloud syntax checks are not a Flutter/Kotlin build.

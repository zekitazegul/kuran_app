# KuranApp

Free, ad-free Android Quran reader with Turkish, English and Dutch interfaces.
Translation content is Turkish.

## Features

- Three Quran script editions, offline reading after download and saved reading progress.
- Surah, juz and page selection; edition-specific bookmarks with creation dates.
- A draggable bookmarks panel and confirmation before deleting a bookmark.
- Screen-sized translation pages, horizontal swiping, font controls and full-screen mode.
- Reading history, hatim tracking, surah/verse/page audio and offline downloaded recordings.
- Themes, colors, home cards, personal shortcuts and customizable bottom navigation.
- Release notes shown once per version in the last-used interface language.

## Development

Requires Flutter and Android SDKs. Development SDK: Flutter 3.47.5.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Native Android logic tests:

```sh
cd android
./gradlew :app:testDebugUnitTest
```

## Release builds

```sh
flutter build apk --release
flutter build appbundle --release
```

Supply your own local `android/key.properties` and signing keystore. Signing
credentials, private keys and build artifacts are excluded from Git. Back up
your signing credentials securely. The AAB output is
`build/app/outputs/bundle/release/app-release.aab`.

Increment the build number and update release notes in all three languages
for each delivered update. See [release instructions](docs/RELEASE_UPDATES.md)
and [project rules](AGENTS.md).

## Content and privacy

Reading records stay on the device. There are no accounts, ads or analytics SDKs.
Quran pages and audio are downloaded over HTTPS at the user's request. Download
servers can see network request metadata such as IP addresses. Optional support
links open in an external browser.

Source code and third-party content have separate rights. Distribution rights
for Quran scans, the Ali Unal translation and EveryAyah audio are not assumed.
Verify and document the relevant permissions before public store distribution.
Source attribution alone is not a licence.

Technical notes: [translation audit](docs/MEAL_AUDIT.md),
[audio and translation](docs/LISTENING_AND_MEAL.md),
[reading history](docs/READING_HISTORY.md).


## Kuran Installer

TR: Paylaş düğmesi yalnızca küçük Kuran Installer dosyasını gönderir. Alıcı uygulamayı internetten indirip Android onayıyla kurar. Sesler isteğe bağlı indirilir. Güncelle, Paylaş ve Ekranı açık tut bölümleri açılabilir başlıklardır; Görünüm ve okuma en üsttedir.

EN: Share sends only the small Kuran Installer file. The recipient downloads the app and installs it with Android confirmation. Audio downloads are optional. Update, Share and Keep screen on use expandable headings; Appearance and reading comes first.

NL: Delen verstuurt alleen het kleine Kuran Installer-bestand. De ontvanger downloadt en installeert de app met Android-bevestiging. Audiodownloads zijn optioneel. Bijwerken, Delen en Scherm aanhouden zijn uitklapbare koppen; Weergave en lezen staat bovenaan.

Build: `flutter build apk --release` builds the native installer from source and embeds it in the main APK. Both modules use the existing local release signing configuration. Never commit credentials or generated APKs. `powershell -ExecutionPolicy Bypass -File tools/publish_release.ps1 -PrepareOnly` verifies and prepares the artifacts without publishing. Publish only after validating the build and the phone workflow.

Download counts: `powershell -ExecutionPolicy Bypass -File tools/download-counts.ps1` reads public GitHub asset download counts without API keys. Repeated downloads and development checks count too; these are not device or user counts.

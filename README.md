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
./gradlew testReleaseUnitTest
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

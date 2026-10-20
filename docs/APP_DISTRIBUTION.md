# APK sharing and in-app updates

Settings exposes APK sharing and a user initiated update check. Release metadata is downloaded from https://github.com/zekitazegul/kuran_app/releases/latest/download/update.json without opening a browser. Only a larger versionCode triggers a download. SHA-256, package name, exact versionCode and installed signing certificate are checked before opening Android installation confirmation. Unknown-source permission denial and cancelled installation remain retryable. Do not replace the existing Android signing key.

To release: increase the version/build in pubspec.yaml, update the tr/en/nl notes in translations.dart and update_dialog.dart, run flutter analyze and flutter test, build with flutter build apk --release, test on the Wi-Fi phone, then run powershell -File tools/publish_release.ps1. The tool uploads KuranApp.apk and update.json to a single immutable version tag. No GitHub authentication is embedded in the app. The GitHub repository and release assets must be public.

TR: Kullanıcı GitHub sayfası görmez; yalnızca Android kurulum onayı ve gerekirse kurulum izni açılır.
EN: Users never see a GitHub page; Android installation confirmation and, if needed, installation permission are shown.
NL: Gebruikers zien geen GitHub-pagina; Android toont installatiebevestiging en zo nodig toestemming voor installatie.

The manifest includes sizeBytes. Download confirmation shows MB before transferring the APK. On mobile data, files at or below 2 MiB require explicit mobile-data consent; larger files also recommend Wi-Fi. Download status shows percentage and total MB. Android permission and Play Protect screens cannot be removed by the app.

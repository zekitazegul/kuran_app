# Android development and release checks

This version targets Android. No iOS distribution is prepared.

## Build on the existing Flutter workstation

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

APK: `build/app/outputs/flutter-apk/app-release.apk`. The Gradle output
directories have been aligned with Flutter to fix the earlier missing-APK error.
This correction must be verified on the local Flutter workstation.
Use the existing signing key to update an installed APK. Version: 1.1.0+2.

## Mandatory device validation

- First launch shows information; acknowledgement survives restart.
- Existing six Yasin assets still work without an internet connection.
- Download starts only after explicit confirmation. Pause, restart and resume;
  already validated pages are not downloaded again. Retry network and disk errors.
- Verify all 604 pages actually download and can be decoded; check Fatiha, Bakara,
  Yasin (440), page 439 and page 604 against the source mushaf.
- Turn off internet and read downloaded pages. Check all 114 surah selections.
- Invalid page input (empty, 0, 605) is rejected; 439 opens page 439.
- Bookmarks and last page survive force-stop/relaunch. Update the existing APK.
- Swipe in both directions, test slow swipes, zoom, rotation, first/last boundaries,
  fast repeated taps, large font settings and reduced motion.
- Check page curling visually on Galaxy S24+. Animations have not been device-tested.
- Screen stays on in foreground and resumes normal timeout in background.

## Content provenance and remaining release gate

Images: `https://android.quran.com/data/width1024/page001.png` through
`page604.png`. This URL construction is documented by Quran for Android's
MadaniPageProvider and QuranFileUtils at upstream commit
`a823af79a577d0d09db38681c4b6cfab4a5253a9`. The image generator identifies the underlying fonts and pages
as belonging to King Fahd Quran Complex, separately from the generator's GPL
code: https://github.com/quran/quran.com-images . No upstream application code
is incorporated here. Surah names and page ranges are factual indexing metadata.

The page host is blocked in the cloud execution environment, so actual download
availability, visual correctness and image distribution/use terms have NOT been
verified here. Confirm applicable image usage terms with the content publisher
before public distribution, or supply an appropriately licensed equivalent source.
Do not describe this build as Play Store ready until these checks are complete.

## Google Play preparation (not publication)

- Run a release build and test the signed APK on a device first.
- Preserve the production signing key; never commit it or its passwords.
- Build an Android App Bundle: `flutter build appbundle --release`.
- Verify the current Play target API policy and merged release manifest.
- Publish a public privacy policy URL with developer identity/contact; match the
  actual network, backup and local-storage behavior. The in-app screen alone is
  not a substitute for the Play privacy policy and Data safety declaration.
- Complete content rating, Data safety, store listing and any account-specific
  testing requirements. No camera/location/contacts/storage runtime permissions
  are requested. Internet is a normal manifest permission, not a runtime prompt.
- This version has no analytics, ads or accounts. Download server receives network
  connection information. Do not blindly select “no data collected” without
  reviewing the provider and Play's definitions.

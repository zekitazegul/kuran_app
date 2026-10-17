# Release update notes

For each update installed on a phone:

1. Increment the build number in `pubspec.yaml` (and the version name when appropriate).
2. Replace `latestUpdateNotes` in `lib/widgets/update_dialog.dart` with the changes in that release.
3. Add English and Dutch translations for every note in `lib/l10n/translations.dart`.
4. Run `flutter test test/update_dialog_test.dart` and the tests relevant to the changes.

Android supplies the installed version name and build number. After restoring the saved language and completing onboarding, the home screen compares that version with the last acknowledged update. The close button saves the acknowledgement. The same installed version does not show the dialog again; a different version does.

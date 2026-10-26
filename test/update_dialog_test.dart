import 'package:kuran_app/widgets/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/compact_confirmation_dialog.dart';

void main() {
  for (final language in ['tr', 'en', 'nl']) {
    testWidgets('New release notes use saved $language once per version', (
      tester,
    ) async {
      String? seen;
      Map uiPreferences={};
      var version = '1.1.0+63';
      AppLanguage.instance.value = const Locale('tr');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
        if(call.method=='saveUiPreferences') { uiPreferences=(call.arguments as Map)['preferences'] as Map; return null; }
        if (call.method == 'acknowledgeUpdate') {
          seen = version;
          return null;
        }
        if (call.method == 'load') {
          return {
            'directory': '/test',
            'lastPage': 1,
            'bookmarks': <int>[],
            'downloaded': <int>[],
            'informationSeen': true,
            'guideSeen': true,
            'language': language,
            'appVersion': version,
            'seenUpdateVersion': seen,
            'uiPreferences':uiPreferences,
          };
        }
        return null;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(ReadingStore.channel, null);
        AppLanguage.instance.value = const Locale('tr');
      });
      Future<void> open() async {
        await tester.pumpWidget(KuranApp(key: UniqueKey()));
        await tester.pumpAndSettle();
      }

      Future<void> closeNotes() async {
        if (latestUpdateNotes.isEmpty) {
          expect(find.byType(CompactConfirmationDialog), findsNothing);
          if (find.byKey(const ValueKey('demo-skip')).evaluate().isNotEmpty) {
            await tester.tap(find.byKey(const ValueKey('demo-skip')));
            await tester.pumpAndSettle();
          }
          expect(seen, version);
          return;
        }
        expect(find.byType(CompactConfirmationDialog), findsOneWidget);
        expect(
          find.textContaining(translate(latestUpdateNotes.first, language)),
          findsOneWidget,
        );
        await tester.tap(find.text(translate('Kapat', language)));
        await tester.pumpAndSettle();
        if(find.byKey(const ValueKey('demo-skip')).evaluate().isNotEmpty) {
          await tester.tap(find.byKey(const ValueKey('demo-skip')));
          await tester.pumpAndSettle();
        }
        expect(uiPreferences['demoRevision'],3);
        expect(seen, version);
      }

      await open();
      expect(AppLanguage.instance.value?.languageCode, language);
      await closeNotes();
      await tester.pumpWidget(const SizedBox());
      await open();
      expect(find.byType(CompactConfirmationDialog), findsNothing);
      await tester.pumpWidget(const SizedBox());
      version = '1.1.1+64';
      await open();
      await closeNotes();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }
}

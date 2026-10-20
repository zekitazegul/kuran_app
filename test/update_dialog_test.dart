import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/compact_confirmation_dialog.dart';

void main() {
  for (final entry in const {
    'tr': ['Yenilikler · 1.0.2', 'Kapat'],
    'en': ['What’s new · 1.0.2', 'Close'],
    'nl': ['Nieuw · 1.0.2', 'Sluiten'],
  }.entries) {
    testWidgets('maintenance update uses saved ${entry.key} and acknowledges without a popup', (tester) async {
      String? seen;
      var version = '1.0.2+16';
      AppLanguage.instance.value = const Locale('tr');
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
        if (call.method == 'acknowledgeUpdate') {
          seen = version;
          return null;
        }
        if (call.method == 'load') {
          return {
          'directory': '/test', 'lastPage': 1, 'bookmarks': <int>[],
          'downloaded': <int>[], 'informationSeen': true, 'guideSeen': true,
          'language': entry.key, 'appVersion': version, 'seenUpdateVersion': seen,
          };
        }
        return null;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(ReadingStore.channel, null);
        AppLanguage.instance.value = const Locale('tr');
      });
      await tester.pumpWidget(KuranApp(key: UniqueKey()));
      await tester.pumpAndSettle();
      expect(find.text(entry.value.first), findsNothing);
      expect(AppLanguage.instance.value?.languageCode, entry.key);
      expect(seen, version);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(KuranApp(key: UniqueKey()));
      await tester.pumpAndSettle();
      expect(find.text(entry.value.first), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      version = '1.0.3+17';
      await tester.pumpWidget(KuranApp(key: UniqueKey()));
      await tester.pumpAndSettle();
      expect(find.byType(CompactConfirmationDialog), findsNothing);
      expect(seen, version);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }
}

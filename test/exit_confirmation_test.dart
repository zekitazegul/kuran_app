import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';

void main() {
  for (final entry in const {
    'tr': ['Çıkış?', 'İptal', 'Tamam'],
    'en': ['Exit?', 'Cancel', 'OK'],
    'nl': ['Afsluiten?', 'Annuleren', 'OK'],
  }.entries) {
  testWidgets('localized exit confirmation in ${entry.key}', (tester) async {
    AppLanguage.instance.value = Locale(entry.key);
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    var exits = 0;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.pop') exits++;
      return null;
    });
    messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async => {
      'directory': '/test', 'lastPage': 439, 'bookmarks': <int>[],
      'downloaded': List<int>.generate(605, (i) => i),
      'informationSeen': true, 'guideSeen': true,
    });
    try {
      await tester.pumpWidget(const KuranApp()); await tester.pumpAndSettle();
      await tester.binding.handlePopRoute(); await tester.pumpAndSettle();
      expect(find.text(entry.value[0]), findsOneWidget); expect(exits, 0);
      await tester.tap(find.text(entry.value[1])); await tester.pumpAndSettle();
      expect(find.text(entry.value[0]), findsNothing); expect(exits, 0);
      await tester.binding.handlePopRoute(); await tester.pumpAndSettle();
      await tester.tap(find.text(entry.value[2])); await tester.pumpAndSettle();
      expect(exits, 1);
      await tester.pumpWidget(const SizedBox());
    } finally {
      messenger.setMockMethodCallHandler(ReadingStore.channel, null);
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    }
  });
  }
}

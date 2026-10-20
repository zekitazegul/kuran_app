import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/data/quran_edition.dart';
import 'package:kuran_app/screens/settings_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('row trash confirms the named edition without changing the selected edition', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    final editions = (jsonDecode(File('assets/editions.json').readAsStringSync()) as List)
      .map((entry) => QuranEdition.fromMap(entry as Map)).toList();
    final store = ReadingStore(directory: '/test/computer', lastPage: 439,
      informationSeen: true, bookmarks: {439}, downloaded: Set<int>.from(List.generate(605, (i) => i)),
      downloadedBytes: editions.first.downloadBytes, edition: editions.first, editions: editions,
      downloadedEditions: {'computer', 'husrev'});
    final removed = <String>[];
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      expect(call.method, 'removeDownload'); removed.add((call.arguments as Map)['edition'] as String);
      return null;
    });
    try {
      await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Kur\u2019an hatt\u0131'), 300);
      await tester.ensureVisible(find.text('Kur\u2019an hatt\u0131'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kur\u2019an hatt\u0131'));
      await tester.pumpAndSettle();
      final trash = find.byKey(const ValueKey('remove-edition-husrev'));
      await tester.scrollUntilVisible(trash, 300);
      await tester.ensureVisible(trash); await tester.pumpAndSettle();
      await tester.tap(trash); await tester.pumpAndSettle();
      expect(find.textContaining('Hüsrev hattı dosyaları'), findsOneWidget);
      await tester.tap(find.text('Vazgeç')); await tester.pumpAndSettle();
      expect(removed, isEmpty);
      await tester.tap(trash); await tester.pumpAndSettle();
      await tester.tap(find.text('Kaldır')); await tester.pumpAndSettle();
      expect(removed, ['husrev']);
      expect(store.edition.id, 'computer'); expect(store.ready, isTrue);
      expect(store.lastPage, 439); expect(store.bookmarks, {439});
      expect(store.downloadedEditions, {'computer'});
      expect(tester.widget<IconButton>(trash).onPressed, isNull);
      await tester.pumpWidget(const SizedBox());
    } finally { messenger.setMockMethodCallHandler(ReadingStore.channel, null); }
  });
}

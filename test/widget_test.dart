import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/data/surahs.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var acknowledged = false;
  var guideSeen = false;
  var animations = true;
  var lastPage = 439;
  var bookmarks = <int>[439];

  setUp(() {
    acknowledged = false;
    guideSeen = false;
    animations = true;
    lastPage = 439;
    bookmarks = [439];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (call) async {
        switch (call.method) {
          case 'load': return {'directory': '/tmp/quran-test', 'lastPage': lastPage,
            'informationSeen': acknowledged, 'guideSeen': guideSeen, 'pageAnimations': animations, 'bookmarks': bookmarks, 'downloaded': <int>[]};
          case 'acknowledge': acknowledged = true; return null;
          case 'acknowledgeGuide': guideSeen = true; return null;
          case 'setPageAnimations': animations = (call.arguments as Map)['enabled'] as bool; return null;
          case 'savePage': lastPage = (call.arguments as Map)['page'] as int; return null;
          case 'saveBookmarks': bookmarks = List<int>.from((call.arguments as Map)['pages'] as List); return null;
          default: throw PlatformException(code: 'UNEXPECTED_METHOD');
        }
      });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, null);
  });

  test('114 surahs cover every page and known boundaries', () {
    expect(surahs.length, 114);
    expect(surahs[35].startPage, 439);
    expect(surahs.last.endPage, 604);
    for (var page = 0; page <= 604; page++) {
      expect(surahsOnPage(page), isNotEmpty, reason: 'Page $page');
    }
    expect(surahsOnPage(438).any((s) => s.number == 36), isFalse);
    expect(surahsOnPage(439).any((s) => s.number == 36), isTrue);
  });

  test('last page and bookmark updates persist through a new store', () async {
    final store = await ReadingStore.load();
    await store.savePage(604);
    await store.toggleBookmark(439);
    await store.toggleBookmark(440);
    final restored = await ReadingStore.load();
    expect(restored.lastPage, 604);
    expect(restored.bookmarks, {440});
    expect(restored.ready, isFalse);
  });

  testWidgets('first launch explains access before offering a download', (tester) async {
    await tester.pumpWidget(const KuranApp());
    await tester.pumpAndSettle();
    expect(find.text('Gizlilik ve uygulama erişimleri'), findsOneWidget);
    expect(find.text('Tam Kur’an’ı indir'), findsNothing);
    await tester.scrollUntilVisible(find.text('Anladım, devam et'), 400);
    await tester.tap(find.text('Anladım, devam et'));
    await tester.pumpAndSettle();
    expect(acknowledged, isTrue);
    expect(find.text('Kullanım kılavuzu'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Okumaya başlayalım'), 400);
    await tester.tap(find.text('Okumaya başlayalım'));
    await tester.pumpAndSettle();
    expect(guideSeen, isTrue);
    expect(find.text('Tam Kur’an’ı indir'), findsOneWidget);
    expect(find.text('Yasin Suresi · Çevrimdışı'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Tam Kur’an’ı indir'), 300);
    await tester.tap(find.text('Tam Kur’an’ı indir'));
    await tester.pumpAndSettle();
    expect(find.text('İndirmeyi başlat'), findsOneWidget);
    await tester.tap(find.text('İptal'));
    await tester.pumpAndSettle();
    expect(find.text('Hazırlanan sayfalar: 0 / 605'), findsOneWidget);
  });
  testWidgets('animation switch persists and help remains accessible', (tester) async {
    final store = await ReadingStore.load();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();
    expect(store.pageAnimations, isTrue);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(store.pageAnimations, isFalse);
    final restored = await ReadingStore.load();
    expect(restored.pageAnimations, isFalse);
    await tester.scrollUntilVisible(find.text('Kullanım kılavuzu'), 200);
    await tester.tap(find.text('Kullanım kılavuzu'));
    await tester.pumpAndSettle();
    expect(find.text('Okumaya hoş geldin'), findsOneWidget);
  });

}

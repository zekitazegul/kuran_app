import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/data/surahs.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/screens/settings_screen.dart';
import 'package:kuran_app/services/app_language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var acknowledged = false;
  var guideSeen = false;
  var animations = true;
  String? language;
  var lastPage = 439;
  var bookmarks = <int>[439];

  setUp(() {
    AppLanguage.instance.value = const Locale('tr');
    language = null;
    acknowledged = false;
    guideSeen = false;
    animations = true;
    lastPage = 439;
    bookmarks = [439];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (call) async {
        switch (call.method) {
          case 'load': return {'directory': '/tmp/quran-test', 'lastPage': lastPage,
            'language': language, 'informationSeen': acknowledged, 'guideSeen': guideSeen, 'pageAnimations': animations, 'bookmarks': bookmarks, 'downloaded': <int>[]};
          case 'setLanguage': language = (call.arguments as Map)['language'] as String; return null;
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

  test('source download is separate from page readiness and removal preserves reading records', () async {
    final store = await ReadingStore.load();
    store.downloadedBytes = store.edition.downloadBytes;
    store.downloaded.add(0);
    expect(store.sourceDownloaded, isTrue);
    expect(store.ready, isFalse);
    final savedPage = store.lastPage;
    final savedBookmarks = Set<int>.from(store.bookmarks);
    String? removedEdition;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (call) async {
        expect(call.method, 'removeDownload');
        removedEdition = (call.arguments as Map)['edition'] as String;
        return null;
      });
    await store.removeDownload();
    expect(removedEdition, store.edition.id);
    expect(store.downloadedBytes, 0);
    expect(store.downloaded, isEmpty);
    expect(store.sourceDownloaded, isFalse);
    expect(store.ready, isFalse);
    expect(store.lastPage, savedPage);
    expect(store.bookmarks, savedBookmarks);
  });

  testWidgets('first launch explains access before offering a download', (tester) async {
    await tester.pumpWidget(const KuranApp());
    await tester.pumpAndSettle();
    expect(find.text('Gizlilik ve uygulama erişimleri'), findsOneWidget);
    expect(find.text('İndirmeyi başlat'), findsNothing);
    await tester.scrollUntilVisible(find.text('Anladım, devam et'), 400);
    final informationButton = find.widgetWithText(FilledButton, 'Anladım, devam et');
    await tester.ensureVisible(informationButton);
    await tester.pumpAndSettle();
    await tester.tap(informationButton);
    await tester.pumpAndSettle();
    expect(acknowledged, isTrue);
    expect(find.text('Kullanım kılavuzu'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Okumaya başlayalım'), 400);
    final continueButton = find.widgetWithText(FilledButton, 'Okumaya başlayalım');
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    expect(continueButton.hitTestable(), findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(guideSeen, isTrue);
    expect(find.text('İndirmeyi başlat'), findsOneWidget);
    expect(find.text('Yasin Suresi · Çevrimdışı'), findsNothing);
    final downloadButton = find.widgetWithText(FilledButton, 'İndirmeyi başlat');
    await tester.ensureVisible(downloadButton);
    await tester.pumpAndSettle();
    expect(downloadButton.hitTestable(), findsOneWidget);
    await tester.tap(downloadButton);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AlertDialog, 'İndirmeyi başlat'), findsOneWidget);
    await tester.tap(find.text('İptal'));
    await tester.pumpAndSettle();
    expect(find.text('İndirilecek sayfalar: 24.1 MB'), findsOneWidget);
    expect(find.text('İndirilen: 0.0 MB · Kalan: 24.1 MB'), findsOneWidget);
  });
  testWidgets('animation switch persists and help remains accessible', (tester) async {
    final store = await ReadingStore.load();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();
    expect(store.pageAnimations, isTrue);
    await tester.tap(find.text('G\u00f6r\u00fcn\u00fcm ve okuma')); await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(store.pageAnimations, isFalse);
    final restored = await ReadingStore.load();
    expect(restored.pageAnimations, isFalse);
    await tester.tap(find.text('G\u00f6r\u00fcn\u00fcm ve okuma')); await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Yard\u0131m ve bilgi'), 200);
    await tester.tap(find.text('Yard\u0131m ve bilgi')); await tester.pumpAndSettle();
    final guideTile = find.widgetWithText(ListTile, 'Kullanım kılavuzu');
    await tester.scrollUntilVisible(guideTile, 200);
    await tester.ensureVisible(guideTile);
    await tester.pumpAndSettle();
    expect(guideTile.hitTestable(), findsOneWidget);
    await tester.tap(guideTile);
    await tester.pumpAndSettle();
    expect(find.text('Okumaya hoş geldin'), findsOneWidget);
  });

  testWidgets('first launch chooses Dutch and can switch to English', (tester) async {
    AppLanguage.instance.value = null;
    await tester.pumpWidget(const KuranApp());
    await tester.pumpAndSettle();
    expect(find.text('Nederlands'), findsOneWidget);
    await tester.tap(find.text('Nederlands'));
    await tester.pumpAndSettle();
    expect(language, 'nl');
    expect(find.text('Privacy en app-toegang'), findsOneWidget);
    await tester.tap(find.byTooltip('Taal kiezen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(language, 'en');
    expect(find.text('Privacy and app access'), findsOneWidget);
    expect((await ReadingStore.load()).language, 'en');
  });

}

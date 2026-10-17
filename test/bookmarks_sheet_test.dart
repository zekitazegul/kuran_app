import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/bookmarks_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final fail in [false, true]) {
    testWidgets('deleting a bookmark requires confirmation and handles save failure ($fail)', (tester) async {
      var writes = 0;
      var changes = 0;
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
        if (call.method == 'saveBookmarks') {
          writes++;
          if (fail) throw PlatformException(code: 'disk');
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(ReadingStore.channel, null));
      final store = ReadingStore(directory: '/test', lastPage: 1,
        informationSeen: true, bookmarks: {10}, downloaded: {});
      final date = DateTime(2026, 10, 17);
      store.bookmarkDates[10] = date;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
        body: TextButton(onPressed: () => showBookmarksSheet(context, store,
          onChanged: () => changes++), child: const Text('Open')),
      ))));
      await tester.tap(find.text('Open')); await tester.pumpAndSettle();
      final remove = find.byKey(const ValueKey('delete-bookmark-10'));
      await tester.tap(remove); await tester.pumpAndSettle();
      expect(find.text('Sayfa 10 için eklediğin ayraç silinsin mi?'), findsOneWidget);
      expect(writes, 0);
      await tester.tap(find.text('Vazgeç')); await tester.pumpAndSettle();
      expect(store.bookmarks, {10});
      expect(store.bookmarkDates[10], date);
      expect(writes, 0);
      await tester.tap(remove); await tester.pumpAndSettle();
      await tester.tap(find.text('Sil')); await tester.pumpAndSettle();
      expect(writes, 1);
      expect(find.byKey(const ValueKey('bookmarks-sheet')), findsOneWidget);
      if (fail) {
        expect(store.bookmarks, {10});
        expect(store.bookmarkDates[10], date);
        expect(remove, findsOneWidget);
        expect(find.text('Ayraç silinemedi. Tekrar dene.'), findsOneWidget);
        expect(changes, 0);
      } else {
        expect(store.bookmarks, isEmpty);
        expect(store.bookmarkDates, isEmpty);
        expect(remove, findsNothing);
        expect(find.textContaining('Henüz ayraç yok.'), findsOneWidget);
        expect(changes, 1);
      }
      expect(tester.takeException(), isNull);
    });
  }

  test('bookmark dates load, preserve legacy unknowns, and change only after a successful save', () async {
    var fail = false;
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      if (call.method == 'load') {
        return {
        'directory': '/test', 'lastPage': 1, 'bookmarks': [10, 20],
        'downloaded': <int>[], 'bookmarkDates': {'20': 1700000000000, '30': 1700000000000},
        };
      }
      if (call.method == 'saveBookmarks' && fail) throw PlatformException(code: 'disk');
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(ReadingStore.channel, null));
    final store = await ReadingStore.load();
    final original = store.bookmarkDates[20];
    expect(original!.millisecondsSinceEpoch, 1700000000000);
    expect(store.bookmarkDates.containsKey(10), isFalse);
    expect(store.bookmarkDates.containsKey(30), isFalse);
    fail = true;
    await expectLater(store.toggleBookmark(20), throwsA(isA<PlatformException>()));
    expect(store.bookmarkDates[20], original);
    expect(store.bookmarks, contains(20));
    fail = false;
    await store.toggleBookmark(30);
    expect(store.bookmarkDates[30], isNotNull);
    expect(store.bookmarkDates[20], original);
    expect(store.bookmarkDates.containsKey(10), isFalse);
    await store.toggleBookmark(20);
    expect(store.bookmarkDates.containsKey(20), isFalse);
  });

  testWidgets('bookmarks show dates and follow a downward drag before dismissing', (tester) async {
    final store = ReadingStore(directory: '/test', lastPage: 1,
      informationSeen: true, bookmarks: {10, 20}, downloaded: {});
    store.bookmarkDates[10] = DateTime(2026, 10, 17, 12, 30);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
      body: TextButton(onPressed: () => showBookmarksSheet(context, store), child: const Text('Open')),
    ))));
    await tester.tap(find.text('Open')); await tester.pumpAndSettle();
    expect(find.textContaining('Eklenme:'), findsOneWidget);
    expect(find.textContaining('2026'), findsOneWidget);
    expect(find.textContaining('Eklenme tarihi bilinmiyor'), findsOneWidget);
    final sheet = find.byKey(const ValueKey('bookmarks-sheet'));
    final original = tester.getTopLeft(sheet).dy;
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('bookmark-10'))));
    await gesture.moveBy(const Offset(0, 30)); await tester.pump();
    await gesture.moveBy(const Offset(0, 70)); await tester.pump();
    expect(tester.getTopLeft(sheet).dy, greaterThan(original + 40));
    await gesture.moveBy(const Offset(0, 300)); await gesture.up(); await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    await tester.tap(find.text('Open')); await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kapat')); await tester.pumpAndSettle();
    expect(sheet, findsNothing);
  });

  testWidgets('a long list scrolls and can still be dragged closed from its top', (tester) async {
    final store = ReadingStore(directory: '/test', lastPage: 1,
      informationSeen: true, bookmarks: Set.from(List.generate(40, (i) => i + 1)), downloaded: {});
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
      body: TextButton(onPressed: () => showBookmarksSheet(context, store), child: const Text('Open')),
    ))));
    await tester.tap(find.text('Open')); await tester.pumpAndSettle();
    final sheet = find.byKey(const ValueKey('bookmarks-sheet'));
    await tester.drag(sheet, const Offset(0, -1000)); await tester.pumpAndSettle();
    expect(sheet, findsOneWidget);
    final list = tester.widget<ListView>(sheet);
    list.controller!.jumpTo(0); await tester.pumpAndSettle();
    await tester.drag(sheet, const Offset(0, 700)); await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    expect(tester.takeException(), isNull);
  });
}

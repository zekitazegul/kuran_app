import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/data/quran_edition.dart';
import 'package:kuran_app/services/reading_history.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/screens/reading_history_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final date = DateTime(2026, 9, 19, 21, 45);
  test('history expires after 365 days, including when a new page is recorded', () {
    ReadingHistoryEntry entry(DateTime time) => ReadingHistoryEntry(session: 'old', edition: 'computer',
      surahs: [36], firstPage: 439, lastPage: 439, time: time);
    final boundary = date.subtract(const Duration(days: 365));
    final entries = [entry(boundary), entry(boundary.subtract(const Duration(milliseconds: 1)))];
    expect(ReadingHistoryEntry.recent(entries, date).length, 1);
    final updated = ReadingHistoryEntry.record(entries, QuranEdition.computer, 440, 'new', date);
    expect(updated.length, 2);
    expect(updated.every((e) => !e.time.isBefore(boundary)), isTrue);
  });

  test('clear runs after pending history saves and persists an empty list', () async {
    final store = ReadingStore(directory: '/test', lastPage: 439, informationSeen: true, bookmarks: {10}, downloaded: {});
    final writes = <List>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      writes.add((call.arguments as Map)['entries'] as List);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, null));
    await Future.wait([store.recordReading(439, 'a', time: date), store.clearReadingHistory()]);
    expect(writes.last, isEmpty);
    expect(store.history, isEmpty);
    expect(store.lastPage, 439);
    expect(store.bookmarks, {10});
  });

  testWidgets('clear history button removes history rows', (tester) async {
    final store = ReadingStore(directory: '/test', lastPage: 439, informationSeen: true, bookmarks: {}, downloaded: {});
    store.history = [ReadingHistoryEntry(session: 'a', edition: 'computer', surahs: [36], firstPage: 439, lastPage: 439, time: date)];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, (_) async => null);
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, null));
    await tester.pumpWidget(MaterialApp(home: ReadingHistoryScreen(store: store)));
    await tester.tap(find.text('Geçmişi temizle'));
    await tester.pumpAndSettle();
    expect(store.history, isEmpty);
    expect(find.text('Henüz okuma geçmişin yok. Okuduğun sayfalar burada görünecek.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  test('adjacent pages merge; jumps, sessions, editions and dates stay separate', () {
    var entries = ReadingHistoryEntry.record([], QuranEdition.computer, 439, 'a', date);
    entries = ReadingHistoryEntry.record(entries, QuranEdition.computer, 440, 'a', date.add(const Duration(seconds: 10)));
    expect(entries.length, 1);
    expect(entries.first.surahs, [36]);
    expect(entries.first.firstPage, 439);
    expect(entries.first.lastPage, 440);
    entries = ReadingHistoryEntry.record(entries, QuranEdition.computer, 442, 'a', date.add(const Duration(seconds: 20)));
    expect(entries.length, 2);
    entries = ReadingHistoryEntry.record(entries, QuranEdition.computer, 442, 'b', date.add(const Duration(seconds: 30)));
    expect(entries.length, 3);
    entries = ReadingHistoryEntry.record(entries, QuranEdition.computer, 442, 'b', date.add(const Duration(days: 1)));
    expect(entries.length, 4);
    expect(entries.first.time.day, 20);
    final restored = ReadingHistoryEntry.fromMap(entries.last.toMap());
    expect(restored.firstPage, 439);
    expect(restored.lastPage, 440);
    expect(restored.time, date.add(const Duration(seconds: 10)));
  });

  test('history writes are serialized and failed writes can be retried', () async {
    final store = ReadingStore(directory: '/test', lastPage: 439, informationSeen: true, bookmarks: {}, downloaded: {});
    var fail = true;
    final writes = <List>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      expect(call.method, 'saveReadingHistory');
      if (fail) throw StateError('disk full');
      writes.add((call.arguments as Map)['entries'] as List);
      return null;
    });
    await expectLater(store.recordReading(439, 'a', time: date), throwsA(anything));
    expect(store.history, isEmpty);
    fail = false;
    await Future.wait([store.recordReading(439, 'a', time: date),
      store.recordReading(440, 'a', time: date.add(const Duration(seconds: 5)))]);
    expect(store.history.length, 1);
    expect(store.history.first.lastPage, 440);
    expect((writes.last.first as Map)['lastPage'], 440);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, null);
  });

  test('bottom shortcuts preserve order and recover invalid saved settings', () {
    final prefs = UiPreferences.fromMap(const UiPreferences(bottomShortcuts: ['history', 'home', 'settings']).toMap());
    expect(prefs.bottomShortcuts, ['history', 'home', 'settings']);
    final repaired = UiPreferences.fromMap({'bottomShortcuts': ['unknown', 'bookmarks', 'bookmarks', 'history']});
    expect(repaired.bottomShortcuts, ['bookmarks', 'history', 'exit']);
    expect(UiPreferences.fromMap({}).bottomShortcuts, UiPreferences.defaultBottomShortcuts);
  });

  testWidgets('history row shows surah, range, time and date', (tester) async {
    final store = ReadingStore(directory: '/test', lastPage: 439, informationSeen: true, bookmarks: {}, downloaded: {});
    store.history = [ReadingHistoryEntry(session: 'a', edition: 'computer', surahs: [36], firstPage: 439, lastPage: 440, time: date)];
    await tester.pumpWidget(MaterialApp(home: ReadingHistoryScreen(store: store)));
    expect(find.text('Yasin 439 – 440'), findsOneWidget);
    expect(find.text('21.45  19.09.26'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/meal_reader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var preferences = <String, dynamic>{};
  setUp(() {
    preferences = {'page': 42, 'zoom': 100};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MealReader.channel, (call) async {
      if (call.method == 'save') preferences = Map<String, dynamic>.from(call.arguments as Map);
      if (call.method == 'render') return Uint8List.fromList([1, 2, 3]);
      return preferences;
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MealReader.channel, null));
  test('surah progress follows page turns, shared starts and final surah', () async {
    final reader = MealReader();
    await reader.load(initialSurah: 11);
    expect(reader.surahPageCount, 31);
    expect(reader.pageInSurah, 1);
    await reader.save(page: 515);
    expect(reader.pageInSurah, 2);
    await reader.save(page: 544);
    expect(reader.pageInSurah, 31);
    await reader.save(page: 545);
    expect(reader.surah, 12);
    expect(reader.pageInSurah, 1);
    await reader.load(initialSurah: 107);
    expect(reader.surahPageCount, greaterThanOrEqualTo(1));
    expect(reader.pageInSurah, 1);
    await reader.load(initialSurah: 114);
    expect(reader.surahPageCount, 1);
    expect(reader.pageInSurah, 1);
    await reader.save(page: 1381);
    expect(reader.hasSurahProgress, isFalse);
  });
  test('PDF has all 114 surahs in order and selecting a surah opens its actual page', () async {
    final reader = MealReader(); await reader.load(initialSurah: 2);
    expect(reader.surahPages.length, 114);
    expect(reader.pageCount, 1490);
    expect(reader.page, 50);
    expect(reader.surah, 2);
    for (var i = 1; i < 114; i++) {
      expect(reader.surahPages[i], greaterThanOrEqualTo(reader.surahPages[i - 1]));
    }
    expect(reader.surahPages.first, 42);
    expect(reader.surahPages.last, 1375);
    await reader.load(initialSurah: 2, initialVerse: 270);
    expect(reader.page, 166);
    await reader.load(initialSurah: 107);
    expect(reader.surah, 107);
    expect(reader.page, 1365);
    expect(() => reader.save(page: 1491), throwsArgumentError);
    expect(await reader.render(), [1, 2, 3]);
  });
  test('PDF position and zoom survive reopening; surah selection overrides position', () async {
    final reader = MealReader(); await reader.load();
    await reader.save(page: 500, zoom: 175);
    final restored = MealReader(); await restored.load();
    expect(restored.page, 500); expect(restored.zoom, 175);
    await restored.load(initialSurah: 1);
    expect(restored.page, 42); expect(restored.zoom, 175);
    await restored.save(zoom: 999); expect(restored.zoom, 300);
    await restored.save(page: restored.surahPages.first);
    expect(restored.surah, 1);
  });
}

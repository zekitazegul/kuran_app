import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/data/quran_edition.dart';
import 'package:kuran_app/services/reading_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each edition has an independent complete index and valid crop bounds', () async {
    final entries = jsonDecode(await File('assets/editions.json').readAsString()) as List;
    expect(entries.length, 3);
    expect(entries.map((e) => (e as Map)['directory']).toSet().length, entries.length);
    expect(entries.map((e) => (e as Map)['preferences']).toSet().length, entries.length);
    for (final entry in entries) {
      final edition = QuranEdition.fromMap(entry as Map);
      expect(edition.surahIndex.length, 114);
      expect(edition.downloadBytes, entry['bytes']);
      expect(edition.downloadBytes, greaterThan(0));
      for (var page = edition.firstPage; page <= edition.lastPage; page++) {
        expect(edition.surahsOnPage(page), isNotEmpty, reason: '${edition.id}: $page');
        final crop = edition.normalizedCrop(page);
        expect(crop.left, greaterThanOrEqualTo(0));
        expect(crop.top, greaterThanOrEqualTo(0));
        expect(crop.right, lessThanOrEqualTo(1));
        expect(crop.bottom, lessThanOrEqualTo(1));
        expect(crop.width, greaterThan(0));
        expect(crop.height, greaterThan(0));
      }
    }
  });

  test('Husrev uses its own PDF offset and variable page dimensions', () async {
    final entries = jsonDecode(await File('assets/editions.json').readAsString()) as List;
    final data = entries.firstWhere((entry) => (entry as Map)['id'] == 'husrev') as Map;
    final edition = QuranEdition.fromMap(data);
    expect(data['pdfOffset'], 0);
    expect(data['pdfPages'], 605);
    expect(edition.pageSizes.length, 605);
    expect(edition.pageCrops.length, 605);
    expect(edition.pageSize(0).height, isNot(edition.pageSize(439).height));
    expect(edition.yasinPage, 439);
  });

  test('switching editions preserves downloads, bookmarks and last page independently', () async {
    final entries = jsonDecode(await File('assets/editions.json').readAsString()) as List;
    var selected = 'computer';
    final pages = {'computer': 439, 'hat2': 0, 'husrev': 0};
    final bookmarks = <String, List<int>>{'computer': [439], 'hat2': [], 'husrev': []};
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      final args = call.arguments as Map? ?? {};
      final id = args['edition'] as String? ?? selected;
      switch (call.method) {
        case 'selectEdition': selected = args['id'] as String; return null;
        case 'load': return {
          'edition': entries.firstWhere((e) => (e as Map)['id'] == selected),
          'editions': entries, 'directory': '/test/$selected', 'lastPage': pages[selected],
          'bookmarks': bookmarks[selected], 'downloaded': selected == 'computer'
            ? List<int>.generate(605, (i) => i) : <int>[],
          'informationSeen': true, 'guideSeen': true, 'pageAnimations': false,
        };
        case 'savePage': pages[id] = args['page'] as int; return null;
        case 'saveBookmarks': bookmarks[id] = List<int>.from(args['pages'] as List); return null;
        default: throw PlatformException(code: 'UNEXPECTED_METHOD');
      }
    });
    try {
      final store = await ReadingStore.load();
      expect(store.ready, isTrue);
      await store.toggleBookmark(440);
      await store.selectEdition('hat2');
      expect(store.edition.id, 'hat2');
      expect(store.ready, isFalse);
      expect(store.bookmarks, isEmpty);
      await store.savePage(12);
      await store.toggleBookmark(12);
      await store.selectEdition('computer');
      expect(store.lastPage, 439);
      expect(store.bookmarks, {439, 440});
      expect(store.ready, isTrue);
      expect(store.guideSeen, isTrue);
      expect(store.pageAnimations, isFalse);
      await store.selectEdition('hat2');
      expect(store.lastPage, 12);
      expect(store.bookmarks, {12});
      await store.selectEdition('husrev');
      expect(store.edition.id, 'husrev');
      expect(store.lastPage, 0);
      expect(store.bookmarks, isEmpty);
      await store.savePage(439);
      await store.toggleBookmark(439);
      await store.selectEdition('computer');
      expect(store.lastPage, 439);
      expect(store.bookmarks, {439, 440});
      await store.selectEdition('husrev');
      expect(store.lastPage, 439);
      expect(store.bookmarks, {439});
    } finally {
      messenger.setMockMethodCallHandler(ReadingStore.channel, null);
    }
  });
}

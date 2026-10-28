import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/verse_regions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Raw verse lookup matches all page references in every edition',
    () async {
      final regions = await VerseRegions.load();
      final data = jsonDecode(
        File('assets/verse_regions.json').readAsStringSync(),
      ) as Map;
      for (final edition in data.keys.cast<String>()) {
        final pages = data[edition] as List;
        final firstPages = <String, int>{};
        for (var page = 0; page < pages.length; page++) {
          for (final entry in pages[page] as List) {
            firstPages.putIfAbsent('${entry[0]}:${entry[1]}', () => page);
          }
        }
        for (final entry in firstPages.entries) {
          final reference = entry.key.split(':').map(int.parse).toList();
          expect(
            regions.pageForVerse(
              edition,
              reference[0],
              reference[1],
              firstPage: 0,
              lastPage: pages.length - 1,
            ),
            entry.value,
          );
        }
        expect(
          regions.pageForVerse(
            edition,
            999,
            999,
            firstPage: 0,
            lastPage: pages.length - 1,
          ),
          isNull,
        );
        expect(
          regions.pageForVerse(
            edition,
            1,
            1,
            firstPage: pages.length,
            lastPage: pages.length + 1,
          ),
          isNull,
        );
      }
      expect(
        regions.pageForVerse('unknown', 1, 1, firstPage: 0, lastPage: 604),
        isNull,
      );
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/data/surahs.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'package:kuran_app/widgets/reader_tap_region.dart';

void main() {
  test('all UI entries have English and Dutch translations', () {
    for (final entry in translations.entries) {
      expect(entry.value['en'], isNotEmpty, reason: entry.key);
      expect(entry.value['nl'], isNotEmpty, reason: entry.key);
    }
    expect(translate('Ayarlar', 'en'), 'Settings');
    expect(translate('Ayarlar', 'nl'), 'Instellingen');
    expect(translate('Sayfa {page}', 'nl', {'page': 439}), 'Pagina 439');
  });

  test('surah search ignores accents, spaces, hyphens and apostrophes', () {
    final imran = surahs[2];
    for (final query in ['Ali imran', 'Al-i imran', 'Âl-i İmrân', "Ali 'Imran", '3']) {
      expect(matchesSurah(imran, query), isTrue, reason: query);
    }
    expect(matchesSurah(surahs[1], 'Bakara'), isTrue);
    expect(matchesSurah(surahs[1], 'Al-Baqarah'), isTrue);
    expect(matchesSurah(surahs[35], 'Yasin'), isTrue);
    expect(matchesSurah(surahs[35], 'Ya-Sin'), isTrue);
    expect(matchesSurah(imran, 'Bakara'), isFalse);
    expect(internationalSurahNames.length, 114);
    expect(surahName(surahs[1], 'en'), 'Al-Baqarah');
    expect(surahName(surahs[1], 'nl'), 'Al-Baqarah');
    expect(surahName(surahs[1], 'tr'), 'Bakara');
  });

  test('only centimeter edge strips turn pages; the broad center toggles fullscreen', () {
    expect(readerTapRegion(20, 400, 63), ReaderTapRegion.nextPage);
    expect(readerTapRegion(380, 400, 63), ReaderTapRegion.previousPage);
    for (final x in [63.0, 90.0, 200.0, 310.0, 337.0]) {
      expect(readerTapRegion(x, 400, 63), ReaderTapRegion.fullscreen);
    }
    expect(readerTapRegion(50, 150, 63), ReaderTapRegion.fullscreen);
    expect(readerTapRegion(120, 800, 63), ReaderTapRegion.fullscreen);
  });
}

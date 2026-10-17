import 'dart:convert';
import 'package:flutter/services.dart';

class MealReader {
  static const channel = MethodChannel('com.zekitazegul.kuranapp/meal-pdf');
  List<int> surahPages = [];
  Map<String, int> versePages = {};
  int pageCount = 0;
  int page = 42;
  int zoom = 100;
  int? selectedSurah;
  int surahsEndPage = 1375;
  int get surahPageCount {
    if (surahPages.isEmpty) return 0;
    final start = surahPages[surah - 1];
    final end = surah < 114 ? surahPages[surah] - 1 : surahsEndPage;
    return (end - start + 1).clamp(1, pageCount);
  }
  int get pageInSurah => surahPages.isEmpty ? 0
      : (page - surahPages[surah - 1] + 1).clamp(1, surahPageCount);
  bool get hasSurahProgress => surahPages.isNotEmpty && page >= surahPages.first && page <= surahsEndPage;
  int get surah {
    if (selectedSurah != null && page == surahPages[selectedSurah! - 1]) return selectedSurah!;
    for (var i = surahPages.length - 1; i >= 0; i--) {
      if (page >= surahPages[i]) return i + 1;
    }
    return 1;
  }
  Future<void> load({int? initialSurah, int? initialVerse}) async {
    final data = jsonDecode(await rootBundle.loadString('assets/meal/index.json')) as Map;
    pageCount = data['pageCount'] as int;
    surahPages = (data['surahs'] as List).map((s) => s['page'] as int).toList();
    versePages = Map<String, int>.from(data['versePages'] as Map? ?? {});
    if (surahPages.length != 114 || surahPages.any((p) => p < 1 || p > pageCount)) {
      throw StateError('Incomplete PDF index');
    }
    final preferences = await channel.invokeMapMethod<String, dynamic>('load');
    page = initialSurah != null ? surahPages[initialSurah.clamp(1, 114) - 1]
      : (preferences?['page'] as int? ?? surahPages.first).clamp(1, pageCount);
    if (initialSurah != null && initialVerse != null) {
      for (var verse = initialVerse; verse >= 1; verse--) {
        final found = versePages['$initialSurah:$verse'];
        if (found != null) { page = found; break; }
      }
    }
    zoom = (preferences?['zoom'] as int? ?? 100).clamp(100, 300);
    selectedSurah = initialSurah?.clamp(1, 114);
  }
  Future<Uint8List> render() async {
    final bytes = await channel.invokeMethod<Uint8List>('render', {'page': page, 'width': 1800});
    if (bytes == null) throw StateError('PDF page unavailable');
    return bytes;
  }
  Future<void> save({int? page, int? zoom, int? surah}) async {
    final nextPage = page ?? this.page;
    if (nextPage < 1 || nextPage > pageCount) throw ArgumentError('Invalid PDF page');
    final nextZoom = (zoom ?? this.zoom).clamp(100, 300);
    await channel.invokeMethod<void>('save', {'page': nextPage, 'zoom': nextZoom});
    this.page = nextPage;
    this.zoom = nextZoom;
    if (page != null) selectedSurah = surah;
  }
}

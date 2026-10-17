import 'package:flutter/material.dart';
import 'surahs.dart';

class QuranEdition {
  final int downloadBytes;
  final String id;
  final String name;
  final String description;
  final int firstPage;
  final int lastPage;
  final Size pdfSize;
  final Rect cropOdd;
  final Rect cropEven;
  final Rect cropFirst;
  final Rect cropSecond;
  final List<Surah> surahIndex;
  final List<Size> pageSizes;
  final List<Rect> pageCrops;
  final List<Rect> outerCrops;

  const QuranEdition({required this.id, required this.name, required this.description,
    required this.firstPage, required this.lastPage, required this.pdfSize,
    required this.cropOdd, required this.cropEven, required this.cropFirst,
    required this.cropSecond, required this.surahIndex,
    this.downloadBytes = 24129254, this.pageSizes = const [], this.pageCrops = const [], this.outerCrops = const []});

  static const computer = QuranEdition(id: 'computer', name: 'Süleyman Feyzullahoğlu Hattı',
    description: 'Diyanet · Süleyman Feyzullahoğlu', firstPage: 0, lastPage: 604,
    pdfSize: Size(538.583, 779.528),
    cropOdd: Rect.fromLTRB(78.5, 63.8, 461, 715), cropEven: Rect.fromLTRB(78.5, 63.8, 461, 715),
    cropFirst: Rect.fromLTRB(132.5, 264.3, 305.4, 513.8),
    cropSecond: Rect.fromLTRB(232.4, 266, 405.4, 513.6), surahIndex: surahs);

  factory QuranEdition.fromMap(Map<dynamic, dynamic> data) {
    Rect rect(String name) {
      final values = List<num>.from(data[name] as List);
      return Rect.fromLTRB(values[0].toDouble(), values[1].toDouble(),
        values[2].toDouble(), values[3].toDouble());
    }
    return QuranEdition(downloadBytes: (data['bytes'] as num).toInt(), id: data['id'] as String, name: data['name'] as String,
      description: data['description'] as String, firstPage: data['firstPage'] as int,
      lastPage: data['lastPage'] as int,
      pdfSize: Size((data['pdfWidth'] as num).toDouble(), (data['pdfHeight'] as num).toDouble()),
      cropOdd: rect('cropOdd'), cropEven: rect('cropEven'), cropFirst: rect('cropFirst'), cropSecond: rect('cropSecond'),
      pageSizes: ((data['pageSizes'] as List?) ?? const []).map((entry) {
        final row = List<num>.from(entry as List);
        return Size(row[0].toDouble(), row[1].toDouble());
      }).toList(),
      outerCrops: ((data['outerCrops'] as List?) ?? const []).map((entry) {
        final row = List<num>.from(entry as List);
        return Rect.fromLTRB(row[0].toDouble(), row[1].toDouble(), row[2].toDouble(), row[3].toDouble());
      }).toList(),
      pageCrops: ((data['pageCrops'] as List?) ?? const []).map((entry) {
        final row = List<num>.from(entry as List);
        return Rect.fromLTRB(row[0].toDouble(), row[1].toDouble(), row[2].toDouble(), row[3].toDouble());
      }).toList(),
      surahIndex: (data['surahs'] as List).map((entry) {
        final row = List<int>.from(entry as List);
        return Surah(row[0], surahs[row[0] - 1].name, row[1], row[2]);
      }).toList());
  }

  int get pageCount => lastPage - firstPage + 1;
  int get yasinPage => surahIndex[35].startPage;
  Size pageSize(int page) {
    final index = page - firstPage;
    return index >= 0 && index < pageSizes.length ? pageSizes[index] : pdfSize;
  }
  Rect crop(int page) {
    final index = page - firstPage;
    if (index >= 0 && index < pageCrops.length) return pageCrops[index];
    return page == firstPage ? cropFirst : page == firstPage + 1
      ? cropSecond : page.isOdd ? cropOdd : cropEven;
  }
  Rect outerCrop(int page) {
    final index = page - firstPage;
    if (index >= 0 && index < outerCrops.length) return outerCrops[index];
    final size = pageSize(page);
    return crop(page).inflate(17).intersect(Offset.zero & size);
  }
  Rect normalizedOuterCrop(int page) {
    final r = outerCrop(page);
    final size = pageSize(page);
    return Rect.fromLTRB(r.left / size.width, r.top / size.height,
      r.right / size.width, r.bottom / size.height);
  }
  Rect normalizedCrop(int page) {
    final r = crop(page);
    final size = pageSize(page);
    return Rect.fromLTRB(r.left / size.width, r.top / size.height,
      r.right / size.width, r.bottom / size.height);
  }
  List<Surah> surahsOnPage(int page) => surahIndex.where((s) => s.startPage <= page && page <= s.endPage).toList();
}

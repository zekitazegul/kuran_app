import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerseRegion {
  final int surah;
  final int verse;
  final List<Rect> boxes;
  const VerseRegion(this.surah, this.verse, this.boxes);
}

class VerseRegions {
  static VerseRegions? _cached;
  static Future<VerseRegions>? _loading;
  final Map<String, dynamic> _data;
  VerseRegions._(this._data);
  static Future<VerseRegions> load() {
    if (_cached != null) return Future.value(_cached!);
    return _loading ??= rootBundle
        .loadString('assets/verse_regions.json', cache: false)
        .then((text) => compute(_decodeRegions, text))
        .then((data) => _cached = VerseRegions._(data))
        .whenComplete(() => _loading = null);
  }

  // Search raw references without allocating drawing boxes for every page.
  int? pageForVerse(
    String edition,
    int surah,
    int verse, {
    required int firstPage,
    required int lastPage,
  }) {
    final pages = _data[edition] as List?;
    if (pages == null) return null;
    for (
      var page = firstPage;
      page <= lastPage && page < pages.length;
      page++
    ) {
      if (page < 0) continue;
      for (final entry in pages[page] as List) {
        if (entry[0] == surah && entry[1] == verse) return page;
      }
    }
    return null;
  }

  List<VerseRegion> page(String edition, int page) =>
      ((_data[edition] as List)[page] as List)
          .map(
            (entry) => VerseRegion(
              entry[0] as int,
              entry[1] as int,
              (entry[2] as List)
                  .map(
                    (b) => Rect.fromLTRB(
                      (b[0] as num).toDouble(),
                      (b[1] as num).toDouble(),
                      (b[2] as num).toDouble(),
                      (b[3] as num).toDouble(),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
}

Map<String, dynamic> _decodeRegions(String text) =>
    jsonDecode(text) as Map<String, dynamic>;

/// Same contain transform as ReadingPage, including full-screen cropping.
Rect verseDisplayRect(Rect normalized, Size size, Size imageSize, Rect? crop) {
  final source = crop == null
      ? Offset.zero & imageSize
      : Rect.fromLTRB(
          crop.left * imageSize.width,
          crop.top * imageSize.height,
          crop.right * imageSize.width,
          crop.bottom * imageSize.height,
        );
  final fitted = applyBoxFit(BoxFit.contain, source.size, size);
  final destination = Alignment.center.inscribe(
    fitted.destination,
    Offset.zero & size,
  );
  return Rect.fromLTRB(
    destination.left +
        (normalized.left * imageSize.width - source.left) /
            source.width *
            destination.width,
    destination.top +
        (normalized.top * imageSize.height - source.top) /
            source.height *
            destination.height,
    destination.left +
        (normalized.right * imageSize.width - source.left) /
            source.width *
            destination.width,
    destination.top +
        (normalized.bottom * imageSize.height - source.top) /
            source.height *
            destination.height,
  );
}

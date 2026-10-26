import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Shares pending reads and retains only the decoded content, not the JSON text.
class MealContent {
  static Future<List<List<String>>>? _pages;
  static Future<Map<String, String>>? _verses;

  static Future<List<List<String>>> pages() => _pages ??= _loadPages();

  static Future<List<List<String>>> _loadPages() async {
    try {
      final text = await rootBundle.loadString('assets/meal/turkish-pages.json', cache: false);
      return await compute(_decodePages, text);
    } catch (_) {
      _pages = null;
      rethrow;
    }
  }

  static Future<Map<String, String>> verses() => _verses ??= _loadVerses();

  static Future<Map<String, String>> _loadVerses() async {
    try {
      final text = await rootBundle.loadString('assets/meal/translation.json', cache: false);
      return await compute(_decodeVerses, text);
    } catch (_) {
      _verses = null;
      rethrow;
    }
  }
}

List<List<String>> _decodePages(String text) => (jsonDecode(text) as List)
    .map((page) => List<String>.unmodifiable(page as List)).toList(growable: false);

Map<String, String> _decodeVerses(String text) => Map.unmodifiable({
  for (final verse in jsonDecode(text)['verses'] as List)
    '${verse['surah']}:${verse['verse']}': verse['text'] as String,
});

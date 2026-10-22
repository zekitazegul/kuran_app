import 'app_preferences.dart';
import 'reading_history.dart';

import 'package:flutter/services.dart';

import '../data/quran_edition.dart';

class ReadingStore {
  static const channel = MethodChannel('com.zekitazegul.kuranapp/reading');
  static const pageCount = 605;
  static const lastNumberedPage = 604;
  final Set<int> bookmarks;
  final Map<int, DateTime> bookmarkDates = {};
  final Set<int> downloaded;
  final Set<String> downloadedEditions;
  String directory;
  QuranEdition edition;
  List<QuranEdition> editions;
  int downloadedBytes;
  int lastPage;
  bool informationSeen;
  bool guideSeen;
  String? appVersion;
  String? seenUpdateVersion;
  bool pageAnimations;
  bool keepScreenOn;
  String pageEffect;
  final String? language;
  final double edgeTapWidth;
  List<ReadingHistoryEntry> history = [];
  Future<void>? _historyWrite;

  Future<void> clearReadingHistory() {
    final operation = (_historyWrite ?? Future<void>.value()).then((_) async {
      await channel.invokeMethod<void>('saveReadingHistory', {
        'entries': <Map<String, Object>>[],
      });
      history = [];
    });
    _historyWrite = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> recordReading(int page, String session, {DateTime? time}) {
    final selectedEdition = edition;
    final recordedAt = time ?? DateTime.now();
    final operation = (_historyWrite ?? Future<void>.value()).then((_) async {
      final updated = ReadingHistoryEntry.record(
        history,
        selectedEdition,
        page,
        session,
        recordedAt,
      );
      await channel.invokeMethod<void>('saveReadingHistory', {
        'entries': updated.map((e) => e.toMap()).toList(),
      });
      history = updated;
    });
    _historyWrite = operation.catchError((Object _) {});
    return operation;
  }

  ReadingStore({
    required this.directory,
    required this.lastPage,
    required this.informationSeen,
    required this.bookmarks,
    required this.downloaded,
    Set<String>? downloadedEditions,
    this.downloadedBytes = 0,
    this.guideSeen = false,
    this.pageAnimations = true,
    this.pageEffect = 'slide',
    this.keepScreenOn = true,
    this.language,
    this.edgeTapWidth = 160 / 2.54,
    this.edition = QuranEdition.computer,
    this.editions = const [QuranEdition.computer],
  }) : downloadedEditions = downloadedEditions ?? <String>{};

  final Set<int> hatimPages = {};
  int? hatimResume;
  bool get hatimComplete => hatimPages.length == edition.pageCount;
  int? nextHatimPage([int? after]) {
    for (var offset = 1; offset <= edition.pageCount; offset++) {
      final page =
          edition.firstPage +
          ((after ?? (hatimResume ?? edition.firstPage) - 1) -
                  edition.firstPage +
                  offset) %
              edition.pageCount;
      if (!hatimPages.contains(page)) return page;
    }
    return null;
  }

  Future<void> saveHatim(
    Iterable<int> pages, {
    bool read = true,
    int? resume,
  }) async {
    final updated = {...hatimPages};
    for (final page in pages) {
      if (page < edition.firstPage || page > edition.lastPage) continue;
      if (read) {
        updated.add(page);
      } else {
        updated.remove(page);
      }
    }
    await channel.invokeMethod<void>('saveHatim', {
      'edition': edition.id,
      'pages': updated.toList()..sort(),
      'resume': resume ?? hatimResume ?? edition.firstPage,
    });
    hatimPages
      ..clear()
      ..addAll(updated);
    hatimResume = resume ?? hatimResume;
  }

  bool get ready => downloaded.length == edition.pageCount;
  String pagePath(int page) =>
      '$directory/page${page.toString().padLeft(3, '0')}.png';

  static Future<ReadingStore> load() async {
    final data = await channel.invokeMapMethod<String, dynamic>('load');
    if (data == null) throw StateError('Okuma kayıtları yüklenemedi.');
    AppPreferences.instance.restore(data['uiPreferences'] as Map?);
    final edition = data['edition'] is Map
        ? QuranEdition.fromMap(data['edition'] as Map)
        : QuranEdition.computer;
    final store = ReadingStore(
      downloadedEditions: data['downloadedEditions'] is List
          ? Set<String>.from(data['downloadedEditions'] as List)
          : ((data['downloadedBytes'] as num? ?? 0) > 0 ||
                (data['downloaded'] as List).isNotEmpty)
          ? {edition.id}
          : <String>{},
      edition: edition,
      editions: data['editions'] is List
          ? (data['editions'] as List)
                .map((e) => QuranEdition.fromMap(e as Map))
                .toList()
          : [QuranEdition.computer],
      downloadedBytes: (data['downloadedBytes'] as num?)?.toInt() ?? 0,
      directory: data['directory'] as String,
      lastPage: (data['lastPage'] as int)
          .clamp(edition.firstPage, edition.lastPage)
          .toInt(),
      informationSeen: data['informationSeen'] == true,
      guideSeen: data['guideSeen'] == true,
      language: data['language'] as String?,
      edgeTapWidth: ((data['edgeTapWidth'] as num?)?.toDouble() ?? 160 / 2.54)
          .clamp(32.0, 96.0)
          .toDouble(),
      pageAnimations: data['pageAnimations'] != false,
      keepScreenOn: data['keepScreenOn'] != false,
      pageEffect: data['pageEffect'] == 'curl' ? 'curl' : 'slide',
      bookmarks: Set<int>.from(data['bookmarks'] as List)
          .where((p) => p >= edition.firstPage && p <= edition.lastPage)
          .toSet(),
      downloaded: Set<int>.from(data['downloaded'] as List),
    );
    final dates = data['bookmarkDates'];
    if (dates is Map) {
      for (final entry in dates.entries) {
        final page = int.tryParse(entry.key.toString());
        final time = entry.value;
        if (page != null &&
            store.bookmarks.contains(page) &&
            time is num &&
            time > 0) {
          store.bookmarkDates[page] = DateTime.fromMillisecondsSinceEpoch(
            time.toInt(),
          );
        }
      }
    }
    store.appVersion = data['appVersion'] as String?;
    store.seenUpdateVersion = data['seenUpdateVersion'] as String?;
    store.hatimPages.addAll(
      ((data['hatimPages'] as List?) ?? []).cast<int>().where(
        (p) => p >= edition.firstPage && p <= edition.lastPage,
      ),
    );
    store.hatimResume = (data['hatimResume'] as int?)?.clamp(
      edition.firstPage,
      edition.lastPage,
    );
    store.history =
        ((data['readingHistory'] as List?) ?? [])
            .map((e) => ReadingHistoryEntry.fromMap(e as Map))
            .toList()
          ..sort((a, b) => b.time.compareTo(a.time));
    final recent = ReadingHistoryEntry.recent(store.history, DateTime.now());
    if (recent.length != store.history.length) {
      await channel.invokeMethod<void>('saveReadingHistory', {
        'entries': recent.map((e) => e.toMap()).toList(),
      });
      store.history = recent;
    }
    return store;
  }

  Future<void> savePage(int page) async {
    final id = edition.id;
    await channel.invokeMethod<void>('savePage', {'edition': id, 'page': page});
    if (edition.id == id) lastPage = page;
  }

  Future<void> toggleBookmark(int page) async {
    final updated = {...bookmarks};
    if (!updated.remove(page)) updated.add(page);
    final id = edition.id;
    await channel.invokeMethod<void>('saveBookmarks', {
      'edition': id,
      'pages': updated.toList()..sort(),
    });
    if (edition.id == id) {
      if (updated.contains(page)) {
        bookmarkDates[page] = DateTime.now();
      } else {
        bookmarkDates.remove(page);
      }
      bookmarks
        ..clear()
        ..addAll(updated);
    }
  }

  Future<void> acknowledgeInformation() async {
    await channel.invokeMethod<void>('acknowledge');
    informationSeen = true;
  }

  Future<void> acknowledgeGuide() async {
    await channel.invokeMethod<void>('acknowledgeGuide');
    guideSeen = true;
  }

  Future<void> setKeepScreenOn(bool enabled) async {
    await channel.invokeMethod<void>('setKeepScreenOn', {'enabled': enabled});
    keepScreenOn = enabled;
  }

  Future<void> setPageEffect(String effect) async {
    if (effect != 'curl' && effect != 'slide') {
      throw ArgumentError.value(effect);
    }
    await channel.invokeMethod<void>('setPageEffect', {'effect': effect});
    pageEffect = effect;
  }

  Future<void> setPageAnimations(bool enabled) async {
    await channel.invokeMethod<void>('setPageAnimations', {'enabled': enabled});
    pageAnimations = enabled;
  }

  Future<void> selectEdition(String id) async {
    if (id == edition.id) return;
    await channel.invokeMethod<dynamic>('selectEdition', {'id': id});
    final selected = await ReadingStore.load();
    hatimPages
      ..clear()
      ..addAll(selected.hatimPages);
    hatimResume = selected.hatimResume;
    edition = selected.edition;
    editions = selected.editions;
    directory = selected.directory;
    lastPage = selected.lastPage;
    downloadedBytes = selected.downloadedBytes;
    downloadedEditions
      ..clear()
      ..addAll(selected.downloadedEditions);
    bookmarks
      ..clear()
      ..addAll(selected.bookmarks);
    bookmarkDates
      ..clear()
      ..addAll(selected.bookmarkDates);
    downloaded
      ..clear()
      ..addAll(selected.downloaded);
  }

  bool get sourceDownloaded => downloadedBytes >= edition.downloadBytes;

  Future<bool> restoreDownloadedEdition() async {
    final id = await channel.invokeMethod<String>('findDownloadedEdition');
    if (id == null) return false;
    await selectEdition(id);
    return ready;
  }

  Future<void> removeDownload({String? editionId}) async {
    final id = editionId ?? edition.id;
    await channel.invokeMethod<void>('removeDownload', {'edition': id});
    downloadedEditions.remove(id);
    if (id == edition.id) {
      downloaded.clear();
      downloadedBytes = 0;
    }
  }

  Future<void> downloadPage(int page) async {
    await channel.invokeMethod<void>('downloadPage', {
      'edition': edition.id,
      'page': page,
    });
    downloadedBytes = edition.downloadBytes;
    downloadedEditions.add(edition.id);
    downloaded.add(page);
  }
}

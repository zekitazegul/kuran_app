import 'package:flutter/services.dart';
import '../data/quran_edition.dart';

class ReadingStore {
  static const channel = MethodChannel('com.zekitazegul.kuranapp/reading');
  static const pageCount = 605;
  static const lastNumberedPage = 604;
  final Set<int> bookmarks;
  final Set<int> downloaded;
  String directory;
  QuranEdition edition;
  List<QuranEdition> editions;
  int lastPage;
  bool informationSeen;
  bool guideSeen;
  bool pageAnimations;

  ReadingStore({required this.directory, required this.lastPage,
    required this.informationSeen, required this.bookmarks, required this.downloaded,
    this.guideSeen = false, this.pageAnimations = true,
    this.edition = QuranEdition.computer, this.editions = const [QuranEdition.computer]});

  bool get ready => downloaded.length == edition.pageCount;
  String pagePath(int page) => '$directory/page${page.toString().padLeft(3, '0')}.png';

  static Future<ReadingStore> load() async {
    final data = await channel.invokeMapMethod<String, dynamic>('load');
    if (data == null) throw StateError('Okuma kayıtları yüklenemedi.');
    final edition = data['edition'] is Map ? QuranEdition.fromMap(data['edition'] as Map) : QuranEdition.computer;
    return ReadingStore(
      edition: edition,
      editions: data['editions'] is List ? (data['editions'] as List).map((e) => QuranEdition.fromMap(e as Map)).toList() : [QuranEdition.computer],
      directory: data['directory'] as String,
      lastPage: (data['lastPage'] as int).clamp(edition.firstPage, edition.lastPage).toInt(),
      informationSeen: data['informationSeen'] == true,
      guideSeen: data['guideSeen'] == true,
      pageAnimations: data['pageAnimations'] != false,
      bookmarks: Set<int>.from(data['bookmarks'] as List).where((p) => p >= edition.firstPage && p <= edition.lastPage).toSet(),
      downloaded: Set<int>.from(data['downloaded'] as List),
    );
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
    await channel.invokeMethod<void>('saveBookmarks', {'edition': id, 'pages': updated.toList()..sort()});
    if (edition.id == id) bookmarks..clear()..addAll(updated);
  }

  Future<void> acknowledgeInformation() async {
    await channel.invokeMethod<void>('acknowledge');
    informationSeen = true;
  }

  Future<void> acknowledgeGuide() async {
    await channel.invokeMethod<void>('acknowledgeGuide');
    guideSeen = true;
  }

  Future<void> setPageAnimations(bool enabled) async {
    await channel.invokeMethod<void>('setPageAnimations', {'enabled': enabled});
    pageAnimations = enabled;
  }

  Future<void> selectEdition(String id) async {
    if (id == edition.id) return;
    await channel.invokeMethod<dynamic>('selectEdition', {'id': id});
    final selected = await ReadingStore.load();
    edition = selected.edition;
    editions = selected.editions;
    directory = selected.directory;
    lastPage = selected.lastPage;
    bookmarks..clear()..addAll(selected.bookmarks);
    downloaded..clear()..addAll(selected.downloaded);
  }

  Future<void> downloadPage(int page) async {
    await channel.invokeMethod<void>('downloadPage', {'edition': edition.id, 'page': page});
    downloaded.add(page);
  }
}

import 'package:flutter/services.dart';

class ReadingStore {
  static const channel = MethodChannel('com.zekitazegul.kuranapp/reading');
  static const pageCount = 604;
  final Set<int> bookmarks;
  final Set<int> downloaded;
  final String directory;
  int lastPage;
  bool informationSeen;

  ReadingStore({required this.directory, required this.lastPage,
    required this.informationSeen, required this.bookmarks, required this.downloaded});

  bool get ready => downloaded.length == pageCount;
  String pagePath(int page) => '$directory/page${page.toString().padLeft(3, '0')}.png';

  static Future<ReadingStore> load() async {
    final data = await channel.invokeMapMethod<String, dynamic>('load');
    if (data == null) throw StateError('Okuma kayıtları yüklenemedi.');
    return ReadingStore(
      directory: data['directory'] as String,
      lastPage: (data['lastPage'] as int).clamp(1, pageCount).toInt(),
      informationSeen: data['informationSeen'] == true,
      bookmarks: Set<int>.from(data['bookmarks'] as List).where((p) => p >= 1 && p <= pageCount).toSet(),
      downloaded: Set<int>.from(data['downloaded'] as List),
    );
  }

  Future<void> savePage(int page) async {
    await channel.invokeMethod<void>('savePage', {'page': page});
    lastPage = page;
  }

  Future<void> toggleBookmark(int page) async {
    final updated = {...bookmarks};
    if (!updated.remove(page)) updated.add(page);
    await channel.invokeMethod<void>('saveBookmarks', {'pages': updated.toList()..sort()});
    bookmarks..clear()..addAll(updated);
  }

  Future<void> acknowledgeInformation() async {
    await channel.invokeMethod<void>('acknowledge');
    informationSeen = true;
  }

  Future<void> downloadPage(int page) async {
    await channel.invokeMethod<void>('downloadPage', {'page': page});
    downloaded.add(page);
  }
}

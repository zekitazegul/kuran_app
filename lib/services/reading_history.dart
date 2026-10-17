import '../data/quran_edition.dart';

class ReadingHistoryEntry {
  static List<ReadingHistoryEntry> recent(List<ReadingHistoryEntry> entries, DateTime now) {
    final cutoff = now.subtract(const Duration(days: 365));
    return entries.where((entry) => !entry.time.isBefore(cutoff)).toList();
  }
  final String session;
  final String edition;
  final List<int> surahs;
  final int firstPage;
  final int lastPage;
  final DateTime time;
  const ReadingHistoryEntry({required this.session, required this.edition,
    required this.surahs, required this.firstPage, required this.lastPage, required this.time});

  Map<String, Object> toMap() => {'session': session, 'edition': edition,
    'surahs': surahs, 'firstPage': firstPage, 'lastPage': lastPage,
    'time': time.millisecondsSinceEpoch};
  factory ReadingHistoryEntry.fromMap(Map data) => ReadingHistoryEntry(
    session: data['session'] as String, edition: data['edition'] as String,
    surahs: List<int>.from(data['surahs'] as List), firstPage: data['firstPage'] as int,
    lastPage: data['lastPage'] as int,
    time: DateTime.fromMillisecondsSinceEpoch((data['time'] as num).toInt()));

  static List<ReadingHistoryEntry> record(List<ReadingHistoryEntry> entries,
      QuranEdition edition, int page, String session, DateTime time) {
    entries = recent(entries, time);
    final onPage = edition.surahsOnPage(page);
    final starting = onPage.where((s) => s.startPage == page).toList();
    final numbers = (starting.isEmpty ? onPage : starting).map((s) => s.number).toList();
    final previous = entries.isEmpty ? null : entries.first;
    final merge = previous != null && previous.session == session &&
      previous.edition == edition.id && previous.surahs.join(',') == numbers.join(',') &&
      page >= previous.firstPage - 1 && page <= previous.lastPage + 1 &&
      time.difference(previous.time).inMinutes >= 0 && time.difference(previous.time).inMinutes < 30 &&
      previous.time.year == time.year && previous.time.month == time.month && previous.time.day == time.day;
    final entry = ReadingHistoryEntry(session: session, edition: edition.id, surahs: numbers,
      firstPage: merge && previous.firstPage < page ? previous.firstPage : page,
      lastPage: merge && previous.lastPage > page ? previous.lastPage : page, time: time);
    return [entry, ...entries.skip(merge ? 1 : 0)]..sort((a, b) => b.time.compareTo(a.time));
  }
}

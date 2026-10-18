import '../widgets/screen_title.dart';
import '../widgets/personal_page_scope.dart';
import 'package:flutter/material.dart';
import '../data/surahs.dart';
import '../l10n/translations.dart';
import '../services/reading_store.dart';
import 'quran_screen.dart';
import '../widgets/app_bottom_bar.dart';

class ReadingHistoryScreen extends StatefulWidget {
  final ReadingStore store;
  const ReadingHistoryScreen({super.key, required this.store});
  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  bool _clearing = false;
  Future<void> _clear() async {
    if (_clearing) return;
    setState(() => _clearing = true);
    try {
      await store.clearReadingHistory();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Geçmiş temizlenemedi. Tekrar dene.'))));
    } finally { if (mounted) setState(() => _clearing = false); }
  }
  ReadingStore get store => widget.store;
  String _two(int value) => value.toString().padLeft(2, '0');
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(automaticallyImplyLeading: PersonalPageScope.of(context) == null, title: PersonalPageScope.of(context) == null ? ScreenTitle(context, context.t('Okuma geçmişi')) : null, actions: [
      TextButton(onPressed: _clearing || store.history.isEmpty ? null : _clear,
        child: Text(context.t('Geçmişi temizle'))),
    ]),
    body: store.history.isEmpty ? Center(child: Padding(padding: const EdgeInsets.all(24),
      child: Text(context.t('Henüz okuma geçmişin yok. Okuduğun sayfalar burada görünecek.')))) :
      ListView.separated(padding: const EdgeInsets.all(16), itemCount: store.history.length,
        separatorBuilder: (_, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = store.history[index];
          final date = entry.time.toLocal();
          final names = entry.surahs.map((number) => number == 36 ? context.t('Yasin')
            : surahName(surahs[number - 1], context.language)).join(' · ');
          final pages = entry.firstPage == entry.lastPage ? '${entry.firstPage}'
            : '${entry.firstPage} – ${entry.lastPage}';
          return ListTile(contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            title: Wrap(alignment: WrapAlignment.spaceBetween, spacing: 12, runSpacing: 4, children: [
              Text('$names $pages'),
              Text('${_two(date.hour)}.${_two(date.minute)}  ${_two(date.day)}.${_two(date.month)}.${_two(date.year % 100)}',
                style: Theme.of(context).textTheme.bodySmall),
            ]),
            onTap: () async {
              try {
                await store.selectEdition(entry.edition);
                AppNavigation.instance.refresh();
                if (!context.mounted) return;
                if (!store.ready) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Bu hattı okumak için önce indir.'))));
                  return;
                }
                await Navigator.push(context, MaterialPageRoute<void>(builder: (_) =>
                  QuranScreen(store: store, initialPage: entry.firstPage)));
                if (mounted) setState(() {});
              } catch (_) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Okuma kaydı açılamadı.'))));
              }
            },
          );
        }),
  );
}

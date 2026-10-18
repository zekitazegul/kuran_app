import 'package:flutter/material.dart';
import '../data/surahs.dart';
import '../l10n/translations.dart';
import '../services/reading_store.dart';
import 'compact_confirmation_dialog.dart';

Future<int?> showBookmarksSheet(BuildContext context, ReadingStore store, {VoidCallback? onChanged}) =>
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .55,
        minChildSize: .2,
        maxChildSize: .85,
        snap: true,
        snapSizes: const [.55],
        shouldCloseOnMinExtent: true,
        builder: (context, controller) => BookmarksSheet(store: store, controller: controller, onChanged: onChanged),
      ),
    );

class BookmarksSheet extends StatefulWidget {
  final ReadingStore store;
  final ScrollController controller;
  final VoidCallback? onChanged;
  final bool showHeader;
  final ValueChanged<int>? onSelected;
  const BookmarksSheet({super.key, required this.store, required this.controller, this.onChanged, this.showHeader = true, this.onSelected});

  @override
  State<BookmarksSheet> createState() => _BookmarksSheetState();
}

class _BookmarksSheetState extends State<BookmarksSheet> {
  bool _removing = false;
  ReadingStore get store => widget.store;

  Future<void> _remove(int page) async {
    if (_removing) return;
    setState(() => _removing = true);
    try {
      final confirmed = await showDialog<bool>(context: context,
        builder: (context) => CompactConfirmationDialog(
          title: Text(context.t('Ayracı sil')),
          content: Text(context.t('Sayfa {page} için eklediğin ayraç silinsin mi?', {'page': page})),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t('Vazgeç'))),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.t('Sil'))),
          ],
        ));
      if (confirmed != true || !mounted || !store.bookmarks.contains(page)) return;
      await store.toggleBookmark(page);
      widget.onChanged?.call();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('Ayraç silinemedi. Tekrar dene.'))));
      }
    } finally {
      if (mounted) setState(() => _removing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = store.bookmarks.toList()..sort();
    final localizations = MaterialLocalizations.of(context);
    return SafeArea(top: false, child: ListView(
      key: const ValueKey('bookmarks-sheet'),
      controller: widget.controller,
      children: [
        if (widget.showHeader) ListTile(title: Text(context.t('Ayraçlar')),
          trailing: IconButton(tooltip: context.t('Kapat'), icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context))),
        if (pages.isEmpty) Padding(padding: const EdgeInsets.all(24),
          child: Text(context.t('Henüz ayraç yok. Okuduğunuz sayfada ayraç simgesine dokunun.'))),
        for (final page in pages) Builder(builder: (context) {
          final date = store.bookmarkDates[page]?.toLocal();
          final dateLabel = date == null ? context.t('Eklenme tarihi bilinmiyor')
            : context.t('Eklenme: {date}', {'date': '${localizations.formatShortDate(date)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}'});
          final names = store.edition.surahsOnPage(page).map((s) => surahName(s, context.language)).join(', ');
          return ListTile(key: ValueKey('bookmark-$page'),
            title: Text(context.t('Sayfa {page}', {'page': page})),
            subtitle: Text([if (names.isNotEmpty) names, dateLabel].join('\n')),
            isThreeLine: names.isNotEmpty,
            trailing: IconButton(key: ValueKey('delete-bookmark-$page'),
              tooltip: context.t('Ayracı sil'), icon: const Icon(Icons.delete_outline),
              onPressed: _removing ? null : () => _remove(page)),
            onTap: _removing ? null : () {
              if (widget.onSelected != null) { widget.onSelected!(page); } else { Navigator.pop(context, page); }
            });
        }),
      ],
    ));
  }
}

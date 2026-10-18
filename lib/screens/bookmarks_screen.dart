import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/reading_store.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/bookmarks_sheet.dart';
import '../widgets/personal_page_scope.dart';
import '../widgets/screen_title.dart';
import 'quran_screen.dart';

class BookmarksScreen extends StatefulWidget {
  final ReadingStore store;
  const BookmarksScreen({super.key, required this.store});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _scroll = ScrollController();
  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  Future<void> _open(int page) async {
    if (!widget.store.ready) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Bu hattı okumak için önce indir.'))));
      return;
    }
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => QuranScreen(store: widget.store, initialPage: page)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => PersonalPageSwipe(
    onNavigate: (delta) => AppNavigation.instance.switchPage?.call(delta),
    child: Scaffold(
      appBar: PersonalPageScope.of(context) == null ? AppBar(title: ScreenTitle(context, context.t('Ayraçlar'))) : null,
      body: BookmarksSheet(store: widget.store, controller: _scroll,
        showHeader: false, onSelected: _open, onChanged: AppNavigation.instance.refresh),
    ),
  );
}

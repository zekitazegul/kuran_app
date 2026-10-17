import 'package:flutter/material.dart';
import '../services/reading_store.dart';

class HatimSelectionScreen extends StatefulWidget {
  final ReadingStore store;
  const HatimSelectionScreen({super.key, required this.store});
  @override
  State<HatimSelectionScreen> createState() => _HatimSelectionScreenState();
}
class _HatimSelectionScreenState extends State<HatimSelectionScreen> {
  bool busy = false;
  Future<void> mark(List<int> pages, bool read) async {
    setState(() => busy = true);
    try { await widget.store.saveHatim(pages, read: read); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlerleme kaydedilemedi. Tekrar deneyin.'))); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(title: Text('Hatim · ${store.hatimPages.length}/${store.edition.pageCount}'),
        bottom: const TabBar(tabs: [Tab(text: 'Sayfalar'), Tab(text: 'Cüzler')])),
      body: TabBarView(children: [
        ListView.builder(itemCount: store.edition.pageCount, itemBuilder: (_, i) {
          final page = store.edition.firstPage + i;
          return ListTile(title: Text('Sayfa $page'),
            onTap: busy ? null : () => Navigator.pop(context, page),
            trailing: Checkbox(key: ValueKey('hatim-select-page-$page'),
              value: store.hatimPages.contains(page),
              onChanged: busy ? null : (v) => mark([page], v!)));
        }),
        ListView.builder(itemCount: 30, itemBuilder: (_, i) {
          final first = i == 0 ? store.edition.firstPage : i * 20 + 1;
          final last = i == 29 ? store.edition.lastPage : (i + 1) * 20;
          final pages = [for (var p = first; p <= last; p++) p];
          final count = pages.where(store.hatimPages.contains).length;
          return ListTile(title: Text('Cüz ${i + 1}'), subtitle: Text('$count / ${pages.length} sayfa'),
            onTap: busy ? null : () => Navigator.pop(context, first),
            trailing: Checkbox(key: ValueKey('hatim-select-juz-${i + 1}'),
              tristate: true, value: count == 0 ? false : count == pages.length ? true : null,
              onChanged: busy ? null : (_) => mark(pages, count != pages.length)));
        }),
      ])));
  }
}

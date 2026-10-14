import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/information_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/quran_screen.dart';
import 'services/reading_store.dart';

void main() => runApp(const KuranApp());

class KuranApp extends StatelessWidget {
  const KuranApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'Kuran App',
    theme: ThemeData(useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8F4EB),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF164D43),
        primary: const Color(0xFF164D43), secondary: const Color(0xFFB28A46),
        surface: const Color(0xFFFFFCF5)),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF8F4EB),
        foregroundColor: Color(0xFF163D35), centerTitle: false, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      cardTheme: CardThemeData(elevation: 0, color: const Color(0xFFFFFCF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFE8DFCC))))),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReadingStore? _store;
  String? _error;
  bool _downloading = false;
  bool _pauseRequested = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final store = await ReadingStore.load();
      if (mounted) setState(() { _store = store; _error = null; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Okuma kayıtları yüklenemedi. Bu sürüm Android içindir.');
    }
  }

  Future<void> _download() async {
    final store = _store!;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text('${store.edition.name} · Mushafı indir'),
      content: const Text('Seçili hattın PDF’si indirilecek ve sayfalar cihazınızda hazırlanacak. Hazırlanan görseller ek depolama alanı kullanır. Wi-Fi kullanmanız önerilir. İndirme sırasında uygulamayı açık tutun; duraklatıp daha sonra kaldığınız yerden sürdürebilirsiniz.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('İndirmeyi başlat'))],
    ));
    if (confirmed != true || !mounted) return;
    setState(() { _downloading = true; _pauseRequested = false; _error = null; });
    try {
      for (var page = store.edition.firstPage; page <= store.edition.lastPage; page++) {
        if (_pauseRequested || !mounted) break;
        if (store.downloaded.contains(page)) continue;
        await store.downloadPage(page);
        if (mounted) setState(() {});
      }
    } catch (error) {
      final detail = error is PlatformException ? (error.message ?? error.code) : error.toString();
      if (mounted) setState(() => _error = 'İndirme tamamlanamadı: $detail\n\nİndirilen sayfalar korunur; tekrar deneyerek devam edebilirsiniz.');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _read(int page, {String? panel}) async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => QuranScreen(store: _store!, initialPage: page, initialPanel: panel)));
    if (mounted) setState(() {});
  }

  @override
  void dispose() { _pauseRequested = true; super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    if (store != null && !store.informationSeen) {
      return InformationScreen(onContinue: () async {
        await store.acknowledgeInformation();
        if (mounted) setState(() {});
      });
    }
    if (store != null && !store.guideSeen) {
      return GuideScreen(onContinue: () async {
        await store.acknowledgeGuide();
        if (mounted) setState(() {});
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Kur’an-ı Kerim', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [IconButton(tooltip: 'Ayarlar', icon: const Icon(Icons.tune_rounded),
          onPressed: store == null || _downloading ? null : () async {
            await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SettingsScreen(store: store)));
            if (mounted) setState(() {});
          })]),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF164D43), Color(0xFF092F2A)])),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              const Positioned(top: -45, right: -45, child: _Ornament()),
              Padding(padding: const EdgeInsets.all(26), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0x22E5C383), borderRadius: BorderRadius.circular(20)),
                    child: const Text('OKUMA VAKTİ', style: TextStyle(color: Color(0xFFE5C383),
                      fontWeight: FontWeight.w600, letterSpacing: 2, fontSize: 11))),
                  const SizedBox(height: 24),
                  const Icon(Icons.auto_stories_rounded, color: Color(0xFFE5C383), size: 40),
                  const SizedBox(height: 14),
                  const Text('Her sayfada\nbir huzur.', style: TextStyle(color: Colors.white,
                    fontSize: 32, height: 1.2, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  if (store != null && store.ready) ...[
                    Text('${store.edition.surahsOnPage(store.lastPage).map((s) => s.name).join(' · ')}  /  ${store.lastPage == 0 ? 'Fatiha' : 'Sayfa ${store.lastPage}'}',
                      style: const TextStyle(color: Color(0xFFE1E9DC))),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE5C383), foregroundColor: const Color(0xFF173C32)),
                      onPressed: () => _read(store.lastPage), icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Okumaya devam et'))),
                  ] else const Text('Mushafını yanında taşı.', style: TextStyle(color: Color(0xFFE1E9DC))),
                ])),
            ])),
          const SizedBox(height: 24),
          if (store == null && _error == null) const Center(child: CircularProgressIndicator()),
          if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 16),
            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          if (store == null && _error != null) OutlinedButton(onPressed: _load, child: const Text('Tekrar dene')),
          if (store != null && store.ready) ...[
            Text('Kütüphanem', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                _QuickAction(width: width, icon: Icons.format_list_numbered_rounded,
                  title: 'Sureler', subtitle: '${store.edition.surahIndex.length} sure', onTap: () => _read(store.lastPage, panel: 'surah')),
                _QuickAction(width: width, icon: Icons.bookmarks_outlined,
                  title: 'Ayraçlarım', subtitle: '${store.bookmarks.length} kayıt', onTap: () => _read(store.lastPage, panel: 'bookmarks')),
                _QuickAction(width: width, icon: Icons.menu_book_outlined,
                  title: 'Baştan oku', subtitle: 'Fatiha Suresi', onTap: () => _read(store.edition.firstPage)),
                _QuickAction(width: width, icon: Icons.auto_stories_outlined,
                  title: 'Yasin Suresi', subtitle: 'Sayfa ${store.edition.yasinPage}', onTap: () => _read(store.edition.yasinPage)),
              ]);
            }),
            const SizedBox(height: 20),
            Card(child: ListTile(leading: const Icon(Icons.numbers_rounded), title: const Text('Sayfaya git'),
              trailing: const Icon(Icons.arrow_forward_rounded, size: 20), onTap: () => _read(store.lastPage, panel: 'jump'))),
          ] else if (store != null) ...[
            Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Mushafını hazırla', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8), const Text('Bir kez indir, her yerde çevrimdışı oku.'),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: store.downloaded.length / store.edition.pageCount, borderRadius: BorderRadius.circular(8), minHeight: 6),
                const SizedBox(height: 10), Text('Hazırlanan sayfalar: ${store.downloaded.length} / ${store.edition.pageCount}'),
                const SizedBox(height: 18),
                if (_downloading) OutlinedButton(onPressed: _pauseRequested ? null : () => setState(() => _pauseRequested = true),
                  child: Text(_pauseRequested ? 'Mevcut sayfa tamamlanıyor…' : 'İndirmeyi duraklat'))
                else FilledButton.icon(onPressed: _download, icon: const Icon(Icons.download_rounded),
                  label: Text(store.downloaded.isEmpty ? 'Tam Kur’an’ı indir' : 'İndirmeye devam et')),
              ]))),
          ],
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.verified_outlined, size: 16, color: Color(0xFF8B7449)), const SizedBox(width: 6),
            Flexible(child: Text('${store?.edition.name ?? 'Kur’an-ı Kerim'} · Reklamsız okuma', style: const TextStyle(color: Color(0xFF776F61), fontSize: 12))),
          ]),
        ]))),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickAction({required this.width, required this.icon, required this.title,
    required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: Card(margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: Padding(
      padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
          color: const Color(0xFFF0E8D5), borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: const Color(0xFF7E6533), size: 24)),
        const SizedBox(height: 14), Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Color(0xFF827A6C), fontSize: 12)),
      ])))));
}

class _Ornament extends StatelessWidget {
  const _Ornament();
  @override
  Widget build(BuildContext context) => Transform.rotate(angle: .45,
    child: SizedBox(width: 180, height: 180, child: Stack(alignment: Alignment.center, children: [
      for (var i = 0; i < 4; i++) Transform.rotate(angle: i * .39,
        child: Container(width: 125, height: 125,
          decoration: BoxDecoration(border: Border.all(color: const Color(0x24E5C383), width: 1.5)))),
      Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle,
        border: Border.all(color: const Color(0x18E5C383)))),
    ])));
}

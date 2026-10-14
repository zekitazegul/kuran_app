import 'l10n/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/app_language.dart';
import 'screens/language_screen.dart';
import 'widgets/language_selector.dart';
import 'screens/information_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/quran_screen.dart';
import 'services/reading_store.dart';
import 'widgets/quran_artwork.dart';
import 'data/surahs.dart';

void main() => runApp(KuranApp());

class KuranApp extends StatelessWidget {
  const KuranApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Locale?>(
    valueListenable: AppLanguage.instance,
    builder: (context, locale, _) => MaterialApp(
    locale: locale ?? Locale('tr'),
    supportedLocales: [Locale('tr'), Locale('en'), Locale('nl')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    debugShowCheckedModeBanner: false, title: translate('Kuran App', locale?.languageCode ?? 'tr'),
    theme: ThemeData(useMaterial3: true,
      scaffoldBackgroundColor: Color(0xFFF8F4EB),
      colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF164D43),
        primary: Color(0xFF164D43), secondary: Color(0xFFB28A46),
        surface: Color(0xFFFFFCF5)),
      appBarTheme: AppBarTheme(backgroundColor: Color(0xFFF8F4EB),
        foregroundColor: Color(0xFF163D35), centerTitle: false, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      cardTheme: CardThemeData(elevation: 0, color: Color(0xFFFFFCF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: Color(0xFFE8DFCC))))),
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReadingStore? _store;
  String? _error;
  bool _downloadError = false;
  bool _downloading = false;
  bool _pauseRequested = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final store = await ReadingStore.load();
      AppLanguage.instance.restore(store.language);
      if (mounted) setState(() { _store = store; _error = null; _downloadError = false; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Okuma kayıtları yüklenemedi. Bu sürüm Android içindir.');
    }
  }

  Future<void> _download() async {
    final store = _store!;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(context.t('{edition} · Mushafı indir', {'edition': context.t(store.edition.name)})),
      content: Text(context.t('Seçili hattın PDF’si indirilecek ve sayfalar cihazınızda hazırlanacak. Hazırlanan görseller ek depolama alanı kullanır. Wi-Fi kullanmanız önerilir. İndirme sırasında uygulamayı açık tutun; duraklatıp daha sonra kaldığınız yerden sürdürebilirsiniz.')),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t('İptal'))),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.t('İndirmeyi başlat')))],
    ));
    if (confirmed != true || !mounted) return;
    setState(() { _downloading = true; _pauseRequested = false; _error = null; _downloadError = false; });
    try {
      for (var page = store.edition.firstPage; page <= store.edition.lastPage; page++) {
        if (_pauseRequested || !mounted) break;
        if (store.downloaded.contains(page)) continue;
        await store.downloadPage(page);
        if (mounted) setState(() {});
      }
    } catch (error) {
      if (!mounted) return;
      final raw = error is PlatformException ? (error.message ?? error.code) : error.toString();
      setState(() { _error = raw; _downloadError = true; });
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
    if (store != null && AppLanguage.instance.value == null) {
      return LanguageScreen(onSelected: () { if (mounted) setState(() {}); });
    }
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
      appBar: AppBar(leading: Padding(padding: EdgeInsets.all(6),
        child: QuranArtwork(size: 44, decorative: true)),
        titleSpacing: 0, title: Text(context.t('Kur’an-ı Kerim'), style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [IconButton(tooltip: context.t('Ayarlar'), icon: Icon(Icons.tune_rounded),
          onPressed: store == null || _downloading ? null : () async {
            await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SettingsScreen(store: store)));
            if (mounted) setState(() {});
          }), LanguageSelector()]),
      body: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 680),
        child: ListView(padding: EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF164D43), Color(0xFF092F2A)])),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              Positioned(top: -45, right: -45, child: _Ornament()),
              Padding(padding: EdgeInsets.all(26), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Color(0x22E5C383), borderRadius: BorderRadius.circular(20)),
                    child: Text(context.t('OKUMA VAKTİ'), style: TextStyle(color: Color(0xFFE5C383),
                      fontWeight: FontWeight.w600, letterSpacing: 2, fontSize: 11))),
                  SizedBox(height: 12),
                  Center(child: SizedBox(width: 220, height: 200, child: Stack(alignment: Alignment.center, children: [
                    Container(width: 155, height: 155, decoration: BoxDecoration(shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [Color(0x558DAD80), Color(0x008DAD80)]))),
                    QuranArtwork(size: 220),
                  ]))),
                  SizedBox(height: 20),
                  if (store != null && store.ready) ...[
                    Text('${store.edition.surahsOnPage(store.lastPage).map((s) => surahName(s, context.language)).join(' · ')}  /  ${store.lastPage == 0 ? context.t('Fatiha') : context.t('Sayfa {page}', {'page': store.lastPage})}',
                      style: TextStyle(color: Color(0xFFE1E9DC))),
                    SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Color(0xFFE5C383), foregroundColor: Color(0xFF173C32)),
                      onPressed: () => _read(store.lastPage), icon: Icon(Icons.play_arrow_rounded),
                      label: Text(context.t('Okumaya devam et')))),
                  ] else Text(context.t(store?.edition.name ?? 'Kur’an-ı Kerim'), style: TextStyle(color: Color(0xFFE1E9DC))),
                ])),
            ])),
          SizedBox(height: 24),
          if (store == null && _error == null) Center(child: CircularProgressIndicator()),
          if (_error != null) Padding(padding: EdgeInsets.only(bottom: 16),
            child: Text(_downloadError ? context.t('İndirme tamamlanamadı: {detail}\n\nİndirilen sayfalar korunur; tekrar deneyerek devam edebilirsiniz.', {'detail': context.t(_error!)}) : context.t(_error!), style: TextStyle(color: Theme.of(context).colorScheme.error))),
          if (store == null && _error != null) OutlinedButton(onPressed: _load, child: Text(context.t('Tekrar dene'))),
          if (store != null && store.ready) ...[
            Row(children: [Expanded(child: Text(context.t('Kütüphanem'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
              Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Color(0xFFEAE4D4), borderRadius: BorderRadius.circular(20)),
                child: Text(context.t('{count} sure', {'count': store.edition.surahIndex.length}), style: TextStyle(color: Color(0xFF6B634E), fontSize: 12))),
            ]),
            SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                _QuickAction(width: width, icon: Icons.format_list_numbered_rounded,
                  title: context.t('Sure / Cüz'), subtitle: context.t('{count} sure', {'count': store.edition.surahIndex.length}), onTap: () => _read(store.lastPage, panel: 'surah')),
                _QuickAction(width: width, icon: Icons.bookmarks_outlined,
                  title: context.t('Ayraçlarım'), subtitle: context.t('{count} kayıt', {'count': store.bookmarks.length}), onTap: () => _read(store.lastPage, panel: 'bookmarks')),
                _QuickAction(width: width, icon: Icons.menu_book_outlined,
                  title: context.t('Fetih'), subtitle: context.t('Sayfa {page}', {'page': store.edition.surahIndex[47].startPage}), onTap: () => _read(store.edition.surahIndex[47].startPage)),
                _QuickAction(width: width, icon: Icons.auto_stories_outlined,
                  title: context.t('Yasin'), subtitle: context.t('Sayfa {page}', {'page': store.edition.yasinPage}), onTap: () => _read(store.edition.yasinPage)),
              ]);
            }),
            SizedBox(height: 20),
            Card(child: ListTile(leading: Icon(Icons.numbers_rounded), title: Text(context.t('Sayfaya git')),
              trailing: Icon(Icons.arrow_forward_rounded, size: 20), onTap: () => _read(store.lastPage, panel: 'jump'))),
          ] else if (store != null) ...[
            Card(child: Padding(padding: EdgeInsets.all(22), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(context.t('Mushafını hazırla'), style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8), Text(context.t('Bir kez indir, her yerde çevrimdışı oku.')),
                SizedBox(height: 20),
                LinearProgressIndicator(value: store.downloaded.length / store.edition.pageCount, borderRadius: BorderRadius.circular(8), minHeight: 6),
                SizedBox(height: 10), Text(context.t('Hazırlanan sayfalar: {done} / {total}', {'done': store.downloaded.length, 'total': store.edition.pageCount})),
                SizedBox(height: 18),
                if (_downloading) OutlinedButton(onPressed: _pauseRequested ? null : () => setState(() => _pauseRequested = true),
                  child: Text(_pauseRequested ? context.t('Mevcut sayfa tamamlanıyor…') : context.t('İndirmeyi duraklat')))
                else FilledButton.icon(onPressed: _download, icon: Icon(Icons.download_rounded),
                  label: Text(store.downloaded.isEmpty ? context.t('Tam Kur’an’ı indir') : context.t('İndirmeye devam et'))),
              ]))),
          ],
          SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.verified_outlined, size: 16, color: Color(0xFF8B7449)), SizedBox(width: 6),
            Flexible(child: Text(context.t('{edition} · Reklamsız okuma', {'edition': context.t(store?.edition.name ?? 'Kur’an-ı Kerim')}), style: TextStyle(color: Color(0xFF776F61), fontSize: 12))),
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
      padding: EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(
          color: Color(0xFFF0E8D5), borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: Color(0xFF7E6533), size: 24)),
        SizedBox(height: 14), Text(context.t(title), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        SizedBox(height: 4), Row(children: [
          Expanded(child: Text(context.t(subtitle), style: TextStyle(color: Color(0xFF827A6C), fontSize: 12))),
          Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF9B834F)),
        ]),
      ])))));
}

class _Ornament extends StatelessWidget {
  const _Ornament();
  @override
  Widget build(BuildContext context) => Transform.rotate(angle: .45,
    child: SizedBox(width: 180, height: 180, child: Stack(alignment: Alignment.center, children: [
      for (var i = 0; i < 4; i++) Transform.rotate(angle: i * .39,
        child: Container(width: 125, height: 125,
          decoration: BoxDecoration(border: Border.all(color: Color(0x24E5C383), width: 1.5)))),
      Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle,
        border: Border.all(color: Color(0x18E5C383)))),
    ])));
}

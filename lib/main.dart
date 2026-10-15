import 'services/app_preferences.dart';
import 'screens/support_screen.dart';
import 'dart:async';
import 'screens/about_screen.dart';
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
  Widget build(BuildContext context) => ValueListenableBuilder<UiPreferences>(
    valueListenable: AppPreferences.instance,
    builder: (context, preferences, _) => ValueListenableBuilder<Locale?>(
      valueListenable: AppLanguage.instance,
      builder: (context, locale, _) => MaterialApp(
        locale: locale ?? const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en'), Locale('nl')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false, title: 'KuranApp',
        themeMode: preferences.themeMode,
        theme: _theme(preferences.seed, Brightness.light),
        darkTheme: _theme(preferences.seed, Brightness.dark),
        home: const HomeScreen(),
      ),
    ),
  );

  ThemeData _theme(Color seed, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(useMaterial3: true, colorScheme: scheme,
      scaffoldBackgroundColor: dark ? scheme.surface : const Color(0xFFF8F4EB),
      appBarTheme: AppBarTheme(backgroundColor: dark ? scheme.surface : const Color(0xFFF8F4EB),
        foregroundColor: scheme.onSurface, centerTitle: false, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      cardTheme: CardThemeData(elevation: 0, color: dark ? scheme.surfaceContainerLow : const Color(0xFFFFFCF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant))),
    );
  }

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
  bool _cancelRequested = false;
  bool _returningToReading = false;
  Completer<void>? _downloadStopped;

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
      title: Text(context.t('{edition} · Kur’an sayfalarını indir', {'edition': context.t(store.edition.name)})),
      content: Text(context.t('Seçilen hat cihazına indirilecek. Wi-Fi kullanmanı ve işlem boyunca uygulamayı açık tutmanı öneririz. İndirmeyi duraklatıp daha sonra devam edebilirsin.')),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t('İptal'))),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.t('İndirmeyi başlat')))],
    ));
    if (confirmed != true || !mounted) return;
    _downloadStopped = Completer<void>();
    setState(() { _downloading = true; _pauseRequested = false; _cancelRequested = false; _error = null; _downloadError = false; });
    ReadingStore.channel.setMethodCallHandler((call) async {
      if (call.method != 'downloadProgress' || !mounted) return;
      final data = call.arguments as Map;
      if (data['edition'] != store.edition.id) return;
      final bytes = (data['bytes'] as num).toInt();
      if (bytes != store.downloadedBytes) setState(() => store.downloadedBytes = bytes);
    });
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
      ReadingStore.channel.setMethodCallHandler(null);
      if (mounted) setState(() => _downloading = false);
      _downloadStopped?.complete();
      _downloadStopped = null;
    }
  }

  Future<void> _cancelDownload() async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(dialogContext.t('İndirmeyi iptal et')),
      content: Text(dialogContext.t('İndirme mevcut sayfadan sonra durdurulacak. İndirilen sayfalar korunur; daha sonra devam edebilirsin.')),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(dialogContext.t('Vazgeç'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(dialogContext.t('İndirmeyi iptal et')))],
    ));
    if (confirmed != true || !mounted || !_downloading) return;
    setState(() { _cancelRequested = true; _pauseRequested = true; });
  }

  Future<void> _returnToReading({bool exitIfUnavailable = false}) async {
    final store = _store;
    if (store == null || _returningToReading) return;
    setState(() { _returningToReading = true; _pauseRequested = true; });
    try {
      await _downloadStopped?.future;
      if (!mounted) return;
      if (store.ready || await store.restoreDownloadedEdition()) {
        if (mounted) setState(() { _error = null; _downloadError = false; _cancelRequested = false; });
      } else if (mounted) {
        if (exitIfUnavailable) {
          await SystemNavigator.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Henüz tamamen indirilmiş bir hat yok.'))));
        }
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('İndirilen hatta dönülemedi. Tekrar dene.'))));
    } finally { if (mounted) setState(() => _returningToReading = false); }
  }

  void _about() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AboutScreen()));
  }

  Future<void> _settings() async {
    final store = _store;
    if (store == null || _downloading || _returningToReading) return;
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SettingsScreen(store: store)));
    if (mounted) setState(() {});
  }

  String _shortcutName(HomeShortcut shortcut) => shortcut.kind == ShortcutKind.surah
    ? shortcut.number == 36 ? context.t('Yasin') : surahName(_store!.edition.surahIndex[shortcut.number - 1], context.language)
    : context.t('Cüz {number}', {'number': shortcut.number});

  void _openShortcut(HomeShortcut shortcut) {
    final page = shortcut.kind == ShortcutKind.surah
      ? _store!.edition.surahIndex[shortcut.number - 1].startPage : shortcut.firstPage;
    _read(page);
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
    return PopScope(
      canPop: store == null || store.ready,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _returnToReading(exitIfUnavailable: true);
      },
      child: Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(leading: store != null && !store.ready
        ? IconButton(tooltip: context.t('Ana sayfaya dön'), icon: const Icon(Icons.arrow_back),
            onPressed: _returningToReading ? null : () => _returnToReading())
        : Padding(padding: EdgeInsets.all(6),
        child: InkWell(onTap: _about, child: Tooltip(message: context.t('Uygulama hakkında'),
          child: const QuranArtwork(size: 44, decorative: true)))),
        titleSpacing: 0, title: Text('KuranApp', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [IconButton(tooltip: context.t('Ayarlar'), icon: Icon(Icons.tune_rounded),
          onPressed: store == null || _downloading || _returningToReading ? null : _settings), LanguageSelector()]),
      body: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 680),
        child: ListView(padding: EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppPreferences.instance.value.seed,
                HSLColor.fromColor(AppPreferences.instance.value.seed).withLightness(.12).toColor()])),
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
                  if (store != null && !store.ready) ...[
                    ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset(
                      'assets/previews/${store.edition.id}.png',
                      width: double.infinity, fit: BoxFit.contain,
                      semanticLabel: context.t('{edition} · Hat ön izleme',
                        {'edition': context.t(store.edition.name)}))),
                    const SizedBox(height: 8),
                    Text(context.t('Hat ön izleme'),
                      style: const TextStyle(color: Color(0xFFE1E9DC), fontSize: 12)),
                  ] else Center(child: InkWell(onTap: _about,
                    child: const QuranArtwork(size: 180, decorative: true))),
                  SizedBox(height: 20),
                  if (store != null && store.ready) ...[
                    Text('${store.edition.surahsOnPage(store.lastPage).map((s) => surahName(s, context.language)).join(' · ')}  /  ${store.lastPage == 0 ? context.t('Fatiha') : context.t('Sayfa {page}', {'page': store.lastPage})}',
                      style: TextStyle(color: Color(0xFFE1E9DC))),
                    SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Color(0xFFE5C383), foregroundColor: Color(0xFF173C32)),
                      onPressed: () => _read(store.lastPage), icon: Icon(Icons.play_arrow_rounded),
                      label: Text(context.t('Okumaya devam et')))),
                  ] else Text(context.t(store?.edition.name ?? 'KuranApp'), style: TextStyle(color: Color(0xFFE1E9DC))),
                ])),
            ])),
          SizedBox(height: 24),
          if (store == null && _error == null) Center(child: CircularProgressIndicator()),
          if (_error != null) Padding(padding: EdgeInsets.only(bottom: 16),
            child: Text(_downloadError ? context.t('İndirme tamamlanamadı: {detail}\n\nİndirilen sayfalar korunur; tekrar deneyerek devam edebilirsiniz.', {'detail': context.t(_error!)}) : context.t(_error!), style: TextStyle(color: Theme.of(context).colorScheme.error))),
          if (store == null && _error != null) OutlinedButton(onPressed: _load, child: Text(context.t('Tekrar dene'))),
          if (store != null && store.ready) ...[
            _MenuRow(icon: Icons.search_rounded, title: context.t('Arama / sure, cüz, sayfa'),
              onTap: () => _read(store.lastPage, panel: 'surah')),
            _MenuRow(icon: Icons.bookmarks_outlined, title: context.t('Ayraçlarım'),
              onTap: () => _read(store.lastPage, panel: 'bookmarks')),
            for (final shortcut in AppPreferences.instance.value.shortcuts)
              _MenuRow(icon: shortcut.kind == ShortcutKind.surah ? Icons.menu_book_outlined : Icons.auto_stories_outlined,
                title: _shortcutName(shortcut), onTap: () => _openShortcut(shortcut)),
            _MenuRow(icon: Icons.favorite_outline, title: context.t('Destek'),
              onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SupportScreen()))),
            _MenuRow(icon: Icons.tune_rounded, title: context.t('Ayarlar'), onTap: _settings),
          ] else if (store != null) ...[
            Card(child: Padding(padding: EdgeInsets.all(22), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(context.t(store.edition.id == 'husrev' ? 'Hüsrev hattını indir'
                  : store.edition.id == 'hat2' ? 'Bilgisayar Hattı 2’yi indir' : 'Bilgisayar hattını indir'),
                  style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8), Text(context.t('İndirilecek sayfalar: {size} MB', {'size': (store.edition.downloadBytes / 1000000).toStringAsFixed(1)})),
                SizedBox(height: 20),
                Text(context.t(store.sourceDownloaded
                  ? '2 / 2 · Sayfalar cihaza indiriliyor'
                  : '1 / 2 · Dosya indiriliyor')),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: store.sourceDownloaded
                  ? store.downloaded.length / store.edition.pageCount
                  : (store.downloadedBytes / store.edition.downloadBytes).clamp(0.0, 1.0),
                  borderRadius: BorderRadius.circular(8), minHeight: 6),
                const SizedBox(height: 10),
                if (!store.sourceDownloaded)
                  Text(context.t('İndirilen: {done} MB · Kalan: {remaining} MB', {
                    'done': (store.downloadedBytes / 1000000).toStringAsFixed(1),
                    'remaining': ((store.edition.downloadBytes - store.downloadedBytes).clamp(0, store.edition.downloadBytes) / 1000000).toStringAsFixed(1)}))
                else ...[
                  Text(context.t('İndirilen: {done}/{total}', {
                    'done': store.downloaded.length, 'total': store.edition.pageCount})),
                ],
                SizedBox(height: 18),
                if (_downloading) ...[
                  OutlinedButton(onPressed: _pauseRequested ? null : () => setState(() => _pauseRequested = true),
                    child: Text(context.t(_pauseRequested ? 'İndirme durduruluyor…' : 'İndirmeyi duraklat'))),
                  TextButton(onPressed: _pauseRequested ? null : _cancelDownload,
                    child: Text(context.t('İndirmeyi iptal et'))),
                ] else ...[
                  if (_cancelRequested) Text(context.t('İndirme iptal edildi. İndirilen sayfalar korundu.')),
                  FilledButton.icon(onPressed: _returningToReading ? null : _download, icon: const Icon(Icons.download_rounded),
                    label: Text(context.t(store.downloadedBytes == 0 && store.downloaded.isEmpty
                      ? 'İndirmeyi başlat' : 'İndirmeye devam et'))),
                ],
              ]))),
          ],
          SizedBox(height: 24),
        ]))),
    ));
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuRow({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(dense: true, minVerticalPadding: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20), onTap: onTap),
  );
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

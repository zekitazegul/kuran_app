import 'widgets/update_dialog.dart';
import 'widgets/compact_confirmation_dialog.dart';
import 'services/app_preferences.dart';
import 'screens/meal_screen.dart';
import 'screens/listening_screen.dart';
import 'widgets/app_bottom_bar.dart';
import 'widgets/dashboard_cards.dart';
import 'widgets/bottom_up_page_transitions.dart';
import 'screens/reading_history_screen.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const KuranApp());
}

final appNavigatorKey = GlobalKey<NavigatorState>();

class KuranApp extends StatelessWidget {
  const KuranApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<UiPreferences>(
    valueListenable: AppPreferences.instance,
    builder: (context, preferences, _) => ValueListenableBuilder<Locale?>(
      valueListenable: AppLanguage.instance,
      builder: (context, locale, _) => MaterialApp(
        navigatorKey: appNavigatorKey,
        builder: (context, child) => NavigationOverlay(child: Column(children: [Expanded(child: child!), const AnimatedAppBottomBar()])),
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
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        for (final platform in TargetPlatform.values) platform: const BottomUpPageTransitionsBuilder(),
      }),
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
  final _dashboardScroll = ScrollController();
  String? _error;
  bool _downloadError = false;
  bool _downloading = false;
  bool _pauseRequested = false;
  bool _cancelRequested = false;
  bool _returningToReading = false;
  bool _exitConfirmationOpen = false;
  bool _updateScheduled = false;
  int _navigationId = 0;
  Completer<void>? _downloadStopped;

  @override
  void initState() {
    super.initState();
    AppNavigation.instance.open = _navigate;
    AppNavigation.instance.openCard = _openDashboardCard;
    _load();
  }

  void _openDashboardCard(String id) {
    if (_store == null || _downloading || _returningToReading) return;
    appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    if (id == 'meal') {
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const MealScreen()));
    } else if (id == 'listen') {
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ListeningScreen()));
    } else if (id == 'support') {
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SupportScreen()));
    } else if (_store!.ready) {
      for (final shortcut in AppPreferences.instance.value.shortcuts) {
        if (shortcut.id == id) { _openShortcut(shortcut); break; }
      }
    }
  }

  Future<void> _navigate(AppDestination destination) async {
    if (destination == AppDestination.exit) {
      final navigator = appNavigatorKey.currentState;
      if (navigator != null && navigator.canPop()) {
        await navigator.maybePop();
      } else {
        await _confirmExit();
      }
      return;
    }
    final store = _store;
    if (store == null || _downloading || _returningToReading) return;
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;
    if (destination != AppDestination.home &&
        AppNavigation.instance.selected.value == destination && navigator.canPop()) {
      ++_navigationId;
      navigator.popUntil((route) => route.isFirst);
      AppNavigation.instance.selected.value = AppDestination.home;
      return;
    }
    navigator.popUntil((route) => route.isFirst);
    final navigationId = ++_navigationId;
    AppNavigation.instance.selected.value = destination;
    try {
    if (destination == AppDestination.home) { setState(() {}); return; }
    if (destination == AppDestination.settings) { await _settings(); return; }
    if (destination == AppDestination.history) {
      await navigator.push(MaterialPageRoute<void>(builder: (_) => ReadingHistoryScreen(store: store)));
      if (mounted) setState(() {});
      return;
    }
    if (destination == AppDestination.hatim && store.ready) {
      await navigator.push(MaterialPageRoute<void>(builder: (_) => QuranScreen(store: store,
        initialPage: store.hatimComplete ? store.edition.lastPage : store.hatimResume ?? store.nextHatimPage()!,
        initialPanel: store.hatimComplete ? 'prayer' : null, hatim: true)));
      return;
    }
    if (store.ready) {
      await _read(store.lastPage, panel: destination == AppDestination.bookmarks
        ? 'bookmarks' : destination == AppDestination.search ? 'jump' : 'surah');
    }
    } finally {
      if (mounted && navigationId == _navigationId) {
        AppNavigation.instance.selected.value = AppDestination.home;
      }
    }
  }

  Future<void> _load() async {
    try {
      final store = await ReadingStore.load();
      AppLanguage.instance.restore(store.language);
      AppNavigation.instance.value = store;
      if (mounted) setState(() { _store = store; _error = null; _downloadError = false; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Okuma kayıtları yüklenemedi. Bu sürüm Android içindir.');
    }
  }

  Future<void> _download() async {
    final store = _store!;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => CompactConfirmationDialog(
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
      AppNavigation.instance.refresh();
      if (mounted) setState(() => _downloading = false);
      _downloadStopped?.complete();
      _downloadStopped = null;
    }
  }

  Future<void> _cancelDownload() async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => CompactConfirmationDialog(
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
          await _confirmExit();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Henüz tamamen indirilmiş bir hat yok.'))));
        }
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('İndirilen hatta dönülemedi. Tekrar dene.'))));
    } finally { if (mounted) setState(() => _returningToReading = false); }
  }

  Future<void> _confirmExit() async {
    if (_exitConfirmationOpen || !mounted) return;
    _exitConfirmationOpen = true;
    try {
      final exit = await showDialog<bool>(context: context, builder: (dialogContext) => Dialog(
        alignment: Alignment.bottomCenter,
        insetPadding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(key: const ValueKey('exit-confirmation'), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Expanded(child: Text(dialogContext.t('Çıkış?'), style: Theme.of(dialogContext).textTheme.titleMedium)),
            TextButton(onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(dialogContext.t('İptal'))),
            const SizedBox(width: 8),
            FilledButton(style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: const Size(64, 40)),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(dialogContext.t('Tamam'))),
          ])),
      ));
      if (exit == true && mounted) await SystemNavigator.pop();
    } finally { _exitConfirmationOpen = false; }
  }

  Widget _guardExit(Widget child) => PopScope(canPop: false,
    onPopInvokedWithResult: (didPop, result) { if (!didPop) _confirmExit(); }, child: child);

  void _about() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AboutScreen()));
  }

  Future<void> _settings() async {
    final store = _store;
    if (store == null || _downloading || _returningToReading) return;
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SettingsScreen(store: store)));
    AppNavigation.instance.refresh();
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
    AppNavigation.instance.refresh();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pauseRequested = true;
    _dashboardScroll.dispose();
    AppNavigation.instance.open = null;
    AppNavigation.instance.openCard = null;
    AppNavigation.instance.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    if (store != null && AppLanguage.instance.value == null) {
      return _guardExit(LanguageScreen(onSelected: () { if (mounted) setState(() {}); }));
    }
    if (store != null && !store.informationSeen) {
      return _guardExit(InformationScreen(onContinue: () async {
        await store.acknowledgeInformation();
        AppNavigation.instance.refresh();
        if (mounted) setState(() {});
      }));
    }
    if (store != null && !store.guideSeen) {
      return _guardExit(GuideScreen(onContinue: () async {
        await store.acknowledgeGuide();
        AppNavigation.instance.refresh();
        if (mounted) setState(() {});
      }));
    }
    if (store != null && store.appVersion != null &&
        store.seenUpdateVersion != store.appVersion && !_updateScheduled) {
      _updateScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showUpdateDialog(context, store.appVersion!.split('+').first);
        if (!mounted) return;
        try {
          await ReadingStore.channel.invokeMethod<void>('acknowledgeUpdate');
          store.seenUpdateVersion = store.appVersion;
        } catch (_) {
          // Retry on the next launch if the acknowledgement cannot be saved.
        }
      });
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (store == null || store.ready) {
            _confirmExit();
          } else {
            _returnToReading(exitIfUnavailable: true);
          }
        }
      },
      child: Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(leading: store != null && !store.ready
        ? IconButton(tooltip: context.t('Ana sayfaya dön'), icon: const Icon(Icons.arrow_back),
            onPressed: _returningToReading ? null : () => _returnToReading())
        : Padding(padding: EdgeInsets.all(6),
        child: InkWell(onTap: _about, child: Tooltip(message: context.t('Uygulama hakkında'),
          child: const QuranArtwork(size: 44, decorative: true)))),
        titleSpacing: 0, title: Text('KuranApp', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [IconButton(tooltip: context.t('Ayarlar'), icon: Icon(Icons.settings_rounded),
          onPressed: store == null || _downloading || _returningToReading ? null : _settings), LanguageSelector()]),
      body: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 680),
        child: ListView(controller: _dashboardScroll, padding: EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppPreferences.instance.value.seed,
                HSLColor.fromColor(AppPreferences.instance.value.seed).withLightness(.12).toColor()])),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              Positioned(top: -45, right: -45, child: _Ornament()),
              Padding(padding: const EdgeInsets.all(20), child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (store != null && store.ready) ...[
                    Row(children: [
                      InkWell(onTap: _about, child: const QuranArtwork(size: 64, decorative: true)),
                      const SizedBox(width: 16),
                      Expanded(child: Text('${store.edition.surahsOnPage(store.lastPage).map((s) => surahName(s, context.language)).join(' · ')} / ${store.lastPage == 0 ? context.t('Fatiha') : context.t('Sayfa {page}', {'page': store.lastPage})}',
                        style: const TextStyle(color: Color(0xFFE1E9DC), fontSize: 16, fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE5C383),
                        foregroundColor: const Color(0xFF173C32),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      onPressed: () => _read(store.lastPage), icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(context.t('Okumaya devam et'))),
                  ] else if (store != null) ...[
                    ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset(
                      'assets/previews/${store.edition.id}.png', height: 140, fit: BoxFit.contain,
                      semanticLabel: context.t('{edition} · Hat ön izleme', {'edition': context.t(store.edition.name)}))),
                    const SizedBox(height: 12),
                    Text(context.t(store.edition.name), style: const TextStyle(color: Color(0xFFE1E9DC))),
                  ] else const Center(child: QuranArtwork(size: 64, decorative: true)),
                ])),
            ])),
          SizedBox(height: 24),
          if (store == null && _error == null) Center(child: CircularProgressIndicator()),
          if (_error != null) Padding(padding: EdgeInsets.only(bottom: 16),
            child: Text(_downloadError ? context.t('İndirme tamamlanamadı: {detail}\n\nİndirilen sayfalar korunur; tekrar deneyerek devam edebilirsiniz.', {'detail': context.t(_error!)}) : context.t(_error!), style: TextStyle(color: Theme.of(context).colorScheme.error))),
          if (store == null && _error != null) OutlinedButton(onPressed: _load, child: Text(context.t('Tekrar dene'))),
          if (store != null) DashboardCards(scrollController: _dashboardScroll, cards: {
            'meal': _MenuRow(icon: Icons.translate_rounded,
              title: context.t('Meal Oku'), subtitle: 'Ali Ünal',
              onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const MealScreen()))),
            'listen': _MenuRow(icon: Icons.headphones_rounded,
              title: context.t("Kur'an dinle"),
              onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ListeningScreen()))),
            if (store.ready) ...{
              'hatim': _MenuRow(icon: Icons.auto_stories_rounded, title: context.t('Hatim'),
                onTap: () => _navigate(AppDestination.hatim)),
              'history': _MenuRow(icon: Icons.history_rounded, title: context.t('Okuma geçmişi'),
              onTap: () => _navigate(AppDestination.history)),
              'search': _MenuRow(icon: Icons.auto_stories_rounded, title: context.t('Sure, cüz, sayfa'),
              onTap: () => _read(store.lastPage, panel: 'surah')),
              'bookmarks': _MenuRow(icon: Icons.bookmarks_rounded, title: context.t('Ayraçlarım'),
              onTap: () => _read(store.lastPage, panel: 'bookmarks')),
            for (final shortcut in AppPreferences.instance.value.shortcuts)
              shortcut.id: _MenuRow(icon: shortcut.kind == ShortcutKind.surah ? Icons.menu_book_outlined : Icons.auto_stories_outlined,
                title: _shortcutName(shortcut), onTap: () => _openShortcut(shortcut)),
              'support': _MenuRow(icon: Icons.favorite_outline, title: context.t('Destek'),
              onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SupportScreen()))),
              'settings': _MenuRow(icon: Icons.settings_rounded, title: context.t('Ayarlar'), onTap: _settings),
            },
          }),
          if (store != null && !store.ready) ...[
            Card(child: Padding(padding: EdgeInsets.all(22), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(context.t(store.edition.id == 'husrev' ? 'Hüsrev hattını indir'
                  : store.edition.id == 'hat2' ? 'Yakupzâde İzzet Efendi hattını indir' : 'Süleyman Feyzullahoğlu hattını indir'),
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
  final String? subtitle;
  final VoidCallback onTap;
  const _MenuRow({required this.icon, required this.title, required this.onTap, this.subtitle});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(dense: true, minVerticalPadding: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      subtitle: subtitle == null ? null : Text(subtitle!),
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

import 'screens/meal_screen.dart';
import 'widgets/motif_surface.dart';
import 'widgets/feature_demo.dart';
import 'widgets/dashboard_cards.dart';
import 'screens/about_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'widgets/update_dialog.dart';
import 'widgets/required_update_gate.dart';
import 'widgets/compact_confirmation_dialog.dart';
import 'services/app_preferences.dart';
import 'services/voice_intents.dart';
import 'services/voice_suggestions.dart';
import 'services/voice_control.dart';
import 'services/verse_regions.dart';
import 'widgets/app_bottom_bar.dart';
import 'widgets/home_menu.dart';
import 'widgets/bottom_up_page_transitions.dart';
import 'screens/reading_history_screen.dart';
import 'screens/support_screen.dart';
import 'dart:async';
import 'l10n/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/app_language.dart';
import 'screens/language_screen.dart';
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
        builder: (context, child) => RequiredUpdateGate(child: NavigationOverlay(child: Stack(fit:StackFit.expand,children:[const Positioned.fill(child:MotifSurface()),Column(children: [Expanded(child: child!), const AnimatedAppBottomBar()])]))),
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
      bottomSheetTheme:const BottomSheetThemeData(
        shape:RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
        clipBehavior:Clip.antiAlias),
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        for (final platform in TargetPlatform.values) platform: const BottomUpPageTransitionsBuilder(),
      }),
      scaffoldBackgroundColor: Colors.transparent,
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
  final _homeScaffold = GlobalKey<ScaffoldState>();
  String? _error;
  bool _downloadError = false;
  bool _downloading = false;
  bool _pauseRequested = false;
  bool _cancelRequested = false;
  bool _returningToReading = false;
  bool _exitConfirmationOpen = false;
  bool _updateScheduled = false;
  bool _voiceBusy = false;
  int _navigationId = 0;
  Completer<void>? _downloadStopped;

  @override
  void initState() {
    super.initState();
    VoiceControl.listen = _voiceCommand;
    VoiceControl.help = _showVoiceHelp;
    AppNavigation.instance.open = _navigate;
    AppNavigation.instance.openCard = _openDashboardCard;
    AppNavigation.instance.navigationContext = () => appNavigatorKey.currentState?.overlay?.context;
    AppNavigation.instance.switchPage = null;
    AppPreferences.instance.addListener(_refreshChrome);
    AppNavigation.instance.fullscreenReader.addListener(_refreshChrome);
    AppNavigation.instance.fullscreenMeal.addListener(_refreshChrome);
    _load();
  }

  void _openDashboardCard(String id) {
    if (id == 'meal') {
      _navigate(AppDestination.meal);
      return;
    }
    if (_store == null || _downloading || _returningToReading) return;
    AppNavigation.instance.exitFullscreen();
    appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    if (id == 'support') {
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SupportScreen()));
    } else if (_store!.ready) {
      for (final shortcut in AppPreferences.instance.value.shortcuts) {
        if (shortcut.id == id) { _openShortcut(shortcut); break; }
      }
    }
  }

  void _refreshChrome() { if (mounted) setState(() {}); }

  void _selectMenu(String id) {
    AppNavigation.instance.exitFullscreen();
    _homeScaffold.currentState?.closeDrawer();
    final store = _store;
    if (store == null) return;
    switch (id) {
      case 'home': _navigate(AppDestination.home);
      case 'exit': _navigate(AppDestination.exit);
      case 'page': _read(store.lastPage,panel:'jump');
      case 'settings': _settings();
      case 'support': Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SupportScreen()));
      case 'search': _read(store.lastPage, panel: 'surah');
      case 'bookmarks': _openBookmarks();
      case 'history': _navigate(AppDestination.history);
      case 'hatim': _navigate(AppDestination.hatim);
      default: _openDashboardCard(id);
    }
  }

  Future<void> _voiceCommand() async {
    if (_voiceBusy || _store?.ready != true) return;
    setState(() => _voiceBusy = true);
    VoiceControl.busy.value = true;
    VoiceCommand? command;
    String? interruptedAudio;
    try {
      final audio=await ReadingStore.channel.invokeMapMethod<String,dynamic>('loadAudio');
      if(audio?['playing']!=null && audio?['paused']!=true) {
        interruptedAudio=audio!['playing'] as String;
        await ReadingStore.channel.invokeMethod<void>('pauseAudio');
      }
      if(!mounted)return;
      final results = await ReadingStore.channel.invokeListMethod<String>('recognizeVoice', {
        'language': {'tr': 'tr-TR', 'en': 'en-US', 'nl': 'nl-NL'}[context.language],
        'prompt': context.t('voicePrompt'),
      });
      if (!mounted || results == null || results.isEmpty) return;
      for (final result in results) {
        command = VoiceIntents.parse(result);
        if (command != null) break;
      }
      if (command == null) {
        _suggestVoiceCorrection(results);
      } else {
        await _executeVoice(command);
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('voiceUnavailable'))));
    } finally {
      if(interruptedAudio!=null && command?.action!=VoiceAction.pause && command?.action!=VoiceAction.stop) {
        try {
          final audio=await ReadingStore.channel.invokeMapMethod<String,dynamic>('loadAudio');
          if(audio?['playing']==interruptedAudio && audio?['paused']==true) {
            await ReadingStore.channel.invokeMethod<void>('resumeAudio');
          }
        } catch(_) { /* A stopped recording does not need resuming. */ }
      }
      VoiceControl.busy.value = false;
      if (mounted) setState(() => _voiceBusy = false);
    }
  }

  Future<void> _executeVoice(VoiceCommand command) async {
    final store = _store!;

    if (command.action == VoiceAction.help) {
      _showVoiceHelp();
      return;
    }
    if (command.action == VoiceAction.night || command.action == VoiceAction.day) {
      await AppPreferences.instance.save(AppPreferences.instance.value.copyWith(
        themeMode:command.action==VoiceAction.night?ThemeMode.dark:ThemeMode.light));
      return;
    }
    if (await VoiceControl.dispatch(command)) return;
    switch(command.action) {
      case VoiceAction.continueReading:
        unawaited(_readVoice(store.lastPage));
      case VoiceAction.surah:
        unawaited(_readVoice(store.edition.surahIndex[command.number!-1].startPage,
          voice:command,playSurah:command.play?command.number:null));
      case VoiceAction.page:
        if(command.number!<store.edition.firstPage || command.number!>store.edition.lastPage) { _voiceNotice('voiceInvalidTarget'); return; }
        unawaited(_readVoice(command.number!));
      case VoiceAction.juz:
        final page=command.number==1?store.edition.firstPage:(command.number!-1)*20+1;
        if(page>store.edition.lastPage) { _voiceNotice('voiceInvalidTarget');return; }
        unawaited(_readVoice(page));
      case VoiceAction.verse:
        final regions=await VerseRegions.load();
        int? page;
        for(var p=store.edition.firstPage;p<=store.edition.lastPage;p++) {
          if(regions.page(store.edition.id,p).any((v)=>v.surah==command.number && v.verse==command.verse)) {page=p;break;}
        }
        if(page==null) {_voiceNotice('voiceInvalidTarget');return;}
        unawaited(_readVoice(page,voice:command));
      case VoiceAction.bookmarks:
        unawaited(_navigate(AppDestination.bookmarks));
      default:
        _voiceNotice('voiceOpenReader');
    }
  }

  Future<void> _readVoice(int page,{VoiceCommand? voice,int? playSurah}) async {
    final navigator=appNavigatorKey.currentState;
    if(navigator==null)return;
    if(navigator.canPop()) {
      navigator.popUntil((route)=>route.isFirst);
      await Future<void>.delayed(const Duration(milliseconds:400));
      if(!mounted)return;
    }
    unawaited(_read(page,voice:voice,playSurah:playSurah));
  }

  void _showVoiceHelp({String? initialText}) {
    final controller=TextEditingController(text: initialText);
    final visible=appNavigatorKey.currentState?.overlay?.context;
    if(visible==null)return;
    unawaited(showDialog<String>(context:visible,builder:(context)=>AlertDialog(
      title:Text(context.t(initialText == null ? 'voiceHelpTitle' : 'voiceEditSuggestion')),
      content:SizedBox(width:520,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        if (initialText == null) ...[
          Text(context.t('voiceHelpBody')),
          const SizedBox(height:16),
        ],
        TextField(key:const ValueKey('voice-command-input'),controller:controller,
          decoration:InputDecoration(labelText:context.t('voiceTypeHint')),
          onSubmitted:(value)=>Navigator.pop(context,value)),
      ]))),
      actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(context.t('Kapat'))),
        FilledButton(key:const ValueKey('voice-command-apply'),onPressed:()=>Navigator.pop(context,controller.text),child:Text(context.t('voiceApply')))]
    )).then((text) async {
      if(text==null || text.trim().isEmpty || !mounted)return;
      final command=VoiceIntents.parse(text);
      if(command==null) {_suggestVoiceCorrection([text]);return;}
      try {await _executeVoice(command);}catch(_) {_voiceNotice('voiceUnavailable');}
    }).whenComplete(() {Future.delayed(const Duration(milliseconds:400),controller.dispose);}));
  }

  void _voiceNotice(String key) {
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.t(key))));
  }

  void _suggestVoiceCorrection(List<String> results) {
    if (!mounted) return;
    String? suggestion;
    for (final result in results) {
      suggestion = VoiceSuggestions.suggest(result, context.language);
      if (suggestion != null) break;
    }
    final correction = suggestion;
    ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(SnackBar(
      duration: const Duration(seconds: 8),
      content: Text(correction == null ? context.t('voiceNotUnderstood')
        : context.t('voiceSuggestedCorrection', {'command': correction})),
      action: SnackBarAction(label: context.t('voiceEditSuggestion'),
        onPressed: () => _showVoiceHelp(initialText: correction ?? results.first)),
    ));
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
      AppNavigation.instance.exitFullscreen();
      navigator.popUntil((route) => route.isFirst);
      AppNavigation.instance.selected.value = AppDestination.home;
      return;
    }
    AppNavigation.instance.exitFullscreen();
    navigator.popUntil((route) => route.isFirst);
    final navigationId = ++_navigationId;
    AppNavigation.instance.selected.value = destination;
    try {
    if (destination == AppDestination.home) { setState(() {}); return; }
    if (destination == AppDestination.meal) {
      await navigator.push(MaterialPageRoute<void>(builder: (_) => const MealScreen()));
      return;
    }
    if (destination == AppDestination.settings) { await _settings(); return; }
    if (destination == AppDestination.history) {
      await navigator.push(MaterialPageRoute<void>(builder: (_) => ReadingHistoryScreen(store: store)));
      if (mounted) setState(() {});
      return;
    }
    if (destination == AppDestination.bookmarks) {
      await navigator.push(MaterialPageRoute<void>(builder: (_) => BookmarksScreen(store: store)));
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
      await _read(store.lastPage, panel: switch (destination) {
        AppDestination.meal => 'meal',
        AppDestination.search => 'jump',
        _ => 'surah',
      });
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

  Future<void> _openBookmarks() async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => BookmarksScreen(store: _store!)));
    AppNavigation.instance.refresh();
    if (mounted) setState(() {});
  }

  Future<void> _read(int page, {String? panel, int? playSurah, VoiceCommand? voice}) async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => QuranScreen(store: _store!, initialPage: page, initialPanel: panel, initialPlaySurah: playSurah, initialVoice: voice)));
    AppNavigation.instance.refresh();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pauseRequested = true;
    VoiceControl.listen = null;
    VoiceControl.help = null;
    _dashboardScroll.dispose();
    AppPreferences.instance.removeListener(_refreshChrome);
    AppNavigation.instance.fullscreenReader.removeListener(_refreshChrome);
    AppNavigation.instance.fullscreenMeal.removeListener(_refreshChrome);
    AppNavigation.instance.open = null;
    AppNavigation.instance.openCard = null;
    AppNavigation.instance.switchPage = null;
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
        if (!context.mounted) return;
        if(AppPreferences.instance.value.demoRevision<featureDemoRevision) {
          await showFeatureDemo(context,initialStep:AppPreferences.instance.value.demoRevision>=1?4:0);
          if (!mounted) return;
          try { await AppPreferences.instance.save(AppPreferences.instance.value.copyWith(demoRevision:featureDemoRevision)); }
          catch (_) { /* The next feature update can retry saving the tutorial preference. */ }
        }
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
          if (_homeScaffold.currentState?.isDrawerOpen ?? false) {
            _homeScaffold.currentState?.closeDrawer();
            return;
          }
          if (store == null || store.ready) {
            _confirmExit();
          } else {
            _returnToReading(exitIfUnavailable: true);
          }
        }
      },
      child: Scaffold(key: _homeScaffold, drawerEnableOpenDragGesture: false, backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppNavigation.instance.fullscreenReader.value != null ? null : HomeHeader(
        onMenu: () => _homeScaffold.currentState?.openDrawer(),
        onVoice: store?.ready == true && !_voiceBusy ? _voiceCommand : null),
      drawer: store == null ? null : HomeMenu(preferences: AppPreferences.instance.value,
        ready: store.ready, shortcutName: _shortcutName, onSelected: _selectMenu),
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 680),
        child: ListView(controller: _dashboardScroll, padding: EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
            color: AppPreferences.instance.value.seed),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
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
          if(store != null && store.ready) DashboardCards(scrollController: _dashboardScroll,
            cards: {for(final id in AppPreferences.instance.value.availableDashboardCards)
              id: Card(child: ListTile(leading: Icon(bottomShortcutIcon(id)),
                title: Text(dashboardCardLabels.containsKey(id) ? context.t(dashboardCardLabels[id]!) :
                  _shortcutName(AppPreferences.instance.value.shortcuts.firstWhere((s)=>s.id==id))),
                trailing: const Icon(Icons.chevron_right),onTap:()=>_selectMenu(id)))}),
          if (store == null && _error == null) Center(child: CircularProgressIndicator()),
          if (_error != null) Padding(padding: EdgeInsets.only(bottom: 16),
            child: Text(_downloadError ? context.t('İndirme tamamlanamadı: {detail}\n\nİndirilen sayfalar korunur; tekrar deneyerek devam edebilirsiniz.', {'detail': context.t(_error!)}) : context.t(_error!), style: TextStyle(color: Theme.of(context).colorScheme.error))),
          if (store == null && _error != null) OutlinedButton(onPressed: _load, child: Text(context.t('Tekrar dene'))),
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
        ])))),
    ));
  }
}

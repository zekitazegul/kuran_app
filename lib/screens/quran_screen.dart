import '../widgets/verse_selection_overlay.dart';
import '../widgets/reader_action_bar.dart';
import '../widgets/screen_title.dart';
import '../widgets/personal_page_scope.dart';
import '../widgets/bookmarks_sheet.dart';
import '../widgets/compact_confirmation_dialog.dart';
import 'hatim_prayer_screen.dart';
import 'meal_screen.dart';
import 'hatim_selection_screen.dart';
import 'dart:async';
import 'dart:convert';
import '../services/quran_audio.dart';
import '../widgets/page_turn.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/sajdah_notice.dart';
import '../l10n/translations.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/surahs.dart';
import '../services/reading_store.dart';
import '../widgets/page_slide.dart';
import '../widgets/reading_page.dart';
import '../services/verse_regions.dart';
import '../widgets/verse_actions.dart';
import '../data/sajdah_verses.dart';

class QuranScreen extends StatefulWidget {
  final ReadingStore store;
  final int initialPage;
  final String? initialPanel;
  final bool hatim;
  const QuranScreen({super.key, required this.store, required this.initialPage, this.initialPanel, this.hatim = false});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver implements FullscreenReadingSession {
  final _audio = QuranAudio();
  Timer? _audioTimer;
  bool _audioBusy = false;
  VerseRegions? _verseRegions;

  Future<void> _verseAction(List<VerseRegion> verses, Offset anchor) async {
    final verse = verses.first;
    if (_target != null || _preparing || _audioBusy) return;
    final page = _page;
    final action = await showVerseActions(context, verse, anchor, selection: verses);
    if (!mounted || _page != page) return;
    try {
      if (action == 'verseMeal') await showVerseMeal(context, verse, selection: verses);
      if (action == 'verseAudio') await _playVerses(verse.surah, verse.verse, verse.verse, 1, selection: verses);
      if (action == 'verseMemorize') {
        if (!mounted) return;
        final range = await showMemorizeRange(context, verse, selection: verses);
        if (range != null && mounted) {
          await _playVerses(verse.surah, range.$1, range.$2, range.$3, cumulative: true,
            selection: verses.first.surah != verses.last.surah ? verses : null);
        }
      }
    } catch (_) { _error('Ses işlemi tamamlanamadı. Tekrar dene.'); }
  }

  Future<void> _playVerses(int surah, int first, int last, int repeats, {bool cumulative = false, List<VerseRegion>? selection}) async {
    if (_audioBusy) return;
    final page = _page;
    setState(() => _audioBusy = true);
    try {
      await _audio.load();
      if (_audio.playing != null) {
        _error('verseStopFirst');
        return;
      }
      final tracks = <AudioTrack>[];
      for (final verse in selection ?? [for (var v = first; v <= last; v++) VerseRegion(surah, v, [])]) {
        final track = _audio.find(verse.surah, verse.verse);
        if (track == null) { _error('verseAudioUnavailable'); return; }
        tracks.add(track);
      }
      final missing = tracks.where((t) => !_audio.downloaded.contains(t.id)).toList();
      if (missing.isNotEmpty) {
        if (!mounted) return;
        final yes = await showDialog<bool>(context: context, builder: (context) => CompactConfirmationDialog(
          title: Text(context.t('Ses dosyasını indir')),
          content: Text(context.t('verseDownloadHint', {'count': missing.length,
            'size': (missing.fold<int>(0, (sum, t) => sum + t.bytes) / 1000000).toStringAsFixed(1)})),
          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t('İptal'))),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.t('İndirmeyi başlat')))],
        ));
        if (yes != true) return;
        for (final track in missing) {
          if (!mounted || _page != page) return;
          await _audio.download(track);
        }
      }
      if (!mounted || _page != page) return;
      if (selection != null && tracks.length > 1) { await _audio.playSelection(tracks, repetitions: repeats, cumulative: cumulative); }
      else if (!cumulative && repeats == 1 && first == last) { await _audio.play(tracks.single); }
      else { await _audio.playRange(surah, first, last, repetitions: repeats, cumulative: cumulative); }
    } finally { if (mounted) setState(() => _audioBusy = false); }
  }

  Future<void> _listenPage() async {
    if (_audioBusy) return;
    final page = _page;
    setState(() => _audioBusy = true);
    try {
      await _audio.load();
      if (_audio.playing != null) { await _audio.stop(); return; }
      final track = _audio.findPage(page);
      if (track == null) { _error('verseAudioUnavailable'); return; }
      if (!_audio.downloaded.contains(track.id)) {
        if (!mounted) return;
        final yes = await showDialog<bool>(context: context, builder: (context) => CompactConfirmationDialog(
          title: Text(context.t('Ses dosyasını indir')),
          content: Text('${_audio.reciters[_audio.reciter]}\n${context.t('Bir kez indir, çevrimdışı dinle. Boyut: {size} MB', {'size': (track.bytes / 1000000).toStringAsFixed(1)})}'),
          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t('Vazgeç'))),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.t('İndirmeyi başlat')))]));
        if (yes != true) return;
        await _audio.download(track);
      }
      if (mounted && page == _page) await _audio.play(track);
    } catch (_) { _error('Ses işlemi tamamlanamadı. Tekrar dene.'); }
    finally { if (mounted) setState(() => _audioBusy = false); }
  }
  bool _mealOpen = false;
  Future<void> _mealPage({bool resume = false}) async {
    _mealOpen = true;
    if (identical(AppNavigation.instance.fullscreenReader.value, this)) {
      AppNavigation.instance.fullscreenReader.value = null;
    }
    try {
      final data = jsonDecode(await rootBundle.loadString('assets/page_verses.json')) as Map;
      final refs = (data['pages'] as List)[_page] as List;
      final first = refs.first as Map;
      if (!mounted) return;
      await _audio.stop();
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => MealScreen(
        initialSurah: resume ? null : first['surah'] as int, initialVerse: resume ? null : first['verse'] as int)));
    } catch (_) { _error('Meal açılamadı. Tekrar dene.'); }
    finally {
      _mealOpen = false;
      if (mounted && _fullscreen && (ModalRoute.of(context)?.isCurrent ?? false)) {
        AppNavigation.instance.fullscreenReader.value = this;
      }
    }
  }
  Timer? _historyTimer;
  String _historySession = DateTime.now().microsecondsSinceEpoch.toString();
  int? _recordedPage;
  bool _foreground = true;

  void _scheduleHistory() {
    _historyTimer?.cancel();
    final page = _page;
    final edition = widget.store.edition.id;
    _historyTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || !_foreground || !(ModalRoute.of(context)?.isCurrent ?? false) || _page != page ||
          widget.store.edition.id != edition || _target != null || _preparing) {
        return;
      }
      timer.cancel();
      if (_recordedPage == page) return;
      _recordedPage = page;
      widget.store.recordReading(page, _historySession).catchError((Object _) {
        _recordedPage = null;
        _error('Okuma geçmişi kaydedilemedi.');
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      _historySession = DateTime.now().microsecondsSinceEpoch.toString();
      _recordedPage = null;
      _scheduleHistory();
    } else {
      _historyTimer?.cancel();
    }
  }
  bool _hatimSaving = false;
  Future<void> _markHatim() async {
    if (_hatimSaving || _target != null || _preparing) return;
    setState(() => _hatimSaving = true);
    try {
      final page = _page;
      final read = !widget.store.hatimPages.contains(page);
      await widget.store.saveHatim([page], read: read, resume: page);
      if (!mounted) return;
      if (read && widget.store.hatimComplete) {
        await _openPrayer();
      }
    } catch (_) { _error('Hatim ilerlemesi kaydedilemedi.'); }
    finally { if (mounted) setState(() => _hatimSaving = false); }
  }
  Future<void> _hatimSelection() async {
    final selectedPage = await Navigator.push<int>(context,
      MaterialPageRoute<int>(builder: (_) => HatimSelectionScreen(store: widget.store)));
    if (!mounted) return;
    setState(() {});
    if (selectedPage != null) {
      await _go(selectedPage);
      return;
    }
    if (widget.store.hatimComplete) {
      await _openPrayer();
    }
  }
  bool _prayerOpen = false;
  Future<void> _openPrayer() async {
    if (_prayerOpen || !mounted) return;
    _prayerOpen = true;
    try {
      await _go(widget.store.edition.lastPage);
      if (!mounted) return;
      final restart = await Navigator.push<bool>(context,
        MaterialPageRoute<bool>(builder: (_) => HatimPrayerScreen(store: widget.store)));
      if (restart == true && mounted) await _go(widget.store.edition.firstPage);
    } finally { _prayerOpen = false; }
  }
  late int _page;
  int? _target;
  bool _fullscreen = false;
  bool _fullscreenBeforeLandscape = false;
  bool _showLandscapeActions = false;
  int? _readingScrollPointer;
  Offset? _readingScrollStart;

  void _readingScrollDown(PointerDownEvent event) {
    if (!_landscape || !_fullscreen) return;
    if (_readingScrollPointer != null) {
      _readingScrollStart = null;
      return;
    }
    _readingScrollPointer = event.pointer;
    _readingScrollStart = event.position;
  }

  void _readingScrollMove(PointerMoveEvent event) {
    if (event.pointer != _readingScrollPointer) return;
    final start = _readingScrollStart;
    if (start == null || !_landscape || !_fullscreen || _zoomed) return;
    final delta = event.position - start;
    if (delta.dy.abs() >= widget.store.edgeTapWidth && delta.dy.abs() > delta.dx.abs() * 1.5) {
      final show = delta.dy > 0;
      if (_showLandscapeActions != show) setState(() => _showLandscapeActions = show);
      _readingScrollStart = event.position;
    }
  }

  void _readingScrollUp(PointerUpEvent event) {
    if (event.pointer != _readingScrollPointer) return;
    _readingScrollPointer = null;
    _readingScrollStart = null;
  }
  bool _showOuterFrame = false;
  bool _preparing = false;
  bool _bookmarkSaving = false;
  final TransformationController _zoom = TransformationController();
  final ScrollController _verticalScroll = ScrollController();
  bool _zoomed = false;
  bool _verseSelectionActive = false;
  bool _landscape = false;
  Orientation? _orientation;

  void _resetReadingPosition() {
    _verseSelectionActive = false;
    _zoom.value = Matrix4.identity();
    _zoomed = false;
    if (_verticalScroll.hasClients) _verticalScroll.jumpTo(0);
  }

  Offset? _touchStart;
  int? _touchPointer;
  bool _multiTouch = false;
  bool _exitFromBottomEdge = false;
  bool _dragging = false;
  double _readerWidth = 1;
  double _readerHeight = 1;

  void _dragMove(PointerMoveEvent event) {
    if (event.pointer != _touchPointer || _touchStart == null || _multiTouch ||
        _preparing || _turn.isAnimating || _zoom.value.getMaxScaleOnAxis() > 1.01) {
      return;
    }
    final delta = event.position - _touchStart!;
    if (!_dragging) {
      if (delta.dx.abs() < 8 || delta.dx.abs() <= delta.dy.abs()) return;
      final target = _page + (delta.dx > 0 ? 1 : -1);
      if (target < widget.store.edition.firstPage || target > widget.store.edition.lastPage) return;
      if (!widget.store.pageAnimations || MediaQuery.of(context).disableAnimations) return;
      setState(() { _dragging = true; _target = target; });
    }
    if (!widget.store.pageAnimations || MediaQuery.of(context).disableAnimations) return;
    final target = _page + (delta.dx > 0 ? 1 : -1);
    if (target < widget.store.edition.firstPage || target > widget.store.edition.lastPage) {
      _turn.value = 0;
      return;
    }
    if (target != _target) setState(() => _target = target);
    _turn.value = (delta.dx.abs() / (_readerWidth * (widget.store.pageEffect == 'curl' ? 2.1 : 1))).clamp(0.0, 1.0).toDouble();
  }

  Future<void> _releaseDrag({required bool commit}) async {
    if (!_dragging) return;
    _dragging = false;
    try {
      if (commit) {
        final target = _target!;
        await _turn.animateTo(1, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic).orCancel;
        if (!mounted) return;
        setState(() { _page = target; _target = null; });
        _resetReadingPosition();
        await _remember(target);
      } else {
        await _turn.reverse().orCancel;
        if (mounted) setState(() => _target = null);
      }
    } on TickerCanceled {
      // Reader closed while the paper was settling.
    }
  }
  late final AnimationController _turn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _page = widget.initialPage.clamp(widget.store.edition.firstPage, widget.store.edition.lastPage).toInt();
    _turn = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _remember(_page);
    VerseRegions.load().then((regions) {
      if (mounted) setState(() => _verseRegions = regions);
    }).catchError((Object _) { _error('verseRegionsUnavailable'); });
    _audioTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_audioBusy || _audio.playing == null) return;
      _audioBusy = true;
      try {
        final previousError = _audio.playbackError;
        await _audio.load();
        if (_audio.playbackError != null && _audio.playbackError != previousError) {
          _error('Ses işlemi tamamlanamadı. Tekrar dene.');
        }
      } catch (_) { /* Refresh on the next tick. */ }
      finally { _audioBusy = false; if (mounted) setState(() {}); }
    });
    if (widget.initialPanel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.initialPanel == 'meal') _mealPage(resume: true);
        if (widget.initialPanel == 'surah') _selectSurah();
        if (widget.initialPanel == 'bookmarks') _bookmarks();
        if (widget.initialPanel == 'jump') _jump();
        if (widget.initialPanel == 'prayer') _openPrayer();
      });
    }
  }

  void _error(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t(message))));
  }

  Future<void> _remember(int page) async {
    if (_audio.playing != null) _audio.stop().catchError((Object _) {});
    _recordedPage = null;
    _scheduleHistory();
    try { if (widget.hatim) await widget.store.saveHatim([], resume: page); } catch (_) { _error('Hatim ilerlemesi kaydedilemedi.'); }
    try { await widget.store.savePage(page); } catch (_) { _error('Son okunan sayfa kaydedilemedi.'); }
  }

  Future<void> _go(int page, {bool animate = false}) async {
    if (widget.hatim && widget.store.hatimComplete && page == widget.store.edition.lastPage + 1) {
      await _openPrayer();
      return;
    }
    if (_target != null || _preparing || page < widget.store.edition.firstPage || page > widget.store.edition.lastPage || page == _page) return;
    _resetReadingPosition();
    if (!animate || !widget.store.pageAnimations || MediaQuery.of(context).disableAnimations) {
      setState(() => _page = page);
      await _remember(page);
      return;
    }
    setState(() => _preparing = true);
    try {
      await precacheImage(FileImage(File(widget.store.pagePath(page))), context,
        onError: (Object error, StackTrace? stack) => _error('Sayfa görüntüsü okunamadı.'));
      if (!mounted) return;
      setState(() => _target = page);
      await _turn.forward(from: 0).orCancel;
      if (!mounted) return;
      setState(() { _page = page; _target = null; });
      await _remember(page);
    } on TickerCanceled {
      // The reader was closed during a page turn.
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  Future<void> _jump() async {
    final controller = TextEditingController();
    final form = GlobalKey<FormState>();
    final page = await showDialog<int>(context: context, builder: (context) => AlertDialog(
      title: Text(context.t('Sayfaya git')),
      content: Form(key: form, child: TextFormField(
        controller: controller, autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: context.t('Sayfa numarası ({first}–{last})', {'first': widget.store.edition.firstPage, 'last': widget.store.edition.lastPage})),
        validator: (value) {
          final n = int.tryParse(value ?? '');
          return n == null || n < widget.store.edition.firstPage || n > widget.store.edition.lastPage ? context.t('{first} ile {last} arasında bir sayı yazın.', {'first': widget.store.edition.firstPage, 'last': widget.store.edition.lastPage}) : null;
        },
        onFieldSubmitted: (_) { if (form.currentState!.validate()) Navigator.pop(context, int.parse(controller.text)); },
      )),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t('İptal'))),
        FilledButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(context, int.parse(controller.text)); }, child: Text(context.t('Sayfaya git')))],
    ));
    // Dialog exit animation may still use the controller; dispose after it finishes.
    await Future<void>.delayed(Duration(milliseconds: 300));
    controller.dispose();
    if (page != null && mounted) await _go(page);
  }

  Future<void> _selectSurah() async {
    final selected = await showModalBottomSheet<int>(context: context, isScrollControlled: true,
      builder: (context) => _SurahPicker(items: widget.store.edition.surahIndex, firstPage: widget.store.edition.firstPage, lastPage: widget.store.edition.lastPage));
    if (selected != null && mounted) await _go(selected);
  }

  Future<void> _bookmarks() async {
    final selected = await showBookmarksSheet(context, widget.store, onChanged: () {
      if (mounted) setState(() {});
    });
    if (selected != null && mounted) await _go(selected);
  }

  Future<void> _toggleBookmark() async {
    if (_bookmarkSaving) return;
    setState(() => _bookmarkSaving = true);
    try {
      await widget.store.toggleBookmark(_page);
      if (mounted) setState(() {});
    } catch (_) { _error('Ayraç kaydedilemedi.'); }
    finally { if (mounted) setState(() => _bookmarkSaving = false); }
  }

  @override
  void exitFullscreen() {
    if (mounted && _fullscreen) setState(() { _fullscreen = false; _showOuterFrame = false; });
    if (identical(AppNavigation.instance.fullscreenReader.value, this)) AppNavigation.instance.fullscreenReader.value = null;
  }

  void _toggleFullscreen() {
    if (_target != null || _preparing) return;
    _resetReadingPosition();
    setState(() {
      _fullscreen = !_fullscreen;
      if (_fullscreen) _showOuterFrame = false;
    });
    AppNavigation.instance.fullscreenReader.value = _fullscreen ? this : null;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _doubleTapFullscreen() {
    if (_target != null || _preparing) return;
    _resetReadingPosition();
    setState(() {
      if (!_fullscreen) {
        _fullscreen = true;
        _showOuterFrame = true;
      } else if (_showOuterFrame) {
        _showOuterFrame = false;
      } else {
        _fullscreen = false;
      }
    });
    AppNavigation.instance.fullscreenReader.value = _fullscreen ? this : null;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Rect _activeCrop(int page) => _showOuterFrame
    ? widget.store.edition.outerCrop(page) : widget.store.edition.crop(page);

  Rect? _normalizedActiveCrop(int page) => !_fullscreen ? null : _showOuterFrame
    ? widget.store.edition.normalizedOuterCrop(page) : widget.store.edition.normalizedCrop(page);

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (identical(AppNavigation.instance.fullscreenReader.value, this)) {
        AppNavigation.instance.fullscreenReader.value = null;
      }
    });
    WidgetsBinding.instance.removeObserver(this);
    _historyTimer?.cancel();
    _audioTimer?.cancel();
    _audio.stop().catchError((Object _) {});
    _verticalScroll.dispose();
    _zoom.dispose();
    _turn.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.dispose();
  }

  Widget _hatimControls(bool busy) => PersonalPageSwipe(
    onNavigate: (delta) => AppNavigation.instance.switchPage?.call(delta),
    child: SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(height: 48, child: Row(children: [
        Tooltip(message: context.t('hatimProgressActions'), child: TextButton.icon(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8)),
          onPressed: busy || _hatimSaving ? null : _hatimSelection,
          icon: const Icon(Icons.checklist, size: 18),
          label: Text('${widget.store.hatimPages.length}/${widget.store.edition.pageCount}',
            style: const TextStyle(fontSize: 12)))),
        const Spacer(),
        Text(context.t('Okundu'), style: const TextStyle(fontSize: 12)),
        Checkbox(key: const ValueKey('hatim-read-checkbox'),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          value: widget.store.hatimPages.contains(_page),
          onChanged: busy || _hatimSaving ? null : (_) => _markHatim()),
      ]))),
    ),
  );

  Widget _pageControls(bool busy) => PersonalPageSwipe(
    onNavigate: AppNavigation.instance.switchPage,
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        IconButton(tooltip: context.t('Sonraki sayfa'),
          onPressed: busy || (_page == widget.store.edition.lastPage && !(widget.hatim && widget.store.hatimComplete)) ? null : () => _go(_page + 1),
          icon: const Icon(Icons.chevron_left)),
        TextButton(onPressed: _jump, child: Text('$_page / ${widget.store.edition.lastPage}')),
        IconButton(tooltip: widget.store.bookmarks.contains(_page) ? context.t('Ayracı kaldır') : context.t('Ayraç ekle'),
          onPressed: busy || _bookmarkSaving ? null : _toggleBookmark,
          icon: Icon(widget.store.bookmarks.contains(_page) ? Icons.bookmark : Icons.bookmark_border)),
        IconButton(tooltip: context.t('Önceki sayfa'),
          onPressed: busy || _page == widget.store.edition.firstPage ? null : () => _go(_page - 1),
          icon: const Icon(Icons.chevron_right)),
      ])),
  );

  Widget _image(int page) => TweenAnimationBuilder<double>(
    tween: Tween(end: widget.hatim && widget.store.hatimPages.contains(page) ? 1 : 0),
    duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 380),
    curve: Curves.easeInOutCubic,
    builder: (context, coverage, child) => Stack(fit: StackFit.expand, children: [
      child!,
      Positioned.fill(child: IgnorePointer(child: ClipRect(child: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(key: ValueKey('hatim-page-curtain-$page'),
          heightFactor: coverage, widthFactor: 1,
          child: const DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
              colors: [Color(0x99FFFDF6), Color(0xB3FFFFFF), Color(0x99FFFDF6),
                Color(0xADFFFFFF), Color(0x99FFFDF6)],
              stops: [0, .25, .5, .75, 1]),
          ))),
      )))),
    ]),
    child: LayoutBuilder(builder: (context, constraints) {
      final regions = _verseRegions?.page(widget.store.edition.id, page) ?? <VerseRegion>[];
      final sajdah = sajdahVerses[page];
      return ClipRect(child: Stack(fit: StackFit.expand, children: [
        ReadingPage(image: FileImage(File(widget.store.pagePath(page))), crop: _normalizedActiveCrop(page)),
        VerseSelectionOverlay(page: page, verses: regions, imageSize: widget.store.edition.pageSize(page),
          crop: _normalizedActiveCrop(page), sajdah: sajdah, onChanged: (selection) {
            if (_verseSelectionActive != selection.isNotEmpty) {
              setState(() => _verseSelectionActive = selection.isNotEmpty);
            }
            if (selection.isNotEmpty) {
              _touchPointer = null; _touchStart = null; _exitFromBottomEdge = false;
            }
          },
          onSelected: _verseAction),
      ]));
    }),
  );

  @override
  Widget build(BuildContext context) {
    final busy = _target != null || _preparing;
    final personalPage = PersonalPageScope.of(context);
    final surahTitle = widget.store.edition.surahsOnPage(_page).map((s) => surahName(s, context.language)).join(' · ');
    final titleNotifier = personalPage?.readerTitle;
    if (titleNotifier != null && titleNotifier.value != surahTitle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && identical(PersonalPageScope.of(context)?.readerTitle, titleNotifier)) titleNotifier.value = surahTitle;
      });
    }
    final orientation = MediaQuery.orientationOf(context);
    if (_orientation != orientation) {
      if (orientation == Orientation.landscape) {
        _fullscreenBeforeLandscape = _fullscreen;
        _fullscreen = true;
        _showOuterFrame = false;
      } else if (_orientation == Orientation.landscape) {
        _fullscreen = _fullscreenBeforeLandscape;
        _showOuterFrame = false;
      }
      _orientation = orientation;
      _showLandscapeActions = false;
      _readingScrollPointer = null;
      _readingScrollStart = null;
      _zoom.value = Matrix4.identity();
      _zoomed = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _resetReadingPosition();
        if (!_mealOpen && (ModalRoute.of(context)?.isCurrent ?? false)) {
          AppNavigation.instance.fullscreenReader.value = _fullscreen ? this : null;
        }
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      });
    }
    _landscape = orientation == Orientation.landscape;
    final fadeLandscapeControls = widget.hatim && _landscape;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: _fullscreen ? 0 : 1),
      duration: fadeLandscapeControls && !MediaQuery.disableAnimationsOf(context)
          ? const Duration(milliseconds: 320) : Duration.zero,
      curve: Curves.easeInOutCubic,
      builder: (context, chromeVisibility, _) => Scaffold(backgroundColor: Color(0xFFE9E1D1),
      appBar: chromeVisibility == 0 || personalPage != null ? null : PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * chromeVisibility),
        child: ClipRect(child: Align(heightFactor: chromeVisibility,
          child: Opacity(opacity: chromeVisibility, child: PersonalPageSwipe(onNavigate: (delta) => AppNavigation.instance.switchPage?.call(delta), child: AppBar(title: ScreenTitle(context, (widget.hatim && PersonalPageScope.of(context) == null ? '${context.t("Hatim")} · ' : '') + widget.store.edition.surahsOnPage(_page).map((s) => surahName(s, context.language)).join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: const <Widget>[])))))),
      bottomNavigationBar: _audio.memorizing ? SafeArea(child: Padding(
        padding: const EdgeInsets.all(8), child: FilledButton.icon(
          onPressed: _audioBusy || _audio.stopPending ? null : () async {
            setState(() => _audioBusy = true);
            try { await _audio.advanceMemorization(); }
            catch (_) { _error('Ses işlemi tamamlanamadı. Tekrar dene.'); }
            finally { if (mounted) setState(() => _audioBusy = false); }
          }, icon: const Icon(Icons.skip_next), label: Text(context.t('verseAdvance'))))) : null,
      body: Listener(behavior: HitTestBehavior.opaque,
        onPointerDown: _readingScrollDown, onPointerMove: _readingScrollMove, onPointerUp: _readingScrollUp,
        onPointerCancel: (_) { _readingScrollPointer = null; _readingScrollStart = null; },
        child: Stack(fit: StackFit.expand, children: [
      SafeArea(top: !_fullscreen, bottom: !_fullscreen, child: Column(children: [
        TweenAnimationBuilder<double>(
          tween: Tween(end: !(_landscape && _fullscreen) || _showLandscapeActions ? 1 : 0),
          duration: _landscape && !MediaQuery.disableAnimationsOf(context)
            ? const Duration(milliseconds: 180) : Duration.zero,
          builder: (context, visibility, child) => visibility == 0 ? const SizedBox.shrink()
            : ClipRect(child: Align(heightFactor: visibility, alignment: Alignment.bottomCenter,
                child: IgnorePointer(ignoring: _landscape && _fullscreen && !_showLandscapeActions,
                  child: child))),
          child: Padding(
          padding: _landscape && _fullscreen ? const EdgeInsets.symmetric(horizontal: 4) : EdgeInsets.zero,
          child: ReaderActionBar(compact: _landscape && _fullscreen,
          loading: _audioBusy, playing: _audio.playing != null, stopping: _audio.stopPending,
          onListen: busy || _audioBusy || _audio.stopPending ? null : _listenPage,
          onMeal: busy || _audioBusy ? null : _mealPage))),
        Expanded(child: GestureDetector(
          key: const ValueKey('quran-reading-surface'),
          behavior: HitTestBehavior.opaque,
          child: Listener(
            onPointerDown: (event) {
              if (_verseSelectionActive) return;
              if (_touchPointer != null) {
                _multiTouch = true;
                _releaseDrag(commit: false);
                return;
              }
              if (_turn.isAnimating || _preparing || _target != null) return;
              _exitFromBottomEdge = _fullscreen && !_landscape && event.localPosition.dy >= _readerHeight - 56;
              _touchPointer = event.pointer;
              _touchStart = event.position;
              _multiTouch = false;
            },
            onPointerMove: _dragMove,
            onPointerUp: (event) {
              if (event.pointer != _touchPointer) return;
              final delta = event.position - (_touchStart ?? event.position);
              if (_exitFromBottomEdge && _fullscreen && !_multiTouch && !_zoomed &&
                  _target == null && !_dragging && !_preparing &&
                  delta.dy < -(widget.hatim && _landscape ? 32 : 70) && delta.dy.abs() > delta.dx.abs()) {
                _exitFromBottomEdge = false;
                _touchPointer = null; _touchStart = null;
                _toggleFullscreen();
                return;
              }
              _exitFromBottomEdge = false;
              if (widget.hatim && widget.store.hatimComplete && _page == widget.store.edition.lastPage &&
                  !_multiTouch && !_zoomed && delta.dx >= widget.store.edgeTapWidth && delta.dx > delta.dy.abs()) {
                _touchPointer = null; _touchStart = null;
                _go(_page + 1);
                return;
              }
              if (_dragging) {
                _releaseDrag(commit: !_multiTouch && delta.dx.abs() >= widget.store.edgeTapWidth && delta.dx.abs() > delta.dy.abs() && _turn.value > 0);
              }
              if (!_multiTouch && (!widget.store.pageAnimations || MediaQuery.of(context).disableAnimations) &&
                  _zoom.value.getMaxScaleOnAxis() <= 1.01 &&
                  delta.dx.abs() >= widget.store.edgeTapWidth && delta.dx.abs() > delta.dy.abs()) {
                _go(_page + (delta.dx > 0 ? 1 : -1));
              }
              _touchPointer = null;
              _touchStart = null;
            },
            onPointerCancel: (_) {
              _releaseDrag(commit: false);
              _touchPointer = null; _touchStart = null; _exitFromBottomEdge = false;
            },
            child: LayoutBuilder(builder: (context, constraints) {
            _readerWidth = constraints.maxWidth;
            _readerHeight = constraints.maxHeight;
            final crop = _activeCrop(_page);
            final aspect = _fullscreen ? crop.height / crop.width : widget.store.edition.pageSize(_page).height / widget.store.edition.pageSize(_page).width;
            final sheetHeight = _fullscreen || _landscape
                ? math.max(constraints.maxHeight, constraints.maxWidth * aspect)
                : constraints.maxHeight;
            final child = _target == null ? _image(_page) : widget.store.pageEffect == 'curl'
              ? PageTurn(image: FileImage(File(widget.store.pagePath(_page))), animation: _turn,
                  toRight: _target! > _page, underneath: _image(_target!), crop: _normalizedActiveCrop(_page))
              : PageSlide(
              animation: _turn, toRight: _target! > _page,
              current: _image(_page), next: _image(_target!));
            return InteractiveViewer(transformationController: _zoom, minScale: 1, maxScale: 4,
              alignment: Alignment.topCenter,
              panEnabled: _zoomed && _target == null,
              onInteractionUpdate: (_) {
                final zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01;
                if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
              },
              child: SingleChildScrollView(
                  controller: _verticalScroll,
                  physics: _zoomed || _target != null
                      ? NeverScrollableScrollPhysics()
                      : ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: Column(children: [
                    GestureDetector(behavior: HitTestBehavior.opaque,
                      onDoubleTap: _verseSelectionActive ? null : _doubleTapFullscreen,
                      child: SizedBox(width: constraints.maxWidth, height: sheetHeight, child: child)),
                    if (_landscape && _fullscreen) SafeArea(top: false,
                      child: Column(key: const ValueKey('landscape-reading-footer'), children: [
                        if (widget.hatim) _hatimControls(busy),
                        _pageControls(busy),
                      ])),
                  ]),
              ));
          })),
        )),
        if (!(_landscape && _fullscreen)) ...[
          if (widget.hatim) _hatimControls(busy),
          if (!_fullscreen) _pageControls(busy),
        ],
      ])),
      Positioned(top: 12, left: 20, right: 20, child: SafeArea(
        child: SajdahNotice(page: _page, editionId: widget.store.edition.id))),

      ])),
    ));
  }
}

class _SurahPicker extends StatefulWidget {
  final List<Surah> items;
  final int firstPage;
  final int lastPage;
  const _SurahPicker({required this.items, required this.firstPage, required this.lastPage});
  @override
  State<_SurahPicker> createState() => _SurahPickerState();
}
class _SurahPickerState extends State<_SurahPicker> {
  final _search = TextEditingController();
  String query = '';
  int mode = 1;
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeSurahName(query).replaceAll('.', '');
    final juzMatch = RegExp(r'^(?:cuz|juz|djoez)([0-9]*)$').firstMatch(normalized)
      ?? RegExp(r'^([0-9]+)(?:cuz|juz|djoez)$').firstMatch(normalized);
    final pageMatch = RegExp(r'^(?:sayfa|page|pagina|s)([0-9]+)$').firstMatch(normalized);
    final digits = juzMatch?.group(1) ?? pageMatch?.group(1) ?? normalized;
    final number = int.tryParse(digits);
    final onlyJuz = juzMatch != null;
    final onlyPage = pageMatch != null;
    final includeSurahs = mode == 1 && !onlyJuz && !onlyPage;
    final includeJuz = (mode == 2 || onlyJuz) && !onlyPage;
    final includePages = (mode == 3 || onlyPage) && !onlyJuz;
    final filtered = includeSurahs ? widget.items.where((s) => matchesSurah(s, query)).toList() : <Surah>[];
    final juzNumbers = includeJuz ? List.generate(30, (i) => i + 1)
      .where((n) => digits.isEmpty || number == n).toList() : <int>[];
    final pages = includePages && number != null && number >= widget.firstPage && number <= widget.lastPage
      ? <int>[number] : <int>[];
    final count = pages.length + filtered.length + juzNumbers.length;
    return SafeArea(child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(height: MediaQuery.sizeOf(context).height * .8,
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(context.t('Bul ve oku'), style: Theme.of(context).textTheme.titleLarge)),
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(children: [
          for (final entry in const {1: 'Sureler', 2: 'Cüzler', 3: 'Sayfa'}.entries) ...[
            if (entry.key != 1) const SizedBox(width: 6),
            Expanded(child: ChoiceChip(showCheckmark: false,
              label: SizedBox(width: double.infinity, child: FittedBox(fit: BoxFit.scaleDown,
                child: Text(context.t(entry.value)))), selected: mode == entry.key,
              onSelected: (_) => setState(() { mode = entry.key; }))),
          ],
        ])),
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          controller: _search,
          decoration: InputDecoration(labelText: context.t('Sure adı, cüz veya sayfa numarası'),
            hintText: context.t('Örn. Ali imran, cüz 3, 439'), prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isEmpty ? null : IconButton(tooltip: context.t('Aramayı temizle'),
              icon: const Icon(Icons.close), onPressed: () { _search.clear(); setState(() => query = ''); })),
          onChanged: (v) => setState(() => query = v))),
        Expanded(child: count == 0
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(context.t('Sonuç bulunamadı. Sure adı, 1–30 arası cüz veya 0–604 arası sayfa yazabilirsin.'))))
          : ListView.builder(itemCount: count, itemBuilder: (_, i) {
          if (i < pages.length) {
            final page = pages[i];
            return ListTile(leading: const Icon(Icons.numbers),
              title: Text(context.t('Sayfa {page}', {'page': page})),
              trailing: const Icon(Icons.arrow_forward), onTap: () => Navigator.pop(context, page));
          }
          final index = i - pages.length;
          if (index < filtered.length) {
            final surah = filtered[index];
            return ListTile(leading: const Icon(Icons.menu_book_outlined),
              title: Text('${surah.number}. ${surahName(surah, context.language)}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(context.t('s. {page}', {'page': surah.startPage})),
                IconButton(tooltip: context.t('Meal Oku'), icon: const Icon(Icons.translate_rounded),
                  onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => MealScreen(initialSurah: surah.number)))),
              ]),
              onTap: () => Navigator.pop(context, surah.startPage));
          }
          final juz = juzNumbers[index - filtered.length];
          final page = juz == 1 ? widget.firstPage : (juz - 1) * 20 + 1;
          return ListTile(leading: const Icon(Icons.auto_stories_outlined),
            title: Text(context.t('Cüz {number}', {'number': juz})),
            trailing: Text(context.t('s. {page}', {'page': page})),
            onTap: () => Navigator.pop(context, page));
        })),
      ]))));
  }
}

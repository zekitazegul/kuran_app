import 'listening_screen.dart';
import '../widgets/sajdah_notice.dart';
import '../l10n/translations.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/surahs.dart';
import '../services/reading_store.dart';
import '../widgets/page_turn.dart';
import '../widgets/reading_page.dart';
import 'settings_screen.dart';
import '../widgets/language_selector.dart';
import '../widgets/reader_tap_region.dart';

class QuranScreen extends StatefulWidget {
  final ReadingStore store;
  final int initialPage;
  final String? initialPanel;
  const QuranScreen({super.key, required this.store, required this.initialPage, this.initialPanel});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  late int _page;
  int? _target;
  bool _fullscreen = false;
  bool _showOuterFrame = false;
  bool _preparing = false;
  bool _bookmarkSaving = false;
  final TransformationController _zoom = TransformationController();
  final ScrollController _verticalScroll = ScrollController();
  bool _zoomed = false;
  double _bottomPull = 0;
  double _topPull = 0;
  bool _landscape = false;
  Orientation? _orientation;

  void _resetReadingPosition() {
    _zoom.value = Matrix4.identity();
    _zoomed = false;
    _bottomPull = 0;
    _topPull = 0;
    if (_verticalScroll.hasClients) _verticalScroll.jumpTo(0);
  }

  bool _scrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification) { _bottomPull = 0; _topPull = 0; }
    if (notification is OverscrollNotification && notification.dragDetails != null &&
        notification.overscroll < 0 && notification.metrics.extentBefore <= 0 &&
        _fullscreen && !_zoomed && !_multiTouch && _target == null && !_preparing) {
      _topPull -= notification.overscroll;
      if (_topPull >= 55) {
        _topPull = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _fullscreen) _toggleFullscreen();
        });
      }
    }
    if (notification is OverscrollNotification && notification.dragDetails != null &&
        notification.overscroll > 0 && notification.metrics.extentAfter <= 0 &&
        _landscape && !_zoomed && !_multiTouch && _target == null &&
        !_preparing && _page < widget.store.edition.lastPage) {
      _bottomPull += notification.overscroll;
      if (_bottomPull >= 55) {
        _bottomPull = 0;
        // Scroll notifications arrive during layout; navigate after this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _target == null && !_preparing) _go(_page + 1, animate: true);
        });
      }
    }
    return false;
  }
  Offset? _touchStart;
  int? _touchPointer;
  bool _multiTouch = false;
  bool _dragging = false;
  double _touchHeight = .85;
  double _dragTilt = 0;
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
    final direction = _target! > _page ? 1 : -1;
    final progress = (delta.dx * direction / (_readerWidth * 2.1)).clamp(0.0, .98).toDouble();
    setState(() => _dragTilt = delta.dy / (1 - progress));
    _turn.value = progress;
  }

  Future<void> _releaseDrag({required bool commit}) async {
    if (!_dragging) return;
    _dragging = false;
    try {
      if (commit) {
        final target = _target!;
        await _turn.forward().orCancel;
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
    _page = widget.initialPage.clamp(widget.store.edition.firstPage, widget.store.edition.lastPage).toInt();
    _turn = AnimationController(vsync: this, duration: Duration(milliseconds: 650));
    _remember(_page);
    if (widget.initialPanel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.initialPanel == 'surah') _selectSurah();
        if (widget.initialPanel == 'bookmarks') _bookmarks();
        if (widget.initialPanel == 'jump') _jump();
      });
    }
  }

  void _error(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t(message))));
  }

  Future<void> _remember(int page) async {
    try { await widget.store.savePage(page); } catch (_) { _error('Son okunan sayfa kaydedilemedi.'); }
  }

  Future<void> _go(int page, {bool animate = false}) async {
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
      setState(() { _target = page; _touchHeight = .85; _dragTilt = -_readerHeight * .08; });
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
    final pages = widget.store.bookmarks.toList()..sort();
    final selected = await showModalBottomSheet<int>(context: context, builder: (context) => SafeArea(
      child: pages.isEmpty ? Padding(padding: EdgeInsets.all(32), child: Text(context.t('Henüz ayraç yok. Okuduğunuz sayfada ayraç simgesine dokunun.')))
      : ListView(children: [ListTile(title: Text(context.t('Ayraçlar'))),
        for (final page in pages) ListTile(title: Text(context.t('Sayfa {page}', {'page': page})),
          subtitle: Text(widget.store.edition.surahsOnPage(page).map((s) => surahName(s, context.language)).join(', ')),
          onTap: () => Navigator.pop(context, page))]),
    ));
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

  void _toggleFullscreen() {
    if (_target != null || _preparing) return;
    _resetReadingPosition();
    setState(() {
      _fullscreen = !_fullscreen;
      if (_fullscreen) _showOuterFrame = false;
    });
    SystemChrome.setEnabledSystemUIMode(_fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
  }

  void _doubleTapFullscreen() {
    if (_target != null || _preparing) return;
    _resetReadingPosition();
    setState(() {
      _showOuterFrame = !_fullscreen || !_showOuterFrame;
      _fullscreen = true;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Rect _activeCrop(int page) => _showOuterFrame
    ? widget.store.edition.outerCrop(page) : widget.store.edition.crop(page);

  Rect? _normalizedActiveCrop(int page) => !_fullscreen ? null : _showOuterFrame
    ? widget.store.edition.normalizedOuterCrop(page) : widget.store.edition.normalizedCrop(page);

  @override
  void dispose() {
    _verticalScroll.dispose();
    _zoom.dispose();
    _turn.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Widget _image(int page) => ReadingPage(
    image: FileImage(File(widget.store.pagePath(page))),
    crop: _normalizedActiveCrop(page),
  );

  void _tapPage(TapUpDetails details) {
    if (_target != null || _preparing) return;
    // Android physical DPI approximates a 1 cm strip at each edge.
    final region = readerTapRegion(details.localPosition.dx, _readerWidth, widget.store.edgeTapWidth);
    if (region == ReaderTapRegion.fullscreen) {
      _toggleFullscreen();
    } else if (_zoom.value.getMaxScaleOnAxis() <= 1.01) {
      _go(_page + (region == ReaderTapRegion.nextPage ? 1 : -1), animate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _target != null || _preparing;
    final orientation = MediaQuery.orientationOf(context);
    if (_orientation != orientation) {
      _orientation = orientation;
      _zoom.value = Matrix4.identity();
      _zoomed = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resetReadingPosition();
      });
    }
    _landscape = orientation == Orientation.landscape;
    return Scaffold(backgroundColor: Color(0xFFE9E1D1),
      appBar: _fullscreen ? null : AppBar(title: Text(widget.store.edition.surahsOnPage(_page).map((s) => surahName(s, context.language)).join(' · ')),
        actions: [IconButton(tooltip: context.t('Dinle'), icon: const Icon(Icons.headphones_outlined),
          onPressed: busy ? null : () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) =>
            ListeningScreen(initialSurah: widget.store.edition.surahsOnPage(_page).first.number)))),
          IconButton(tooltip: context.t('Sayfaya git'), onPressed: _jump, icon: Icon(Icons.numbers)),
          PopupMenuButton<String>(enabled: !busy && !_bookmarkSaving, onSelected: (v) {
            if (v == 'surah') _selectSurah();
            if (v == 'bookmarks') _bookmarks();
            if (v == 'full') _toggleFullscreen();
            if (v == 'settings') {
              final previous = widget.store.edition.id;
              Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SettingsScreen(store: widget.store)))
                .then((_) {
                  if (!mounted || !context.mounted) return;
                  if (!widget.store.ready) { Navigator.pop(context); return; }
                  if (previous != widget.store.edition.id) {
                    _resetReadingPosition();
                    setState(() => _page = widget.store.lastPage);
                  } else { setState(() {}); }
                });
            }
          }, itemBuilder: (_) => [PopupMenuItem(value: 'surah', child: Text(context.t('Sure / Cüz'))),
            PopupMenuItem(value: 'bookmarks', child: Text(context.t('Ayraçlar'))),
            PopupMenuItem(value: 'full', child: Text(context.t('Tam ekran'))),
            PopupMenuItem(value: 'settings', child: Text(context.t('Ayarlar')))]), LanguageSelector()]),
      body: Stack(fit: StackFit.expand, children: [
      SafeArea(top: !_fullscreen, bottom: !_fullscreen, child: Column(children: [
        Expanded(child: GestureDetector(
          key: const ValueKey('quran-reading-surface'),
          behavior: HitTestBehavior.opaque,
          onTapUp: _tapPage,
          onDoubleTap: _doubleTapFullscreen,
          child: Listener(
            onPointerDown: (event) {
              if (_touchPointer != null) {
                _multiTouch = true;
                _releaseDrag(commit: false);
                return;
              }
              if (_turn.isAnimating || _preparing || _target != null) return;
              _touchPointer = event.pointer;
              _touchStart = event.position;
              _touchHeight = (event.localPosition.dy / _readerHeight).clamp(0.0, 1.0).toDouble();
              _multiTouch = false;
            },
            onPointerMove: _dragMove,
            onPointerUp: (event) {
              if (event.pointer != _touchPointer) return;
              final delta = event.position - (_touchStart ?? event.position);
              if (_dragging) {
                _releaseDrag(commit: !_multiTouch && delta.dx.abs() >= 70 &&
                  _turn.value > 0.01);
              }
              if (!_multiTouch && (!widget.store.pageAnimations || MediaQuery.of(context).disableAnimations) &&
                  _zoom.value.getMaxScaleOnAxis() <= 1.01 &&
                  delta.dx.abs() >= 70 && delta.dx.abs() > delta.dy.abs()) {
                _go(_page + (delta.dx > 0 ? 1 : -1));
              }
              _touchPointer = null;
              _touchStart = null;
            },
            onPointerCancel: (_) {
              _releaseDrag(commit: false);
              _touchPointer = null; _touchStart = null;
            },
            child: LayoutBuilder(builder: (context, constraints) {
            _readerWidth = constraints.maxWidth;
            _readerHeight = constraints.maxHeight;
            final crop = _activeCrop(_page);
            final aspect = _fullscreen ? crop.height / crop.width : widget.store.edition.pageSize(_page).height / widget.store.edition.pageSize(_page).width;
            final sheetHeight = _fullscreen || _landscape
                ? math.max(constraints.maxHeight, constraints.maxWidth * aspect)
                : constraints.maxHeight;
            final child = _target == null ? _image(_page) : PageTurn(
              image: FileImage(File(widget.store.pagePath(_page))), animation: _turn,
              toRight: _target! > _page, underneath: _image(_target!),
              touchHeight: (_touchHeight * constraints.maxHeight +
                (_verticalScroll.hasClients ? _verticalScroll.offset : 0)) / sheetHeight, dragTilt: _dragTilt,
              crop: _normalizedActiveCrop(_page));
            return InteractiveViewer(transformationController: _zoom, minScale: 1, maxScale: 4,
              alignment: Alignment.topCenter,
              panEnabled: _zoomed && _target == null,
              onInteractionUpdate: (_) {
                final zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01;
                if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: _scrollNotification,
                child: SingleChildScrollView(
                  controller: _verticalScroll,
                  physics: _zoomed || _target != null
                      ? NeverScrollableScrollPhysics()
                      : ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: SizedBox(width: constraints.maxWidth, height: sheetHeight, child: child),
                ),
              ));
          })),
        )),
        if (!_fullscreen) Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            IconButton(tooltip: context.t('Sonraki sayfa'), onPressed: busy || _page == widget.store.edition.lastPage ? null : () => _go(_page + 1), icon: Icon(Icons.chevron_left)),
            TextButton(onPressed: _jump, child: Text('$_page / ${widget.store.edition.lastPage}')),
            IconButton(tooltip: widget.store.bookmarks.contains(_page) ? context.t('Ayracı kaldır') : context.t('Ayraç ekle'),
              onPressed: busy || _bookmarkSaving ? null : _toggleBookmark, icon: Icon(widget.store.bookmarks.contains(_page) ? Icons.bookmark : Icons.bookmark_border)),
            IconButton(tooltip: context.t('Önceki sayfa'), onPressed: busy || _page == widget.store.edition.firstPage ? null : () => _go(_page - 1), icon: Icon(Icons.chevron_right)),
          ])),
      ])),
      Positioned(top: 12, left: 20, right: 20, child: SafeArea(
        child: SajdahNotice(page: _page, editionId: widget.store.edition.id))),
      ]),
    );
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
  int mode = 0;
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
    final includeSurahs = (mode == 0 || mode == 1) && !onlyJuz && !onlyPage;
    final includeJuz = (mode == 0 || mode == 2 || onlyJuz) && !onlyPage;
    final includePages = (mode == 0 || mode == 3 || onlyPage) && !onlyJuz;
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
        Padding(padding: const EdgeInsets.only(top: 12), child: Wrap(spacing: 6, children: [
          for (final entry in const {0: 'Tümü', 1: 'Sureler', 2: 'Cüzler', 3: 'Sayfa'}.entries)
            ChoiceChip(label: Text(context.t(entry.value)), selected: mode == entry.key,
              onSelected: (_) => setState(() { mode = entry.key; })),
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
              trailing: Text(context.t('s. {page}', {'page': surah.startPage})),
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

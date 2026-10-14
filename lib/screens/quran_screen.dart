import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/surahs.dart';
import '../services/reading_store.dart';
import '../widgets/page_turn.dart';

class QuranScreen extends StatefulWidget {
  final ReadingStore store;
  final int initialPage;
  const QuranScreen({super.key, required this.store, required this.initialPage});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  late int _page;
  int? _target;
  bool _fullscreen = false;
  bool _preparing = false;
  bool _bookmarkSaving = false;
  final TransformationController _zoom = TransformationController();
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
        _preparing || _turn.isAnimating || _zoom.value.getMaxScaleOnAxis() > 1.01) return;
    final delta = event.position - _touchStart!;
    if (!_dragging) {
      if (delta.dx.abs() < 8 || delta.dx.abs() <= delta.dy.abs()) return;
      final target = _page + (delta.dx > 0 ? 1 : -1);
      if (target < 0 || target > 604) return;
      setState(() { _dragging = true; _target = target; });
    }
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
        _zoom.value = Matrix4.identity();
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
    _page = widget.initialPage.clamp(0, ReadingStore.lastNumberedPage).toInt();
    _turn = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _remember(_page);
  }

  void _error(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _remember(int page) async {
    try { await widget.store.savePage(page); } catch (_) { _error('Son okunan sayfa kaydedilemedi.'); }
  }

  Future<void> _go(int page, {bool animate = false}) async {
    if (_target != null || _preparing || page < 0 || page > 604 || page == _page) return;
    _zoom.value = Matrix4.identity();
    if (!animate || MediaQuery.of(context).disableAnimations) {
      setState(() => _page = page);
      await _remember(page);
      return;
    }
    _preparing = true;
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
    } finally { _preparing = false; }
  }

  Future<void> _jump() async {
    final controller = TextEditingController();
    final form = GlobalKey<FormState>();
    final page = await showDialog<int>(context: context, builder: (context) => AlertDialog(
      title: const Text('Sayfaya git'),
      content: Form(key: form, child: TextFormField(
        controller: controller, autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(labelText: 'Sayfa numarası (0–604; 0 = Fatiha)'),
        validator: (value) {
          final n = int.tryParse(value ?? '');
          return n == null || n < 0 || n > 604 ? '0 ile 604 arasında bir sayı yazın.' : null;
        },
        onFieldSubmitted: (_) { if (form.currentState!.validate()) Navigator.pop(context, int.parse(controller.text)); },
      )),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(context, int.parse(controller.text)); }, child: const Text('Sayfaya git'))],
    ));
    // Dialog exit animation may still use the controller; dispose after it finishes.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (page != null && mounted) await _go(page);
  }

  Future<void> _selectSurah() async {
    final selected = await showModalBottomSheet<int>(context: context, isScrollControlled: true,
      builder: (context) => _SurahPicker());
    if (selected != null && mounted) await _go(selected);
  }

  Future<void> _bookmarks() async {
    final pages = widget.store.bookmarks.toList()..sort();
    final selected = await showModalBottomSheet<int>(context: context, builder: (context) => SafeArea(
      child: pages.isEmpty ? const Padding(padding: EdgeInsets.all(32), child: Text('Henüz ayraç yok. Okuduğunuz sayfada ayraç simgesine dokunun.'))
      : ListView(children: [const ListTile(title: Text('Ayraçlar')),
        for (final page in pages) ListTile(title: Text('Sayfa $page'),
          subtitle: Text(surahsOnPage(page).map((s) => s.name).join(', ')),
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
    setState(() => _fullscreen = !_fullscreen);
    SystemChrome.setEnabledSystemUIMode(_fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _zoom.dispose();
    _turn.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Widget _image(int page) => Image.file(File(widget.store.pagePath(page)), fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
    errorBuilder: (_, error, stack) => const Center(child: Text('Sayfa okunamadı. Ana ekrandan indirmeyi tekrar kontrol edin.')));

  @override
  Widget build(BuildContext context) {
    final busy = _target != null || _preparing;
    return Scaffold(backgroundColor: const Color(0xFFE9E1D1),
      appBar: _fullscreen ? null : AppBar(title: Text(surahsOnPage(_page).map((s) => s.name).join(' · ')),
        actions: [IconButton(tooltip: 'Sayfaya git', onPressed: _jump, icon: const Icon(Icons.numbers)),
          PopupMenuButton<String>(onSelected: (v) {
            if (v == 'surah') _selectSurah();
            if (v == 'bookmarks') _bookmarks();
            if (v == 'full') _toggleFullscreen();
          }, itemBuilder: (_) => const [PopupMenuItem(value: 'surah', child: Text('Sure seç')),
            PopupMenuItem(value: 'bookmarks', child: Text('Ayraçlar')),
            PopupMenuItem(value: 'full', child: Text('Tam ekran'))])]),
      body: SafeArea(top: !_fullscreen, bottom: !_fullscreen, child: Column(children: [
        Expanded(child: GestureDetector(
          onDoubleTap: _toggleFullscreen,
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
            final child = _target == null ? _image(_page) : PageTurn(
              image: FileImage(File(widget.store.pagePath(_page))), animation: _turn,
              toRight: _target! > _page, underneath: _image(_target!),
              touchHeight: _touchHeight, dragTilt: _dragTilt);
            return InteractiveViewer(transformationController: _zoom, minScale: 1, maxScale: 4,
              panEnabled: _target == null,
              child: SizedBox(width: constraints.maxWidth, height: constraints.maxHeight, child: child));
          })),
        )),
        if (!_fullscreen) Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            IconButton(tooltip: 'Sonraki sayfa', onPressed: busy || _page == 604 ? null : () => _go(_page + 1, animate: true), icon: const Icon(Icons.chevron_left)),
            TextButton(onPressed: _jump, child: Text('$_page / 604')),
            IconButton(tooltip: widget.store.bookmarks.contains(_page) ? 'Ayracı kaldır' : 'Ayraç ekle',
              onPressed: busy || _bookmarkSaving ? null : _toggleBookmark, icon: Icon(widget.store.bookmarks.contains(_page) ? Icons.bookmark : Icons.bookmark_border)),
            IconButton(tooltip: 'Önceki sayfa', onPressed: busy || _page == 0 ? null : () => _go(_page - 1, animate: true), icon: const Icon(Icons.chevron_right)),
          ])),
      ])),
    );
  }
}

class _SurahPicker extends StatefulWidget {
  @override
  State<_SurahPicker> createState() => _SurahPickerState();
}
class _SurahPickerState extends State<_SurahPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = surahs.where((s) => normalizeSurahName(s.name).contains(normalizeSurahName(query)) || s.number.toString() == query).toList();
    return SafeArea(child: SizedBox(height: MediaQuery.sizeOf(context).height * .8,
      child: Column(children: [Padding(padding: const EdgeInsets.all(16), child: TextField(
        decoration: const InputDecoration(labelText: 'Sure adı veya numarası', prefixIcon: Icon(Icons.search)),
        onChanged: (v) => setState(() => query = v))),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
          final surah = filtered[i];
          return ListTile(title: Text('${surah.number}. ${surah.name}'), trailing: Text('s. ${surah.startPage}'),
            onTap: () => Navigator.pop(context, surah.startPage));
        })),
      ])));
  }
}

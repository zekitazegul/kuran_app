import '../widgets/screen_title.dart';
import '../widgets/paginated_meal_text.dart';
import '../widgets/personal_page_scope.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/surahs.dart';
import '../l10n/translations.dart';
import '../services/meal_reader.dart';
import '../widgets/app_bottom_bar.dart';

class MealScreen extends StatefulWidget {
  final int? initialSurah;
  final int? initialVerse;
  const MealScreen({super.key, this.initialSurah, this.initialVerse});
  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> implements FullscreenReadingSession {
  final _reader = MealReader();
  List<List<String>> _pages = [];
  int _fontSize = 22;
  bool _busy = true;
  bool _failed = false;
  bool _fullscreen = false;
  final _pager = GlobalKey<PaginatedMealTextState>();
  int _textOffset = 0;
  Future<void>? _positionWrite;

  Future<void> _savePosition(int page, int offset) async {
    _textOffset = offset;
    if (page != _reader.page) {
      await _select(page, offset: offset);
      return;
    }
    final fontSize = _fontSize;
    final surah = _reader.surah;
    _positionWrite = (_positionWrite ?? Future<void>.value()).catchError((Object _) {}).then((_) async {
      await MealReader.channel.invokeMethod<void>('saveText', {
        'surah': surah, 'verse': 1, 'fontSize': fontSize,
        'textPage': page, 'textOffset': offset,
      });
    });
    try { await _positionWrite; } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Tercihler kaydedilemedi.'))));
    }
  }

  @override
  void exitFullscreen() {
    if (mounted && _fullscreen) setState(() => _fullscreen = false);
    if (identical(AppNavigation.instance.fullscreenMeal.value, this)) AppNavigation.instance.fullscreenMeal.value = null;
  }

  void _toggleFullscreen() {
    setState(() => _fullscreen = !_fullscreen);
    AppNavigation.instance.fullscreenMeal.value = _fullscreen ? this : null;
  }

  @override
  void dispose() {
    if (identical(AppNavigation.instance.fullscreenMeal.value, this)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (identical(AppNavigation.instance.fullscreenMeal.value, this)) {
          AppNavigation.instance.fullscreenMeal.value = null;
        }
      });
    }
    super.dispose();
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = jsonDecode(await rootBundle.loadString('assets/meal/turkish-pages.json')) as List;
      await _reader.load(initialSurah: widget.initialSurah, initialVerse: widget.initialVerse);
      final preferences = await MealReader.channel.invokeMapMethod<String, dynamic>('loadText');
      if (!mounted) return;
      _textOffset = widget.initialSurah == null && preferences?['textPage'] == _reader.page
        ? (preferences?['textOffset'] as int? ?? 0) : 0;
      setState(() {
        _pages = data.map((p) => List<String>.from(p as List)).toList();
        _fontSize = (preferences?['fontSize'] as int? ?? 22).clamp(16, 40);
        _busy = false;
        _failed = false;
      });
    } catch (_) {
      if (mounted) setState(() { _busy = false; _failed = true; });
    }
  }

  Future<void> _select(int page, {int? surah, int offset = 0}) async {
    setState(() { _busy = true; });
    try {
      await _reader.save(page: page, surah: surah);
      if (!mounted) return;
      _textOffset = offset;
      await _savePosition(page, offset);
      if (mounted) setState(() { _busy = false; _failed = false; });
    } catch (_) {
      if (mounted) setState(() { _busy = false; _failed = true; });
    }
  }

  Future<void> _resize(int delta) async {
    setState(() => _fontSize = (_fontSize + delta).clamp(16, 40));
    try {
      await _savePosition(_reader.page, _textOffset);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Tercihler kaydedilemedi.'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: !_fullscreen, onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _fullscreen) _toggleFullscreen();
    }, child: Scaffold(
      appBar: _fullscreen ? null : AppBar(automaticallyImplyLeading: PersonalPageScope.of(context) == null, title: PersonalPageScope.of(context)?.heading ?? ScreenTitle(context, context.t('Meal Oku')), actions: [
        IconButton(key: const ValueKey('meal-font-smaller'), tooltip: context.t('Yazıyı küçült'), onPressed: _busy || _fontSize <= 16 ? null : () => _resize(-2), icon: const Icon(Icons.text_decrease)),
        IconButton(key: const ValueKey('meal-font-larger'), tooltip: context.t('Yazıyı büyüt'), onPressed: _busy || _fontSize >= 40 ? null : () => _resize(2), icon: const Icon(Icons.text_increase)),
      ]),
      body: SafeArea(top: false, child: _pages.isEmpty && _busy ? const Center(child: CircularProgressIndicator()) : _failed
        ? Center(child: TextButton(onPressed: _load, child: Text(context.t('Tekrar dene'))))
        : Column(children: [
          if (!_fullscreen) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), child: DecoratedBox(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline))),
            child: Row(children: [
            Text(context.t('Sureler')),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<int>(key: ValueKey('meal-surah-${_reader.surah}'), initialValue: _reader.surah, isExpanded: true,
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12),
              border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, disabledBorder: InputBorder.none),
            items: [for (final s in surahs) DropdownMenuItem(value: s.number, child: Text('${s.number}. ${surahName(s, context.language)}', overflow: TextOverflow.ellipsis))],
            onChanged: _busy ? null : (s) { if (s != null) _select(_reader.surahPages[s - 1], surah: s); })),
            if (_reader.hasSurahProgress) Padding(padding: const EdgeInsets.only(left: 12),
              child: Text('${_reader.pageInSurah}/${_reader.surahPageCount} sf.', key: const ValueKey('meal-surah-progress'), style: Theme.of(context).textTheme.titleMedium)),
          ]))),
          Expanded(key: const ValueKey('meal-reading-area'), child: PaginatedMealText(
              onDoubleTap: _toggleFullscreen,
              key: _pager, pages: _pages, page: _reader.page,
              offset: _textOffset, fontSize: _fontSize, enabled: !_busy,
              onChanged: _savePosition,
              footerBuilder: _fullscreen ? null : (context, screen, screens) => PersonalPageSwipe(
                onNavigate: (delta) => AppNavigation.instance.switchPage?.call(delta),
                child: Row(key: const ValueKey('meal-combined-footer'), children: [
                  IconButton(tooltip: context.t('Önceki'), onPressed: _busy ? null : () => _pager.currentState?.turn(-1), icon: const Icon(Icons.chevron_left)),
                  Expanded(child: FittedBox(fit: BoxFit.scaleDown, child: Row(children: [
                    Text('$screen / $screens', key: const ValueKey('meal-screen-progress')),
                    const SizedBox(width: 16),
                    Text('${_reader.page} / ${_reader.pageCount}', key: const ValueKey('meal-source-progress')),
                  ]))),
                  IconButton(tooltip: context.t('Sonraki'), onPressed: _busy ? null : () => _pager.currentState?.turn(1), icon: const Icon(Icons.chevron_right)),
                ])),
          )),
        ])),
    ));
  }
}

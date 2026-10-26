import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderBox, RenderRepaintBoundary, ScrollDirection, ScrollCacheExtent;

class MealTextSlice {
  final int start;
  final int end;
  const MealTextSlice(this.start, this.end);
}

/// Split at rendered line boundaries, keeping every character in order.
List<MealTextSlice> paginateMealText(String text, TextStyle style,
    double width, double height, TextScaler scaler) {
  final painter = TextPainter(textDirection: TextDirection.ltr, textScaler: scaler);
  final slices = <MealTextSlice>[];
  var start = 0;
  while (start < text.length) {
    final remaining = text.substring(start);
    painter.text = TextSpan(text: remaining, style: style);
    painter.layout(maxWidth: width);
    final lines = painter.computeLineMetrics();
    var end = remaining.length;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.baseline + line.descent > height && i > 0) {
        final previous = lines[i - 1];
        final position = painter.getPositionForOffset(Offset(0, previous.baseline));
        end = painter.getLineBoundary(position).end;
        // Consume a line break as part of the preceding page.
        while (end < remaining.length && remaining[end].trim().isEmpty) {
          end++;
        }
        break;
      }
    }
    if (end == 0) end = remaining.length;
    slices.add(MealTextSlice(start, start + end));
    start += end;
  }
  painter.dispose();
  return slices.isEmpty ? [const MealTextSlice(0, 0)] : slices;
}

class PaginatedMealText extends StatefulWidget {
  final List<List<String>> pages;
  final int page;
  final int offset;
  final int fontSize;
  final bool enabled;
  final int positionRevision;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;
  final bool showProgress;
  final void Function(int page, int offset) onChanged;
  final Widget Function(BuildContext context, int screen, int screens)? footerBuilder;
  const PaginatedMealText({super.key, required this.pages, required this.page,
    required this.offset, required this.fontSize, required this.enabled,
    required this.onChanged, this.footerBuilder, this.onDoubleTap,
    this.positionRevision = 0, this.onTap, this.showProgress = true});

  @override
  State<PaginatedMealText> createState() => PaginatedMealTextState();
}

class _MealPageLayout {
  final String text;
  final TextPainter painter;
  final List<MealTextSlice> slices;
  _MealPageLayout(this.text, this.painter, this.slices);
}

/// A continuous vertical document. Horizontal swipes navigate its screenfuls,
/// using the same character anchor as vertical scrolling and saved positions.
class PaginatedMealTextState extends State<PaginatedMealText> with SingleTickerProviderStateMixin {
  final _viewportKey = GlobalKey();
  final _paintKey = GlobalKey();
  late final AnimationController _slide;
  ui.Image? _outgoing;
  bool _horizontalCommit = false;
  int _captureEpoch = 0;

  Future<void> _capture() async {
    final epoch = ++_captureEpoch;
    final boundary = _paintKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || boundary.debugNeedsPaint) return;
    final image = await boundary.toImage(pixelRatio: 1);
    if (!mounted || epoch != _captureEpoch) { image.dispose(); return; }
    _outgoing?.dispose();
    _outgoing = image;
  }

  void _clearSlide() {
    _captureEpoch++;
    _slide.stop();
    _slide.value = 0;
    _outgoing?.dispose();
    _outgoing = null;
    _horizontalCommit = false;
  }

  Future<void> _cancelSlide() async {
    await _slide.animateTo(0, duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
    if (mounted) setState(_clearSlide);
  }

  final _layouts = <int, _MealPageLayout>{};
  final _pageKeys = <int, GlobalKey>{};
  ScrollController? _controller;
  Key _scrollKey = UniqueKey();
  Key _centerKey = UniqueKey();
  Object? _geometry;
  late int _page, _offset, _lastPublishedPage, _lastPublishedOffset;
  int _origin = 1, _index = 0;
  ({int page, int offset})? _requested;
  bool _publishAfterRestore = false;
  bool _restoring = false, _turning = false, _dirty = false;
  bool _observationQueued = false, _flushRequested = false;
  double _horizontalDistance = 0, _width = 1, _textHeight = 1, _viewportHeight = 1;
  late TextStyle _style;
  late TextScaler _scaler;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _slide = AnimationController.unbounded(vsync: this);
    _page = _lastPublishedPage = widget.page;
    _offset = _lastPublishedOffset = widget.offset;
  }

  @override
  void didUpdateWidget(covariant PaginatedMealText oldWidget) {
    super.didUpdateWidget(oldWidget);
    final explicit = oldWidget.positionRevision != widget.positionRevision ||
      !identical(oldWidget.pages, widget.pages);
    final changed = oldWidget.page != widget.page || oldWidget.offset != widget.offset;
    final acknowledgement = widget.page == _lastPublishedPage &&
      widget.offset == _lastPublishedOffset;
    if (explicit || (changed && !acknowledgement)) {
      _requested = (page: widget.page, offset: widget.offset);
      _geometry = null;
    }
  }

  _MealPageLayout _layoutFor(int page) {
    final cached = _layouts.remove(page);
    if (cached != null) {
      _layouts[page] = cached;
      return cached;
    }
    final text = widget.pages[page - 1].join('\n');
    final painter = TextPainter(text: TextSpan(text: text, style: _style),
      textDirection: TextDirection.ltr, textScaler: _scaler)..layout(maxWidth: _width);
    final result = _MealPageLayout(text, painter,
      paginateMealText(text, _style, _width, _textHeight, _scaler));
    _layouts[page] = result;
    // Keep only nearby layout data; the 1,490-page book is built lazily.
    while (_layouts.length > 8) {
      _layouts.remove(_layouts.keys.first)!.painter.dispose();
    }
    return result;
  }

  void _publish() {
    _saveTimer?.cancel();
    if (!mounted || (_page == _lastPublishedPage && _offset == _lastPublishedOffset)) return;
    _lastPublishedPage = _page;
    _lastPublishedOffset = _offset;
    widget.onChanged(_page, _offset);
  }

  ({int page, int offset})? _visibleAnchor() {
    final viewport = _viewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !viewport.hasSize) return null;
    final top = viewport.localToGlobal(Offset.zero).dy;
    final visible = <({int page, double top})>[];
    for (final entry in _pageKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final pageTop = box.localToGlobal(Offset.zero).dy - top;
      if (pageTop + box.size.height > 0 && pageTop < viewport.size.height) {
        visible.add((page: entry.key, top: pageTop));
      }
    }
    if (visible.isEmpty) return null;
    visible.sort((a, b) => a.page.compareTo(b.page));
    final first = visible.first;
    final layout = _layoutFor(first.page);
    final y = (-first.top).clamp(0.0, layout.painter.height);
    final position = layout.painter.getPositionForOffset(Offset(0, y + 0.1));
    final offset = layout.painter.getLineBoundary(position).start.clamp(0, layout.text.length);
    return (page: first.page, offset: offset);
  }

  void _observe({bool flush = false}) {
    if (!mounted || _restoring || !_dirty) return;
    final anchor = _visibleAnchor();
    if (anchor == null) return;
    final sourceChanged = anchor.page != _page;
    final layout = _layoutFor(anchor.page);
    final index = layout.slices.lastIndexWhere((slice) => slice.start <= anchor.offset)
      .clamp(0, layout.slices.length - 1);
    if (_page != anchor.page || _offset != anchor.offset || _index != index) {
      setState(() { _page = anchor.page; _offset = anchor.offset; _index = index; });
    }
    _saveTimer?.cancel();
    if (flush || sourceChanged) {
      _publish();
    } else {
      _saveTimer = Timer(const Duration(milliseconds: 150), _publish);
    }
    if (flush) _dirty = false;
  }

  void _scheduleObservation({bool flush = false}) {
    _flushRequested |= flush;
    if (_observationQueued) return;
    _observationQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _observationQueued = false;
      final flush = _flushRequested;
      _flushRequested = false;
      _observe(flush: flush);
    });
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || _restoring) return false;
    if (notification is ScrollStartNotification &&
        (!_turning || notification.dragDetails != null)) {
      _turning = false;
      _dirty = true;
    }
    if (notification is UserScrollNotification && notification.direction != ScrollDirection.idle) {
      _turning = false;
      _dirty = true;
    }
    if (_dirty && notification is ScrollUpdateNotification) _scheduleObservation();
    if (_dirty && notification is ScrollEndNotification) _scheduleObservation(flush: true);
    return false;
  }

  void turn(int delta) {
    if (!widget.enabled || _controller?.hasClients != true || _restoring || _horizontalCommit) return;
    if (_dirty) _observe(flush: true);
    final slices = _layoutFor(_page).slices;
    final target = _index + delta;
    if (target < 0) {
      if (_page > 1) { _navigate(_page - 1, -1, delta); } else { _cancelSlide(); }
    } else if (target >= slices.length) {
      if (_page < widget.pages.length) { _navigate(_page + 1, 0, delta); } else { _cancelSlide(); }
    } else {
      _navigate(_page, slices[target].start, delta);
    }
  }

  Future<void> _navigate(int page, int offset, int delta) async {
    final layout = _layoutFor(page);
    final targetOffset = offset < 0 ? layout.slices.last.start : offset;
    _horizontalCommit = true;
    if (_outgoing == null) await _capture();
    if (!mounted) return;
    _saveTimer?.cancel();
    _dirty = false;
    _turning = true;
    final direction = delta > 0 ? -1.0 : 1.0;
    final box = _pageKeys[page]?.currentContext?.findRenderObject();
    final viewport = _viewportKey.currentContext?.findRenderObject();
    if (box is RenderBox && viewport is RenderBox && box.attached) {
      final caret = layout.painter.getOffsetForCaret(TextPosition(offset: targetOffset), Rect.zero);
      final top = box.localToGlobal(Offset.zero).dy - viewport.localToGlobal(Offset.zero).dy;
      final controller = _controller!;
      final target = (controller.offset + top + caret.dy)
        .clamp(controller.position.minScrollExtent, controller.position.maxScrollExtent);
      controller.jumpTo(target);
      setState(() {
        _page = page; _offset = targetOffset;
        _index = layout.slices.lastIndexWhere((slice) => slice.start <= targetOffset)
          .clamp(0, layout.slices.length - 1);
      });
    } else {
      setState(() {
        _requested = (page: page, offset: targetOffset);
        _publishAfterRestore = true;
        _geometry = null;
      });
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted) return;
    await _slide.animateTo(direction * (_width + 40),
      duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    if (!mounted) return;
    setState(_clearSlide);
    _turning = false;
    _publish();
  }

  void _reset(Object geometry) {
    _saveTimer?.cancel();
    _dirty = _turning = false;
    _restoring = true;
    for (final layout in _layouts.values) { layout.painter.dispose(); }
    _layouts.clear();
    _pageKeys.clear();
    final anchor = _requested ?? (page: _page, offset: _offset);
    _requested = null;
    _page = _origin = anchor.page.clamp(1, widget.pages.length);
    final layout = _layoutFor(_page);
    _offset = (anchor.offset < 0 ? layout.slices.last.start : anchor.offset).clamp(0, layout.text.length);
    _index = layout.slices.lastIndexWhere((slice) => slice.start <= _offset)
      .clamp(0, layout.slices.length - 1);
    final caret = layout.painter.getOffsetForCaret(TextPosition(offset: _offset), Rect.zero);
    final old = _controller;
    _controller = ScrollController(initialScrollOffset: caret.dy, keepScrollOffset: false);
    _scrollKey = UniqueKey();
    _centerKey = UniqueKey();
    _geometry = geometry;
    final publish = _publishAfterRestore || anchor.offset < 0;
    _publishAfterRestore = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      old?.dispose();
      if (!mounted) return;
      _restoring = false;
      if (publish) _publish();
    });
  }

  Widget _adjacentPreview(int delta) {
    var page = _page;
    var index = _index + delta;
    var layout = _layoutFor(page);
    if (index < 0) {
      if (page == 1) return const SizedBox.expand();
      layout = _layoutFor(--page);
      index = layout.slices.length - 1;
    } else if (index >= layout.slices.length) {
      if (page == widget.pages.length) return const SizedBox.expand();
      layout = _layoutFor(++page);
      index = 0;
    }
    return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(layout.text.substring(layout.slices[index].start),
          textDirection: TextDirection.ltr, style: _style)));
  }

  Widget _buildSource(int page) {
    final layout = _layoutFor(page);
    return Padding(key: _pageKeys.putIfAbsent(page, GlobalKey.new),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(layout.text, key: ValueKey('meal-source-text-$page'),
        textDirection: TextDirection.ltr, style: _style));
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _captureEpoch++;
    _slide.dispose();
    _outgoing?.dispose();
    _controller?.dispose();
    for (final layout in _layouts.values) { layout.painter.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    _width = (constraints.maxWidth - 40).clamp(1.0, double.infinity);
    final footerHeight = widget.footerBuilder != null || widget.showProgress ? 48.0 : 0.0;
    _textHeight = (constraints.maxHeight - (footerHeight == 0 ? 0 : widget.footerBuilder == null ? 52 : 60)).clamp(1.0, double.infinity);
    _viewportHeight = (constraints.maxHeight - footerHeight).clamp(1.0, double.infinity);
    _scaler = MediaQuery.textScalerOf(context);
    _style = DefaultTextStyle.of(context).style.copyWith(fontSize: widget.fontSize.toDouble(), height: 1.6);
    final geometry = (_width, _textHeight, _style, _scaler);
    if (_geometry != geometry) _reset(geometry);
    final slices = _layoutFor(_page).slices;
    return Column(children: [
      Expanded(child: SizedBox(key: _viewportKey, child: GestureDetector(
        key: const ValueKey('meal-reading-surface'), behavior: HitTestBehavior.opaque,
        onDoubleTap: widget.onDoubleTap,
        onTap: widget.onTap,
        onHorizontalDragStart: widget.enabled ? (_) {
          if (_horizontalCommit) return;
          _horizontalDistance = 0;
          _slide.stop();
          _capture();
        } : null,
        onHorizontalDragUpdate: widget.enabled ? (details) {
          if (_horizontalCommit) return;
          _horizontalDistance += details.delta.dx;
          _slide.value = _horizontalDistance.clamp(-constraints.maxWidth, constraints.maxWidth);
        } : null,
        onHorizontalDragCancel: _cancelSlide,
        onHorizontalDragEnd: widget.enabled ? (details) {
          if (_horizontalCommit) return;
          final velocity = details.primaryVelocity ?? 0;
          if (_horizontalDistance.abs() > constraints.maxWidth * .18 || velocity.abs() > 450) {
            turn((velocity.abs() > 450 ? velocity : _horizontalDistance) < 0 ? 1 : -1);
          } else {
            _cancelSlide();
          }
          _horizontalDistance = 0;
        } : null,
        child: AnimatedBuilder(animation: _slide, builder: (context, child) {
          final dx = _slide.value;
          final width = constraints.maxWidth;
          final background = Theme.of(context).scaffoldBackgroundColor;
          return ClipRect(child: Stack(fit: StackFit.expand, children: [
            ColoredBox(color: background),
            if (!_horizontalCommit && dx != 0)
              Positioned.fill(child: ExcludeSemantics(child: IgnorePointer(
                child: Transform.translate(offset: Offset(dx + (dx < 0 ? width : -width), 0),
                  child: _adjacentPreview(dx < 0 ? 1 : -1))))),
            Transform.translate(key: const ValueKey('meal-horizontal-page'),
              offset: Offset(_horizontalCommit ? dx + (dx <= 0 ? width : -width) : dx, 0),
              child: child),
            if (_horizontalCommit && _outgoing != null)
              Positioned.fill(child: IgnorePointer(child: Transform.translate(
                offset: Offset(dx, 0), child: RawImage(image: _outgoing, fit: BoxFit.fill)))),
          ]));
        }, child: RepaintBoundary(key: _paintKey,
          child: NotificationListener<ScrollNotification>(onNotification: _onScroll,
          child: CustomScrollView(key: _scrollKey, controller: _controller, center: _centerKey,
            scrollCacheExtent: ScrollCacheExtent.pixels(_viewportHeight),
            physics: widget.enabled ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
            slivers: [
              SliverList(delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSource(_origin - 1 - index), childCount: _origin - 1)),
              SliverList(key: _centerKey, delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSource(_origin + index), childCount: widget.pages.length - _origin + 1)),
              SliverToBoxAdapter(child: SizedBox(height:
                (_viewportHeight - _scaler.scale(widget.fontSize.toDouble()) * 1.6).clamp(0.0, double.infinity))),
            ])))),
      ))),
      if (widget.footerBuilder != null)
        SizedBox(height: 48, child: widget.footerBuilder!(context, _index + 1, slices.length))
      else if (widget.showProgress) Padding(padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text('${_index + 1} / ${slices.length}', key: const ValueKey('meal-screen-progress'),
          style: Theme.of(context).textTheme.bodySmall)),
    ]);
  });
}

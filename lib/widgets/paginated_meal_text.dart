import 'package:flutter/material.dart';

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
  final void Function(int page, int offset) onChanged;
  const PaginatedMealText({super.key, required this.pages, required this.page,
    required this.offset, required this.fontSize, required this.enabled,
    required this.onChanged});

  @override
  State<PaginatedMealText> createState() => PaginatedMealTextState();
}

class PaginatedMealTextState extends State<PaginatedMealText> {
  PageController? _controller;
  Object? _layout;
  List<MealTextSlice> _slices = [];
  int _index = 0;
  int _offset = 0;
  int _source = 0;

  @override
  void didUpdateWidget(covariant PaginatedMealText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page == widget.page && oldWidget.offset != widget.offset &&
        widget.offset != _offset) {
      _offset = widget.offset;
      _layout = null;
    }
  }

  void turn(int delta) {
    final controller = _controller;
    if (!widget.enabled || controller == null || !controller.hasClients) return;
    final target = (controller.page!.round() + delta).clamp(0,
      _slices.length - 1 + (widget.page > 1 ? 1 : 0) + (widget.page < widget.pages.length ? 1 : 0));
    controller.animateToPage(target, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final width = (constraints.maxWidth - 40).clamp(1.0, double.infinity);
    final height = (constraints.maxHeight - 52).clamp(1.0, double.infinity);
    final scaler = MediaQuery.textScalerOf(context);
    final style = DefaultTextStyle.of(context).style.copyWith(fontSize: widget.fontSize.toDouble(), height: 1.6);
    final layout = (widget.page, width, height, style, scaler);
    final text = widget.pages[widget.page - 1].join('\n\n');
    if (_layout != layout) {
      final anchor = _source == widget.page ? _offset : widget.offset;
      _slices = paginateMealText(text, style, width, height, scaler);
      _index = anchor < 0 ? _slices.length - 1 : _slices.lastIndexWhere((s) => s.start <= anchor).clamp(0, _slices.length - 1);
      _offset = anchor < 0 ? _slices[_index].start : anchor;
      _source = widget.page;
      _layout = layout;
      if (anchor < 0) {
        final source = widget.page;
        final offset = _offset;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.page == source) widget.onChanged(source, offset);
        });
      }
      final old = _controller;
      _controller = PageController(initialPage: _index + (widget.page > 1 ? 1 : 0), keepPage: false);
      if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    final before = widget.page > 1 ? 1 : 0;
    final after = widget.page < widget.pages.length ? 1 : 0;
    return Column(children: [
      Expanded(child: PageView.builder(
        key: ValueKey(_layout), controller: _controller,
        physics: widget.enabled ? null : const NeverScrollableScrollPhysics(),
        itemCount: before + _slices.length + after,
        onPageChanged: (index) {
          if (!widget.enabled) return;
          final local = index - before;
          if (local < 0) { widget.onChanged(widget.page - 1, -1); return; }
          if (local >= _slices.length) { widget.onChanged(widget.page + 1, 0); return; }
          setState(() { _index = local; _offset = _slices[local].start; });
          widget.onChanged(widget.page, _offset);
        },
        itemBuilder: (context, index) {
          final local = index - before;
          var content = text;
          MealTextSlice slice;
          if (local < 0 || local >= _slices.length) {
            content = widget.pages[widget.page - 1 + (local < 0 ? -1 : 1)].join('\n\n');
            final adjacent = paginateMealText(content, style, width, height, scaler);
            slice = local < 0 ? adjacent.last : adjacent.first;
          } else {
            slice = _slices[local];
          }
          return Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Align(alignment: Alignment.topLeft, child: Text(
              content.substring(slice.start, slice.end),
              key: ValueKey('meal-slice-${widget.page}-$local'), style: style,
            )),
          );
        },
      )),
      Padding(padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text('${_index + 1} / ${_slices.length}', key: const ValueKey('meal-screen-progress'),
          style: Theme.of(context).textTheme.bodySmall)),
    ]);
  });
}

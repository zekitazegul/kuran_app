import 'package:flutter/material.dart';
import '../services/verse_regions.dart';
import '../l10n/translations.dart';

/// A long press owns the gesture until release, including moves outside its first verse.
class VerseSelectionOverlay extends StatefulWidget {
  final List<VerseRegion> verses;
  final int page;
  final VerseRegion? focus;
  final Size imageSize;
  final Rect? crop;
  final (int, int)? sajdah;
  final ValueChanged<List<VerseRegion>> onChanged;
  final Future<void> Function(List<VerseRegion>, Offset) onSelected;
  const VerseSelectionOverlay({super.key, required this.page, required this.verses, required this.imageSize,
    this.crop, this.sajdah, this.focus, required this.onChanged, required this.onSelected});
  @override
  State<VerseSelectionOverlay> createState() => _VerseSelectionOverlayState();
}

class _VerseSelectionOverlayState extends State<VerseSelectionOverlay> {
  int? _start;
  int? _handleIndex;
  bool _selecting = false;
  List<VerseRegion> _selected = [];
  void _clear() {
    if (!mounted) return;
    setState(() { _start = null; _selected = []; _selecting = false; });
    widget.onChanged([]);
  }
  @override
  void didUpdateWidget(VerseSelectionOverlay old) {
    super.didUpdateWidget(old);
    if (old.page != widget.page || old.verses.length != widget.verses.length ||
        (old.verses.isNotEmpty && widget.verses.isNotEmpty &&
          (old.verses.first.surah != widget.verses.first.surah || old.verses.first.verse != widget.verses.first.verse))) {
      _start = null; _selected = [];
    }
  }
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final size = constraints.biggest;
    Rect display(Rect box) => verseDisplayRect(box, size, widget.imageSize, widget.crop);
    int? hit(Offset global, {bool nearest = false}) {
      final local = (context.findRenderObject() as RenderBox).globalToLocal(global);
      int? closest;
      var distance = double.infinity;
      for (var i = 0; i < widget.verses.length; i++) {
        for (final box in widget.verses[i].boxes) {
          final rect = display(box);
          if (!nearest && rect.contains(local)) return i;
          if (nearest) {
            final point = Offset(local.dx.clamp(rect.left, rect.right), local.dy.clamp(rect.top, rect.bottom));
            final delta = (local - point).distanceSquared;
            if (delta < distance - .01 || (delta - distance).abs() <= .01 &&
                closest != null && _handleIndex != null && (i - _handleIndex!).abs() < (closest - _handleIndex!).abs()) {
              distance = delta; closest = i;
            }
          }
        }
      }
      return closest;
    }
    void update(int index) {
      final first = _start! < index ? _start! : index;
      final last = _start! > index ? _start! : index;
      setState(() => _selected = widget.verses.sublist(first, last + 1));
      widget.onChanged(_selected);
    }
    Widget handle(bool first) {
      final verse = first ? _selected.first : _selected.last;
      final boxes = verse.boxes.map(display).toList();
      final point = first ? boxes.first.topRight : boxes.last.bottomLeft;
      final left = (point.dx - 24).clamp(0.0, (size.width - 48).clamp(0.0, double.infinity));
      final top = (point.dy - 24).clamp(0.0, (size.height - 48).clamp(0.0, double.infinity));
      return Positioned(left: left, top: top, width: 48, height: 48,
        child: Semantics(label: context.t(first ? 'verseStart' : 'verseEnd'),
          child: GestureDetector(key: ValueKey(first ? 'selection-start' : 'selection-end'),
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              final anchor = first ? _selected.last : _selected.first;
              _start = widget.verses.indexWhere((v) => v.surah == anchor.surah && v.verse == anchor.verse);
              _handleIndex = widget.verses.indexWhere((v) => v.surah == verse.surah && v.verse == verse.verse);
              final index = hit(details.globalPosition, nearest: true);
              if (index != null) { _handleIndex = index; update(index); }
            },
            onPanUpdate: (details) {
              final index = hit(details.globalPosition, nearest: true);
              if (index != null && _start != null) { _handleIndex = index; update(index); }
            },
            onPanEnd: (_) => setState(() { _start = null; _handleIndex = null; }),
            onPanCancel: () => setState(() { _start = null; _handleIndex = null; }),
            child: Center(child: Container(width: 22, height: 22,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
          )));
    }
    Future<void> actions() async {
      final selected = List<VerseRegion>.of(_selected);
      final box = context.findRenderObject() as RenderBox;
      await widget.onSelected(selected, box.localToGlobal(size.center(Offset.zero)));
      _clear();
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: (details) {
        _selecting = true;
        _start = hit(details.globalPosition);
        if (_start != null) update(_start!);
      },
      onLongPressMoveUpdate: (details) {
        if (_start == null) return;
        final index = hit(details.globalPosition);
        if (index != null) update(index);
      },
      onLongPressEnd: (_) { setState(() { _start = null; _selecting = false; }); },
      onTap: _selected.isEmpty ? null : _clear,
      onLongPressCancel: () { if (_selecting) _clear(); },
      child: Stack(fit: StackFit.expand, children: [
        for (final verse in widget.verses)
          for (final box in verse.boxes)
            Positioned.fromRect(key: ValueKey('verse-${widget.page}-${verse.surah}-${verse.verse}-${verse.boxes.indexOf(box)}'),
              rect: display(box), child: ColoredBox(color:
                (_selected.any((v) => v.surah == verse.surah && v.verse == verse.verse) || (widget.focus?.surah==verse.surah && widget.focus?.verse==verse.verse))
                  ? const Color(0x663498DB)
                  : widget.sajdah == (verse.surah, verse.verse) ? const Color(0x55FFB300) : Colors.transparent)),
        if (_selected.isNotEmpty) ...[
          handle(true), handle(false),
          Positioned(top: 4, left: 4, child: FilledButton.icon(
            key: const ValueKey('selection-actions'), onPressed: actions,
            icon: const Icon(Icons.more_horiz), label: Text(context.t('selectionActions')))),
        ],
      ]),
    );
  });
}

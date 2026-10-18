import 'package:flutter/material.dart';
import '../services/verse_regions.dart';

/// A long press owns the gesture until release, including moves outside its first verse.
class VerseSelectionOverlay extends StatefulWidget {
  final List<VerseRegion> verses;
  final int page;
  final Size imageSize;
  final Rect? crop;
  final (int, int)? sajdah;
  final ValueChanged<List<VerseRegion>> onChanged;
  final Future<void> Function(List<VerseRegion>, Offset) onSelected;
  const VerseSelectionOverlay({super.key, required this.page, required this.verses, required this.imageSize,
    this.crop, this.sajdah, required this.onChanged, required this.onSelected});
  @override
  State<VerseSelectionOverlay> createState() => _VerseSelectionOverlayState();
}

class _VerseSelectionOverlayState extends State<VerseSelectionOverlay> {
  int? _start;
  List<VerseRegion> _selected = [];
  void _clear() {
    if (!mounted) return;
    setState(() { _start = null; _selected = []; });
    widget.onChanged([]);
  }
  @override
  void didUpdateWidget(VerseSelectionOverlay old) {
    super.didUpdateWidget(old);
    if (old.crop != widget.crop || old.verses.length != widget.verses.length ||
        (old.verses.isNotEmpty && widget.verses.isNotEmpty &&
          (old.verses.first.surah != widget.verses.first.surah || old.verses.first.verse != widget.verses.first.verse))) {
      _start = null; _selected = [];
    }
  }
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final size = constraints.biggest;
    Rect display(Rect box) => verseDisplayRect(box, size, widget.imageSize, widget.crop);
    int? hit(Offset global) {
      final local = (context.findRenderObject() as RenderBox).globalToLocal(global);
      for (var i = 0; i < widget.verses.length; i++) {
        if (widget.verses[i].boxes.any((box) => display(box).contains(local))) return i;
      }
      return null;
    }
    void update(int index) {
      final first = _start! < index ? _start! : index;
      final last = _start! > index ? _start! : index;
      setState(() => _selected = widget.verses.sublist(first, last + 1));
      widget.onChanged(_selected);
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: (details) {
        _start = hit(details.globalPosition);
        if (_start != null) update(_start!);
      },
      onLongPressMoveUpdate: (details) {
        if (_start == null) return;
        final index = hit(details.globalPosition);
        if (index != null) update(index);
      },
      onLongPressEnd: (details) async {
        final selected = List<VerseRegion>.of(_selected);
        _start = null;
        try {
          if (selected.isNotEmpty) await widget.onSelected(selected, details.globalPosition);
        } finally { _clear(); }
      },
      onLongPressCancel: _clear,
      child: Stack(fit: StackFit.expand, children: [
        for (final verse in widget.verses)
          for (final box in verse.boxes)
            Positioned.fromRect(key: ValueKey('verse-${widget.page}-${verse.surah}-${verse.verse}-${verse.boxes.indexOf(box)}'),
              rect: display(box), child: ColoredBox(color:
                _selected.any((v) => v.surah == verse.surah && v.verse == verse.verse)
                  ? const Color(0x663498DB)
                  : widget.sajdah == (verse.surah, verse.verse) ? const Color(0x55FFB300) : Colors.transparent)),
      ]),
    );
  });
}

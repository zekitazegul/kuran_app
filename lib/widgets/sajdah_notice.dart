import 'dart:async';
import 'package:flutter/material.dart';
import '../data/sajdah_verses.dart';
import '../data/surahs.dart';
import '../l10n/translations.dart';

class SajdahNotice extends StatefulWidget {
  final int page;
  final String editionId;
  const SajdahNotice({super.key, required this.page, required this.editionId});
  @override
  State<SajdahNotice> createState() => _SajdahNoticeState();
}

class _SajdahNoticeState extends State<SajdahNotice> {
  Timer? _timer;
  bool _visible = false;
  @override
  void initState() { super.initState(); _restart(); }
  @override
  void didUpdateWidget(SajdahNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page || oldWidget.editionId != widget.editionId) _restart();
  }
  void _restart() {
    _timer?.cancel();
    _visible = sajdahVerses.containsKey(widget.page);
    if (_visible) {
      _timer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _visible = false);
      });
    }
  }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final verse = sajdahVerses[widget.page];
    if (verse == null) return const SizedBox.shrink();
    return IgnorePointer(child: ExcludeSemantics(excluding: !_visible,
      child: AnimatedOpacity(opacity: _visible ? 1 : 0,
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 400),
        child: Semantics(liveRegion: true, child: Material(
          color: const Color(0xFF164D43), elevation: 6, borderRadius: BorderRadius.circular(16),
          child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            const Icon(Icons.info_outline, color: Color(0xFFE5C383)),
            const SizedBox(width: 12),
            Expanded(child: Text(context.t('Bu sayfada secde ayeti var.\n{surah} · {chapter}:{verse}', {
              'surah': surahName(surahs[verse.$1 - 1], context.language),
              'chapter': verse.$1, 'verse': verse.$2,
            }), style: const TextStyle(color: Colors.white))),
          ])),
        )))));
  }
}

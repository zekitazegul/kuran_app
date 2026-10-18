import 'package:flutter/material.dart';
import '../l10n/translations.dart';

/// Visible labels keep the reader actions understandable without a long press.
class ReaderActionBar extends StatelessWidget {
  final bool loading;
  final bool playing;
  final bool stopping;
  final VoidCallback? onListen;
  final VoidCallback? onMeal;
  const ReaderActionBar({super.key, required this.loading, required this.playing,
    required this.stopping, this.onListen, this.onMeal});

  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.center,
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 280),
        child: Material(color: Theme.of(context).colorScheme.surface.withValues(alpha: .95),
          borderRadius: BorderRadius.circular(20),
          child: Row(children: [
            _action(context, 'reader-listen',
              stopping ? 'readerStoppingLabel' : playing ? 'Durdur' : 'readerListenLabel',
              playing ? Icons.stop_circle_outlined : Icons.headphones_rounded,
              onListen, tooltip: stopping ? 'Ayet sonunda duracak' : playing ? 'Durdur' : "Kur'an dinle", busy: loading),
            _action(context, 'reader-meal', 'readerMealLabel', Icons.menu_book_rounded,
              onMeal, tooltip: 'Meal Oku'),
          ])))));

  Widget _action(BuildContext context, String key, String label, IconData icon,
    VoidCallback? onPressed, {required String tooltip, bool busy = false}) =>
    Expanded(child: Tooltip(message: context.t(tooltip), child: TextButton(
      key: ValueKey(key), onPressed: onPressed,
      style: TextButton.styleFrom(minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 20, height: 20, child: busy
          ? const CircularProgressIndicator(strokeWidth: 2)
          : Icon(icon, size: 20)),
        const SizedBox(width: 6),
        Flexible(child: Text(context.t(label), textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
      ]))));
}

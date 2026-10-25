import 'package:flutter/material.dart';
import 'quran_artwork.dart';

class DashboardDrag {
  final String id;
  final String source;
  const DashboardDrag(this.id, {this.source = 'home'});
  static final active = ValueNotifier<bool>(false);
  static final overNavigation = ValueNotifier<bool>(false);
  static Offset? position;
}

IconData bottomShortcutIcon(String id) => switch (id) {
  'exit' => Icons.arrow_back_rounded, 'home' => Icons.home_rounded,
  'hatim' => Icons.auto_stories_rounded, 'bookmarks' => Icons.bookmarks_rounded,
  'surahs' => Icons.search_rounded, 'history' => Icons.history_rounded,
  'settings' => Icons.settings_rounded, 'search' => Icons.search_rounded,
  'meal' => Icons.menu_book_rounded, 'listen' => Icons.headphones_rounded,
  'support' => Icons.favorite_outline, _ => Icons.menu_book_outlined,
};

class DashboardDragFeedback extends StatelessWidget {
  final String id;
  final double width;
  final Widget card;
  const DashboardDragFeedback({super.key, required this.id, required this.width, required this.card});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: DashboardDrag.overNavigation,
    builder: (context, compact, _) => AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 180),
      layoutBuilder: (current, previous) => Stack(clipBehavior: Clip.none, alignment: Alignment.topLeft,
        children: [...previous, ?current]),
      child: compact
        ? Transform.translate(key: const ValueKey('dashboard-drag-icon'), offset: const Offset(-80, -28),
            child: Material(elevation: 8, color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(28), child: SizedBox(width: 56, height: 56,
                child: Center(child: id == 'hatim' ? const QuranArtwork(size: 28, decorative: true)
                  : Icon(bottomShortcutIcon(id), size: 28, color: Theme.of(context).colorScheme.onPrimaryContainer)))))
        : Transform.translate(key: const ValueKey('dashboard-drag-card'), offset: Offset(-width / 2, -28),
            child: SizedBox(width: width, child: Material(elevation: 8, borderRadius: BorderRadius.circular(16), child: card))),
    ),
  );
}

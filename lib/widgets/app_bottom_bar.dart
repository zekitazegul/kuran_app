import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/app_preferences.dart';
import '../services/reading_store.dart';
import 'quran_artwork.dart';

enum AppDestination { home, hatim, bookmarks, surahs, history, settings, search, exit }

const destinationLabels = {
  AppDestination.exit: 'Geri / Çıkış', AppDestination.hatim: 'Hatim', AppDestination.home: 'Ana sayfa', AppDestination.bookmarks: 'Ayraçlar',
  AppDestination.surahs: 'Sureler', AppDestination.history: 'Okuma geçmişi',
  AppDestination.settings: 'Ayarlar', AppDestination.search: 'Sayfaya git',
};
const destinationIcons = {
  AppDestination.exit: Icons.arrow_back_rounded, AppDestination.hatim: Icons.auto_stories_rounded,
  AppDestination.home: Icons.home_rounded, AppDestination.bookmarks: Icons.bookmarks_rounded,
  AppDestination.surahs: Icons.menu_book_rounded, AppDestination.history: Icons.history_rounded,
  AppDestination.settings: Icons.settings_rounded, AppDestination.search: Icons.numbers_rounded,
};

class AppNavigation extends ValueNotifier<ReadingStore?> {
  AppNavigation._() : super(null);
  static final instance = AppNavigation._();
  final fullscreenReader = ValueNotifier<Object?>(null);
  final fullscreenMeal = ValueNotifier<Object?>(null);
  final selected = ValueNotifier<AppDestination>(AppDestination.home);
  void Function(AppDestination)? open;
  void refresh() => notifyListeners();
}

class AnimatedAppBottomBar extends StatelessWidget {
  const AnimatedAppBottomBar({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([AppNavigation.instance.fullscreenReader, AppNavigation.instance.fullscreenMeal]),
    builder: (context, _) {
      final hidden = AppNavigation.instance.fullscreenMeal.value != null ||
          (AppNavigation.instance.fullscreenReader.value != null && MediaQuery.orientationOf(context) == Orientation.landscape);
      return TweenAnimationBuilder<double>(
        tween: Tween(end: hidden ? 0 : 1),
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        child: IgnorePointer(ignoring: hidden,
          child: ExcludeSemantics(excluding: hidden, child: const AppBottomBar())),
        builder: (context, visibility, child) => ClipRect(
          child: Align(heightFactor: visibility, alignment: Alignment.topCenter,
            child: Opacity(opacity: visibility,
              child: FractionalTranslation(translation: Offset(0, 1 - visibility), child: child))),
        ),
      );
    },
  );
}

class NavigationOverlay extends StatefulWidget {
  final Widget child;
  const NavigationOverlay({super.key, required this.child});
  @override
  State<NavigationOverlay> createState() => _NavigationOverlayState();
}
class _NavigationOverlayState extends State<NavigationOverlay> {
  late final OverlayEntry _entry = OverlayEntry(builder: (_) => widget.child);
  @override
  void didUpdateWidget(NavigationOverlay oldWidget) { super.didUpdateWidget(oldWidget); _entry.markNeedsBuild(); }
  @override
  void dispose() { _entry.remove(); _entry.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Overlay(initialEntries: [_entry]);
}

class AppBottomBar extends StatefulWidget {
  const AppBottomBar({super.key});
  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}
class _AppBottomBarState extends State<AppBottomBar> {
  bool _saving = false;
  String? _dragged;
  OverlayEntry? _trash;
  Future<void> _save(List<String> items) async {
    if (_saving) return;
    setState(() => _saving = true);
    try { await AppPreferences.instance.save(AppPreferences.instance.value.copyWith(bottomShortcuts: items)); }
    catch (_) {
      if (mounted) ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(context.t('Tercih kaydedilemedi.'))));
    } finally { if (mounted) setState(() => _saving = false); }
  }
  void _endDrag() {
    _trash?.remove(); _trash?.dispose(); _trash = null;
    if (mounted) setState(() => _dragged = null);
  }
  void _startDrag(String id) {
    setState(() => _dragged = id);
    final box = context.findRenderObject() as RenderBox;
    final top = box.localToGlobal(Offset.zero).dy;
    _trash = OverlayEntry(builder: (overlayContext) => Positioned(
      top: (top - 100).clamp(0.0, double.infinity), left: 0, right: 0,
      child: Center(child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => details.data == _dragged,
        onAcceptWithDetails: (details) {
          _save(AppPreferences.instance.value.bottomShortcuts.where((item) => item != details.data).toList());
        },
        builder: (context, candidates, rejected) => Material(
          key: const ValueKey('navigation-trash'), elevation: 8,
          color: candidates.isEmpty ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(40),
          child: SizedBox(width: 80, height: 80, child: Icon(Icons.delete_outline,
            size: 32, color: candidates.isEmpty ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onError))),
      ))));
    Overlay.of(context).insert(_trash!);
  }
  @override
  void dispose() { _trash?.remove(); _trash?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ReadingStore?>(
    valueListenable: AppNavigation.instance,
    builder: (context, store, _) {
      if (store == null || !store.informationSeen || !store.guideSeen) return const SizedBox.shrink();
      return ValueListenableBuilder<UiPreferences>(valueListenable: AppPreferences.instance,
        builder: (context, preferences, _) {
          if (preferences.bottomShortcuts.isEmpty) return const SizedBox.shrink();
          return ValueListenableBuilder<AppDestination>(valueListenable: AppNavigation.instance.selected,
            builder: (context, selected, _) => Material(color: Theme.of(context).colorScheme.surfaceContainer,
              child: SafeArea(top: false, child: SizedBox(height: 56, child: Row(children: [
                for (final id in preferences.bottomShortcuts) Expanded(child: Builder(builder: (context) {
                  final destination = AppDestination.values.byName(id);
                  final active = selected == destination;
                  final colors = Theme.of(context).colorScheme;
                  final enabled = store.ready || destination == AppDestination.home || destination == AppDestination.history || destination == AppDestination.settings || destination == AppDestination.exit;
                  Widget icon({bool hovered = false}) => AnimatedContainer(
                    key: ValueKey('navigation-$id'), duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: active || hovered ? colors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(24)),
                    child: AnimatedScale(scale: active ? 1.08 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: destination == AppDestination.hatim
                      ? Opacity(opacity: enabled ? 1 : .4, child: const QuranArtwork(size: 28, decorative: true))
                      : Icon(destinationIcons[destination], color: enabled
                          ? active ? colors.onPrimaryContainer : colors.onSurfaceVariant : Theme.of(context).disabledColor)));
                  return DragTarget<String>(
                    onWillAcceptWithDetails: (details) => details.data != id,
                    onAcceptWithDetails: (details) {
                      final items = [...AppPreferences.instance.value.bottomShortcuts];
                      final oldIndex = items.indexOf(details.data);
                      final newIndex = items.indexOf(id);
                      if (oldIndex >= 0 && newIndex >= 0) { items.insert(newIndex, items.removeAt(oldIndex)); _save(items); }
                    },
                    builder: (context, candidates, rejected) => LongPressDraggable<String>(
                      data: id, maxSimultaneousDrags: _saving ? 0 : 1,
                      onDragStarted: () => _startDrag(id), onDragEnd: (_) => _endDrag(),
                      feedback: Material(elevation: 8, color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(28), child: Padding(padding: const EdgeInsets.all(16),
                          child: destination == AppDestination.hatim
                            ? const QuranArtwork(size: 28, decorative: true)
                            : Icon(destinationIcons[destination], color: colors.onPrimaryContainer))),
                      childWhenDragging: Opacity(opacity: .25, child: Center(child: icon())),
                      child: Semantics(button: true, selected: active, label: context.t(destinationLabels[destination]!),
                        child: InkWell(onTap: enabled ? () => AppNavigation.instance.open?.call(destination) : null,
                          child: SizedBox(height: 56, child: Center(child: icon(hovered: candidates.isNotEmpty))))),
                    ),
                  );
                })),
              ])))));
        });
    });
}

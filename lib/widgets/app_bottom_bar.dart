import 'motif_surface.dart';
import '../services/shortcut_transfer.dart';
import 'personal_page_scope.dart';
import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/app_preferences.dart';
import '../services/reading_store.dart';
import 'quran_artwork.dart';
import 'shortcut_drag.dart';
export 'shortcut_drag.dart' show bottomShortcutIcon;
import '../data/surahs.dart';

String bottomShortcutLabel(BuildContext context, String id) {
  for (final destination in AppDestination.values) {
    if (destination.name == id) return context.t(destinationLabels[destination]!);
  }
  if (dashboardCardLabels.containsKey(id)) return context.t(dashboardCardLabels[id]!);
  final number = int.parse(id.split(':').last);
  return id.startsWith('surah:') ? surahName(surahs[number - 1], context.language)
    : context.t('Cüz {number}', {'number': number});
}
enum AppDestination { home, hatim, bookmarks, surahs, history, settings, search, exit, meal }

const destinationLabels = {
  AppDestination.meal: 'Meal Oku',
  AppDestination.exit: 'Geri / Çıkış', AppDestination.hatim: 'Hatim', AppDestination.home: 'Ana sayfa', AppDestination.bookmarks: 'Ayraçlar',
  AppDestination.surahs: 'Sureler', AppDestination.history: 'Okuma geçmişi',
  AppDestination.settings: 'Ayarlar', AppDestination.search: 'Sayfaya git',
};
const destinationIcons = {
  AppDestination.meal: Icons.menu_book_rounded,
  AppDestination.exit: Icons.arrow_back_rounded, AppDestination.hatim: Icons.auto_stories_rounded,
  AppDestination.home: Icons.home_rounded, AppDestination.bookmarks: Icons.bookmarks_rounded,
  AppDestination.surahs: Icons.search_rounded, AppDestination.history: Icons.history_rounded,
  AppDestination.settings: Icons.settings_rounded, AppDestination.search: Icons.numbers_rounded,
};

abstract interface class FullscreenReadingSession {
  void exitFullscreen();
}

class AppNavigation extends ValueNotifier<ReadingStore?> {
  AppNavigation._() : super(null);
  static final instance = AppNavigation._();
  final fullscreenReader = ValueNotifier<Object?>(null);
  final fullscreenMeal = ValueNotifier<Object?>(null);
  final selected = ValueNotifier<AppDestination>(AppDestination.home);
  void Function(AppDestination)? open;
  void Function(String)? openCard;
  BuildContext? Function()? navigationContext;
  void Function(int delta)? switchPage;
  void exitFullscreen() {
    for (final session in [fullscreenReader.value, fullscreenMeal.value]) {
      if (session is FullscreenReadingSession) session.exitFullscreen();
    }
    fullscreenReader.value = null;
    fullscreenMeal.value = null;
  }
  void refresh() => notifyListeners();
}

class AnimatedAppBottomBar extends StatelessWidget {
  const AnimatedAppBottomBar({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([AppNavigation.instance.fullscreenReader, AppNavigation.instance.fullscreenMeal]),
    builder: (context, _) {
      final hidden = AppNavigation.instance.fullscreenMeal.value != null ||
          AppNavigation.instance.fullscreenReader.value != null;
      return TweenAnimationBuilder<double>(
        tween: Tween(end: hidden ? 0 : 1),
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        child: IgnorePointer(ignoring: hidden,
          child: ExcludeSemantics(excluding: hidden, child: PersonalPageSwipe(
            onNavigate: (delta) => AppNavigation.instance.switchPage?.call(delta), child: const AppBottomBar()))),
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
  bool _shortcutSheetOpen=false;
  final _dropKey = GlobalKey();
  String? _arriving;
  Offset _arrivalOffset = Offset.zero;
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
  Future<void> _chooseShortcuts() async {
    final navigationContext=AppNavigation.instance.navigationContext?.call();
    if(navigationContext==null) return;
    if(_shortcutSheetOpen) { Navigator.of(navigationContext).pop(); return; }
    _shortcutSheetOpen=true;
    try {
    await showModalBottomSheet<void>(context: navigationContext, isScrollControlled: true,
      builder: (sheetContext) => MotifSurface(menu:true,child:SafeArea(child: FractionallySizedBox(heightFactor: .8,
        child: ValueListenableBuilder<UiPreferences>(valueListenable: AppPreferences.instance,
          builder: (context, preferences, _) {
            final ids = {...UiPreferences.availableBottomShortcuts, ...preferences.shortcuts.map((s) => s.id)}.toList();
            return Column(children: [Padding(padding: const EdgeInsets.all(16),
              child: Text(context.t('navigationShortcuts'),style: Theme.of(context).textTheme.titleLarge)),
              Expanded(child: ListView(children: [for(final id in ids) CheckboxListTile(
                key: ValueKey('navigation-choice-$id'),
                title: Text(bottomShortcutLabel(context,id)),
                secondary: Icon(bottomShortcutIcon(id)), value: preferences.bottomShortcuts.contains(id),
                onChanged: (value) async {
                  final items=[...AppPreferences.instance.value.bottomShortcuts];
                  if(value==true) {
                    if(items.length>=5) {
                      ScaffoldMessenger.of(navigationContext).showSnackBar(SnackBar(content:
                        Text(this.context.t('Alt \u00e7ubu\u011fa en fazla 5 k\u0131sayol ekleyebilirsin.'))));
                      return;
                    }
                    items.add(id);
                  } else { items.remove(id); }
                  await _save(items);
                })]))]);
          })))));
    } finally { _shortcutSheetOpen=false; }
  }
  void _endDrag() {
    _trash?.remove(); _trash?.dispose(); _trash = null;
    DashboardDrag.active.value=false;
    DashboardDrag.position=null;
    DashboardDrag.overNavigation.value=false;
    if (mounted) setState(() => _dragged = null);
  }
  void _startDrag(String id) {
    setState(() => _dragged = id);
    DashboardDrag.active.value=true;
    final box = context.findRenderObject() as RenderBox;
    final top = box.localToGlobal(Offset.zero).dy;
    _trash = OverlayEntry(builder: (overlayContext) => Positioned(
      top: (top - 100).clamp(0.0, double.infinity), left: 0, right: 0,
      child: Center(child: DragTarget<DashboardDrag>(
        onWillAcceptWithDetails: (details) => ShortcutTransfer.canonical(details.data.id,'bottom') == _dragged,
        onAcceptWithDetails: (details) {
          _save(AppPreferences.instance.value.bottomShortcuts.where((item) => item != ShortcutTransfer.canonical(details.data.id,'bottom')).toList());
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

          return ValueListenableBuilder<AppDestination>(valueListenable: AppNavigation.instance.selected,
            builder: (context, selected, _) => ValueListenableBuilder<bool>(valueListenable: DashboardDrag.active,
            builder: (context, dragging, _) {

              return DragTarget<DashboardDrag>(
                key: _dropKey,
                onWillAcceptWithDetails: (_) {
                  DashboardDrag.overNavigation.value = true;
                  return !_saving;
                },
                onMove: (_) => DashboardDrag.overNavigation.value = true,
                onLeave: (_) => DashboardDrag.overNavigation.value = false,
                onAcceptWithDetails: (details) async {
                  final id=ShortcutTransfer.canonical(details.data.id,'bottom');
                  final items=AppPreferences.instance.value.bottomShortcuts;
                  final box=_dropKey.currentContext!.findRenderObject() as RenderBox;
                  final fraction=(box.globalToLocal(DashboardDrag.position??details.offset).dx/box.size.width).clamp(0.0,1.0);
                  final index=((Directionality.of(context)==TextDirection.rtl?1-fraction:fraction)*items.length).round();
                  if(!items.contains(id) && items.length<5) {
                    final destination=box.localToGlobal(Offset(box.size.width*(index+.5)/(items.length+1),28));
                    _arriving=id;
                    _arrivalOffset=(DashboardDrag.position??details.offset)-const Offset(52,0)-destination;
                  }
                  final message=await ShortcutTransfer.put('bottom',details.data.id,
                    before:index<items.length?items[index]:null,reorder:details.data.source=='bottom');
                  if(message!=null && context.mounted) { ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content:Text(context.t(message)))); }
                },
                builder: (context, candidates, rejected) => Material(
                  key: const ValueKey('navigation-add-target'),
                  color: candidates.isEmpty ? Theme.of(context).colorScheme.surfaceContainer : Theme.of(context).colorScheme.primaryContainer,
              child: SafeArea(top: false, child: SizedBox(height: 56, child: Row(children: [
                for (final (index,id) in preferences.bottomShortcuts.indexed) ...[
                  if(preferences.bottomShortcuts.length<2 && index==preferences.bottomShortcuts.length-1) Expanded(child: IconButton(
                    key: const ValueKey('navigation-add'), tooltip: context.t('navigationCustomize'),
                    onPressed: _chooseShortcuts,icon: const Icon(Icons.add))),
                  Expanded(child: Builder(builder: (context) {
                  final destination = AppDestination.values.where((d) => d.name == id).firstOrNull;
                  final active = selected == destination;
                  final colors = Theme.of(context).colorScheme;
                  final enabled = store.ready || id == 'meal' || id == 'listen' || id == 'support' || destination == AppDestination.home || destination == AppDestination.history || destination == AppDestination.settings || destination == AppDestination.exit;
                  Widget icon({bool hovered = false}) => AnimatedContainer(
                    key: ValueKey('navigation-$id'), duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: active || hovered ? colors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(24)),
                    child: AnimatedScale(scale: active ? 1.08 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: destination == AppDestination.hatim
                      ? Opacity(opacity: enabled ? 1 : .4, child: const QuranArtwork(size: 28, decorative: true))
                      : Icon(bottomShortcutIcon(id), color: enabled
                          ? active ? colors.onPrimaryContainer : colors.onSurfaceVariant : Theme.of(context).disabledColor)));
                  return TweenAnimationBuilder<double>(
                    key: ValueKey('navigation-arrival-$id'),
                    tween: Tween(begin: _arriving == id ? 0 : 1, end: 1),
                    duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 380),
                    curve: Curves.easeOutCubic,
                    onEnd: () { if (_arriving == id) _arriving = null; },
                    builder: (context, progress, child) => Transform.translate(
                      offset: _arriving == id ? _arrivalOffset * (1 - progress) : Offset.zero,
                      child: Transform.scale(scale: _arriving == id ? 1 + .18 * (1 - progress) : 1, child: child)),
                    child: DragTarget<DashboardDrag>(
                    onWillAcceptWithDetails: (details) => details.data.id != id,
                    onAcceptWithDetails: (details) async {
                      final message=await ShortcutTransfer.put('bottom',details.data.id,before:id,
                        reorder:details.data.source=='bottom');
                      if(message!=null && context.mounted) { ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        SnackBar(content:Text(context.t(message)))); }
                    },
                    builder: (context, candidates, rejected) => LongPressDraggable<DashboardDrag>(
                      data: DashboardDrag(id=='search'?'page':id, source:'bottom'), maxSimultaneousDrags: _saving ? 0 : 1,
                      onDragStarted: () => _startDrag(id), onDragEnd: (_) => _endDrag(),
                      feedback: Material(elevation: 8, color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(28), child: Padding(padding: const EdgeInsets.all(16),
                          child: destination == AppDestination.hatim
                            ? const QuranArtwork(size: 28, decorative: true)
                            : Icon(bottomShortcutIcon(id), color: colors.onPrimaryContainer))),
                      childWhenDragging: Opacity(opacity: .25, child: Center(child: icon())),
                      child: Semantics(button: true, selected: active, label: bottomShortcutLabel(context, id),
                        child: InkWell(onTap: enabled ? () { if (destination != null) { AppNavigation.instance.open?.call(destination); } else { AppNavigation.instance.openCard?.call(id); } } : null,
                          child: SizedBox(height: 56, child: Center(child: icon(hovered: candidates.isNotEmpty))))),
                    ),
                  ));
                })),
                ],
                if(preferences.bottomShortcuts.isEmpty) Expanded(child: IconButton(
                  key: const ValueKey('navigation-add'),tooltip: context.t('navigationCustomize'),
                  onPressed: _chooseShortcuts,icon: const Icon(Icons.add))),
              ])))));
            }));
        });
    });
}

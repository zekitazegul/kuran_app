import 'motif_surface.dart';
import '../services/shortcut_transfer.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/app_preferences.dart';
import '../data/surahs.dart';
import 'shortcut_drag.dart';
export 'shortcut_drag.dart' show DashboardDrag;

class DashboardCards extends StatefulWidget {
  final Map<String, Widget> cards;
  final bool personal;
  final int personalPage;
  final ScrollController scrollController;
  const DashboardCards({super.key, required this.cards, required this.scrollController, this.personal = false, this.personalPage = 0});
  @override
  State<DashboardCards> createState() => _DashboardCardsState();
}
class _DashboardCardsState extends State<DashboardCards> {
  List<String> _order(UiPreferences prefs) => widget.personal
    ? widget.personalPage < prefs.personalPages.length ? prefs.personalPages[widget.personalPage] : const []
    : prefs.dashboardOrder;
  bool _saving = false;
  OverlayEntry? _trash;
  Timer? _scrollTimer;
  Offset? _dragPosition;
  Future<void> _add() async {
    final prefs = AppPreferences.instance.value;
    final hidden = prefs.availableDashboardCards.where((id) => widget.cards.containsKey(id) && !_order(prefs).contains(id)).toList();
    final id = await showModalBottomSheet<String>(context: context, isScrollControlled: true,
      builder: (context) => MotifSurface(menu:true,child:SafeArea(child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .7),
        child: ListView(shrinkWrap: true, children: [
          ListTile(title: Text(context.t('Kısayol ekle'), style: const TextStyle(fontWeight: FontWeight.w700))),
          for (final id in hidden) ListTile(leading: const Icon(Icons.add_circle_outline),
            title: Text(dashboardCardLabels.containsKey(id) ? context.t(dashboardCardLabels[id]!)
              : id.startsWith('surah:') ? surahName(surahs[int.parse(id.split(':').last) - 1], context.language)
              : context.t('Cüz {number}', {'number': id.split(':').last})),
            onTap: () => Navigator.pop(context, id)),
          if (hidden.isEmpty) ListTile(title: Text(context.t('Tüm kısayollar eklendi.'))),
        ])))));
    if (id != null && mounted) await _save([..._order(AppPreferences.instance.value), id]);
  }
  Future<void> _accept(DashboardDrag drag,{String? before}) async {
    try {
      final message=await ShortcutTransfer.put('home',drag.id,before:before,reorder:drag.source=='home');
      if(message!=null && mounted) { ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text(context.t(message)))); }
    } catch (_) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.t('Tercih kaydedilemedi.'))));
    }
  }
  Future<void> _save(List<String> order) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final prefs = AppPreferences.instance.value;
      final pages = [...prefs.personalPages];
      if (widget.personal) {
        final duplicate = order.toSet().length != order.length || order.any((id) =>
          pages.asMap().entries.any((entry) => entry.key != widget.personalPage && entry.value.contains(id)));
        if (duplicate) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('screenAlreadyAdded'))));
          return;
        }
        while (pages.length <= widget.personalPage) { pages.add([]); }
        pages[widget.personalPage] = order;
      }
      await AppPreferences.instance.save(prefs.copyWith(dashboardCards: widget.personal ? null : order,
        personalPages: widget.personal ? pages : null));
    }
    catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Tercih kaydedilemedi.'))));
    } finally { if (mounted) setState(() => _saving = false); }
  }
  void _start() {
    DashboardDrag.active.value = true;
    final size = MediaQuery.sizeOf(context);
    _trash = OverlayEntry(builder: (_) => Positioned(top: MediaQuery.paddingOf(context).top + 16, right: 16,
      child: Center(child: DragTarget<DashboardDrag>(
        onAcceptWithDetails: (details) => _save(_order(AppPreferences.instance.value).where((id) => id != details.data.id).toList()),
        builder: (context, candidates, rejected) => Material(
          key: const ValueKey('dashboard-trash'), elevation: 8, borderRadius: BorderRadius.circular(40),
          color: candidates.isEmpty ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.error,
          child: SizedBox(width: 80, height: 80, child: Icon(Icons.delete_outline,
            size: 32, color: candidates.isEmpty ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onError))),
      ))));
    Overlay.of(context).insert(_trash!);
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      final position = _dragPosition;
      final controller = widget.scrollController;
      if (!mounted || position == null || !controller.hasClients) return;
      final distance = position.dy < 110 ? -16.0 : position.dy > size.height - 150 ? 16.0 : 0.0;
      if (distance != 0) controller.jumpTo((controller.offset + distance).clamp(0.0, controller.position.maxScrollExtent));
    });
  }
  void _end() {
    DashboardDrag.active.value = false;
    DashboardDrag.overNavigation.value = false;
    DashboardDrag.position = null;
    _scrollTimer?.cancel(); _scrollTimer = null; _dragPosition = null;
    _trash?.remove(); _trash?.dispose(); _trash = null;
  }
  @override
  void dispose() { _end(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<UiPreferences>(
    valueListenable: AppPreferences.instance,
    builder: (context, preferences, _) => DragTarget<DashboardDrag>(key:const ValueKey('home-drop'),
      onWillAcceptWithDetails:(_)=>!widget.personal,
      onAcceptWithDetails:(details)=>_accept(details.data),
      builder:(context,candidates,rejected)=>LayoutBuilder(builder: (context, constraints) => Column(children: [
      for (final id in _order(preferences).where(widget.cards.containsKey))
        DragTarget<DashboardDrag>(key: ValueKey('dashboard-card-$id'),
          onWillAcceptWithDetails: (details) => details.data.id != id,
          onAcceptWithDetails: (details) {
            if(!widget.personal && details.data.source!='home') { _accept(details.data,before:id); return; }
            final order = [..._order(AppPreferences.instance.value)];
            final from = order.indexOf(details.data.id);
            final to = order.indexOf(id);
            if (from >= 0 && to >= 0) { order.insert(to, order.removeAt(from)); _save(order); }
          },
          builder: (context, candidates, rejected) => LongPressDraggable<DashboardDrag>(
            data: DashboardDrag(id), maxSimultaneousDrags: _saving ? 0 : 1,
            onDragStarted: _start, onDragUpdate: (details) { _dragPosition = details.globalPosition; DashboardDrag.position = details.globalPosition; },
            onDragEnd: (_) => _end(),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: DashboardDragFeedback(id: id, width: constraints.maxWidth, card: widget.cards[id]!),
            childWhenDragging: Opacity(opacity: .25, child: widget.cards[id]),
            child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
              border: Border.all(color: candidates.isEmpty ? Colors.transparent : Theme.of(context).colorScheme.primary, width: 2)),
              child: widget.cards[id]),
          ),
        ),
      Align(alignment: Alignment.centerRight, child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (_order(preferences).where(widget.cards.containsKey).isEmpty)
          Padding(padding: const EdgeInsets.only(right: 8), child: Text(context.t('K\u0131sayol ekle'))),
        IconButton.filledTonal(
        key: const ValueKey('dashboard-add'), tooltip: context.t('Kısayol ekle'),
        onPressed: _saving ? null : _add, icon: const Icon(Icons.add)),
      ])),
    ]))),
  );
}

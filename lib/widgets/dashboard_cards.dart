import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/app_preferences.dart';
import '../data/surahs.dart';

class _DashboardDrag {
  final String id;
  const _DashboardDrag(this.id);
}

class DashboardCards extends StatefulWidget {
  final Map<String, Widget> cards;
  final ScrollController scrollController;
  const DashboardCards({super.key, required this.cards, required this.scrollController});
  @override
  State<DashboardCards> createState() => _DashboardCardsState();
}
class _DashboardCardsState extends State<DashboardCards> {
  bool _saving = false;
  OverlayEntry? _trash;
  Timer? _scrollTimer;
  Offset? _dragPosition;
  Future<void> _add() async {
    final prefs = AppPreferences.instance.value;
    final hidden = prefs.availableDashboardCards.where((id) => !prefs.dashboardOrder.contains(id)).toList();
    final id = await showModalBottomSheet<String>(context: context, isScrollControlled: true,
      builder: (context) => SafeArea(child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .7),
        child: ListView(shrinkWrap: true, children: [
          ListTile(title: Text(context.t('Kısayol ekle'), style: const TextStyle(fontWeight: FontWeight.w700))),
          for (final id in hidden) ListTile(leading: const Icon(Icons.add_circle_outline),
            title: Text(dashboardCardLabels.containsKey(id) ? context.t(dashboardCardLabels[id]!)
              : id.startsWith('surah:') ? surahName(surahs[int.parse(id.split(':').last) - 1], context.language)
              : context.t('Cüz {number}', {'number': id.split(':').last})),
            onTap: () => Navigator.pop(context, id)),
          if (hidden.isEmpty) ListTile(title: Text(context.t('Tüm kısayollar eklendi.'))),
        ]))));
    if (id != null && mounted) await _save([...AppPreferences.instance.value.dashboardOrder, id]);
  }
  Future<void> _save(List<String> order) async {
    if (_saving) return;
    setState(() => _saving = true);
    try { await AppPreferences.instance.save(AppPreferences.instance.value.copyWith(dashboardCards: order)); }
    catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Tercih kaydedilemedi.'))));
    } finally { if (mounted) setState(() => _saving = false); }
  }
  void _start() {
    final size = MediaQuery.sizeOf(context);
    _trash = OverlayEntry(builder: (_) => Positioned(bottom: 88, left: 0, right: 0,
      child: Center(child: DragTarget<_DashboardDrag>(
        onAcceptWithDetails: (details) => _save(AppPreferences.instance.value.dashboardOrder.where((id) => id != details.data.id).toList()),
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
    _scrollTimer?.cancel(); _scrollTimer = null; _dragPosition = null;
    _trash?.remove(); _trash?.dispose(); _trash = null;
  }
  @override
  void dispose() { _end(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<UiPreferences>(
    valueListenable: AppPreferences.instance,
    builder: (context, preferences, _) => LayoutBuilder(builder: (context, constraints) => Column(children: [
      for (final id in preferences.dashboardOrder.where(widget.cards.containsKey))
        DragTarget<_DashboardDrag>(key: ValueKey('dashboard-card-$id'),
          onWillAcceptWithDetails: (details) => details.data.id != id,
          onAcceptWithDetails: (details) {
            final order = [...AppPreferences.instance.value.dashboardOrder];
            final from = order.indexOf(details.data.id);
            final to = order.indexOf(id);
            if (from >= 0 && to >= 0) { order.insert(to, order.removeAt(from)); _save(order); }
          },
          builder: (context, candidates, rejected) => LongPressDraggable<_DashboardDrag>(
            data: _DashboardDrag(id), maxSimultaneousDrags: _saving ? 0 : 1,
            onDragStarted: _start, onDragUpdate: (details) => _dragPosition = details.globalPosition,
            onDragEnd: (_) => _end(),
            feedback: SizedBox(width: constraints.maxWidth, child: Material(
              elevation: 8, borderRadius: BorderRadius.circular(16), child: widget.cards[id])),
            childWhenDragging: Opacity(opacity: .25, child: widget.cards[id]),
            child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
              border: Border.all(color: candidates.isEmpty ? Colors.transparent : Theme.of(context).colorScheme.primary, width: 2)),
              child: widget.cards[id]),
          ),
        ),
      Align(alignment: Alignment.centerRight, child: IconButton.filledTonal(
        key: const ValueKey('dashboard-add'), tooltip: context.t('Kısayol ekle'),
        onPressed: _saving ? null : _add, icon: const Icon(Icons.add))),
    ])),
  );
}

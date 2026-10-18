import 'screen_title.dart';
import 'personal_page_scope.dart';
import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/app_preferences.dart';
import '../screens/about_screen.dart';
import '../screens/support_screen.dart';
import '../screens/sources_screen.dart';
import 'dashboard_cards.dart';
import 'app_bottom_bar.dart';

class HomePages extends StatefulWidget {
  final Widget dashboard;
  final Map<String, Widget> cards;
  final PageController controller;
  final Map<String, WidgetBuilder> features;
  final ValueChanged<int>? onPageChanged;
  const HomePages({super.key, required this.dashboard, required this.cards, required this.controller, this.features = const {}, this.onPageChanged});
  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  int _selected = 1;
  bool _dragging = false;
  bool _saving = false;
  @override
  void initState() { super.initState(); _selected = widget.controller.initialPage; }

  Future<void> _deletePage(int index) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final prefs = AppPreferences.instance.value;
      final pages = [...prefs.personalPages];
      if (index >= pages.length) return;
      pages.removeAt(index);
      widget.controller.jumpToPage(1);
      await AppPreferences.instance.save(prefs.copyWith(personalPages: pages));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Tercih kaydedilemedi.'))));
    } finally {
      if (mounted) setState(() { _saving = false; _dragging = false; });
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([AppPreferences.instance, AppNavigation.instance.fullscreenReader, AppNavigation.instance.fullscreenMeal]),
    builder: (context, _) {
      final prefs = AppPreferences.instance.value;
      final pages = [...prefs.personalPages];
      if (pages.isEmpty || pages.last.isNotEmpty) pages.add([]);
      final index = _selected - 2;
      final activeId = index >= 0 && index < pages.length && pages[index].isNotEmpty ? pages[index].first : null;
      final reading = activeId == 'listen' || activeId == 'meal' || activeId == 'hatim' || activeId == 'search' || (activeId?.contains(':') ?? false);
      final fullscreen = reading && (AppNavigation.instance.fullscreenReader.value != null || AppNavigation.instance.fullscreenMeal.value != null);
      final labels = [context.t('homeInformation'), context.t('Ana sayfa'),
        for (var i = 0; i < pages.length; i++) context.t('personalPageNumber', {'number': i + 1})];
      return SafeArea(top: !fullscreen, bottom: false, child: Stack(children: [Column(children: [
        if (!fullscreen) SizedBox(height: 40, child: Center(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          for (var i = 0; i < labels.length; i++)
            Semantics(selected: i == _selected, child: IconButton(
              tooltip: labels[i],
              visualDensity: VisualDensity.compact,
              onPressed: _dragging ? null : () => widget.controller.animateToPage(i,
                duration: const Duration(milliseconds: 280), curve: Curves.easeOut),
              icon: Icon(i == _selected ? Icons.circle : Icons.circle_outlined, size: 8),
            )),
        ])))),
        Expanded(child: PageView(controller: widget.controller,
          physics: _dragging || reading ? const NeverScrollableScrollPhysics() : null,
          onPageChanged: (page) {
            AppNavigation.instance.exitFullscreen();
            setState(() => _selected = page);
            widget.onPageChanged?.call(page);
          },
          children: [
            Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(padding: const EdgeInsets.all(20), children: [
                ScreenTitle(context, context.t('homeInformation')),
                const SizedBox(height: 16),
                for (final entry in <(String, IconData, Widget)>[
                  ('Uygulama hakkında', Icons.info_outline, const AboutScreen()),
                  ('Destek', Icons.favorite_outline, const SupportScreen()),
                  ('Kaynaklar ve telif bilgileri', Icons.menu_book_outlined, const SourcesScreen()),
                ]) Card(child: ListTile(leading: Icon(entry.$2), title: Text(context.t(entry.$1)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => entry.$3)))),
              ]))),
            widget.dashboard,
            for (var i = 0; i < pages.length; i++)
              _PersonalPage(key: ValueKey('personal-page-$i-${pages[i].join()}'), index: i, cards: widget.cards,
                featureId: pages[i].isEmpty ? null : pages[i].first, features: widget.features,
                fullscreen: fullscreen,
                canDelete: i < prefs.personalPages.length && !_saving,
                onDragStarted: () => setState(() => _dragging = true),
                onDragEnded: () { if (mounted) setState(() => _dragging = false); }),
          ])),
      ]),
      if (_dragging) Positioned(top: 0, right: 16, child: DragTarget<int>(
        onAcceptWithDetails: (details) => _deletePage(details.data),
        builder: (context, candidates, rejected) => Tooltip(message: context.t('deletePersonalPage'),
          child: Material(key: const ValueKey('page-trash'), elevation: 8,
            color: candidates.isEmpty ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(40),
            child: SizedBox(width: 64, height: 64, child: Icon(Icons.delete_outline,
              color: candidates.isEmpty ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onError)))),
      )),
    ]));
    },
  );
}

class _PersonalPage extends StatefulWidget {
  final int index;
  final Map<String, Widget> cards;
  final bool canDelete;
  final bool fullscreen;
  final String? featureId;
  final Map<String, WidgetBuilder> features;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  const _PersonalPage({super.key, required this.index, required this.cards,
    required this.canDelete, required this.onDragStarted, required this.onDragEnded, required this.featureId, required this.features, required this.fullscreen});
  @override
  State<_PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<_PersonalPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _scroll = ScrollController();
  final _readerTitle = ValueNotifier<String?>(null);
  @override
  void dispose() { _scroll.dispose(); _readerTitle.dispose(); super.dispose(); }
  void _navigate(int delta) {
    final controller = context.findAncestorWidgetOfExactType<HomePages>()!.controller;
    if (!controller.hasClients) return;
    final target = (controller.page!.round() + delta).clamp(0,
      (controller.position.maxScrollExtent / controller.position.viewportDimension).round());
    controller.animateToPage(target, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final feature = widget.features[widget.featureId];
    final title = feature == null ? context.t('personalPageNumber', {'number': widget.index + 1})
      : context.t(widget.featureId == 'bookmarks' ? 'Ayraçlar' : dashboardCardLabels[widget.featureId] ?? widget.featureId!);
    final heading = SizedBox(height: 48, child: Row(children: [
      const Icon(Icons.drag_indicator, size: 24),
      const SizedBox(width: 12),
      Expanded(child: ValueListenableBuilder<String?>(valueListenable: _readerTitle,
        builder: (context, surah, _) => Row(children: [
          Expanded(child: ScreenTitle(context, title)),
          if (surah != null) Flexible(child: ScreenTitle(context, surah, key: const ValueKey('personal-reader-surah'), textAlign: TextAlign.end)),
        ]))),
    ]));
    final handle = PersonalPageSwipe(onNavigate: _navigate, child: LongPressDraggable<int>(key: ValueKey('personal-page-handle-${widget.index}'),
      data: widget.index, maxSimultaneousDrags: widget.canDelete ? 1 : 0,
      onDragStarted: widget.onDragStarted, onDragEnd: (_) => widget.onDragEnded(),
      feedback: Material(elevation: 8, borderRadius: BorderRadius.circular(16),
        child: Padding(padding: const EdgeInsets.all(20), child: ScreenTitle(context, title))),
      childWhenDragging: Opacity(opacity: .3, child: heading), child: heading));
    if (feature != null) {
      return Column(children: [if (!widget.fullscreen && widget.featureId != 'meal') Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: handle),
        Expanded(child: PersonalPageScope(heading: handle, readerTitle: _readerTitle, navigate: _navigate, child: Builder(builder: feature)))]);
    }
    return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680),
      child: ListView(controller: _scroll, padding: const EdgeInsets.all(20), children: [
        handle,
        Text(context.t('personalPageHint')),
        const SizedBox(height: 16),
        DashboardCards(personal: true, personalPage: widget.index, scrollController: _scroll, cards: widget.cards),
      ])));
  }
}

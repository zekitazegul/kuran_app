import '../services/voice_control.dart';
import 'motif_surface.dart';
import '../services/shortcut_transfer.dart';
import 'shortcut_drag.dart';
import '../screens/personalization_screen.dart';
import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/app_preferences.dart';
import 'language_selector.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key, required this.onMenu, this.onVoice});
  final VoidCallback onMenu;
  final VoidCallback? onVoice;
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(height: 56, child: Row(children: [
          DragTarget<DashboardDrag>(key:const ValueKey('menu-open-drop'),
            onWillAcceptWithDetails: (_) { Future.microtask(onMenu); return true; },
            onAcceptWithDetails: (details) async {
              final message=await ShortcutTransfer.put('menu',details.data.id);
              if(message!=null && context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content:Text(context.t(message)))); }
            },
            builder:(context,candidates,rejected)=>IconButton(key: const ValueKey('home-menu'),
              tooltip: context.t('homeMenu'), onPressed: onMenu, icon: const Icon(Icons.menu))),
          Tooltip(message:context.t('voiceCommand'),triggerMode:TooltipTriggerMode.manual,child:GestureDetector(onLongPress:VoiceControl.help,child:IconButton(key: const ValueKey('home-voice'), 
            onPressed: onVoice, icon: const Icon(Icons.mic_none)))),
          const Expanded(child: Align(alignment: Alignment.centerLeft,
            child: FittedBox(fit: BoxFit.scaleDown, child: Text('KuranApp',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700))))),
          const LanguageSelector(),
        ])),
      )),
  );
}

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key, required this.preferences, required this.shortcutName,
    required this.onSelected, this.ready = true});
  final UiPreferences preferences;
  final String Function(HomeShortcut) shortcutName;
  final ValueChanged<String> onSelected;
  final bool ready;
  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  bool _saving = false;
  OverlayEntry? _trash;
  String? _notice;
  void _endDrag() {
    _trash?.remove();_trash?.dispose();_trash=null;
    DashboardDrag.active.value=false;
  }
  void _startDrag(String id) {
    DashboardDrag.active.value=true;
    _trash=OverlayEntry(builder:(context)=>Positioned(top:MediaQuery.paddingOf(context).top+12,right:12,
      child:DragTarget<DashboardDrag>(onAcceptWithDetails:(_)=>ShortcutTransfer.remove('menu',id),
        builder:(context,candidates,rejected)=>Material(key:const ValueKey('menu-trash'),
          color:Theme.of(context).colorScheme.errorContainer,borderRadius:BorderRadius.circular(40),
          child:SizedBox(width:80,height:80,child:Tooltip(message:context.t('shortcutDelete'),
            child:const Icon(Icons.delete_outline,size:32)))))));
    Overlay.of(context).insert(_trash!);
  }
  Future<void> _accept(DashboardDrag drag,{String? before}) async {
    try {
      final message=await ShortcutTransfer.put('menu',drag.id,before:before,reorder:drag.source=='menu');
      if(mounted) setState(()=>_notice=message);
    } catch (_) { if(mounted) setState(()=>_notice='Tercih kaydedilemedi.'); }
  }
  @override
  void dispose() { _endDrag();super.dispose(); }

  Future<void> _save(UiPreferences preferences) async {
    if (_saving) { return; }
    setState(() => _saving = true);
    try { await AppPreferences.instance.save(preferences); }
    catch (_) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('Tercih kaydedilemedi.')))); }
    } finally { if (mounted) setState(() => _saving = false); }
  }
  Future<void> _addShortcut() async {
    final current=AppPreferences.instance.value;
    final hidden=current.availableDashboardCards.where((id)=>!current.menuOrder.contains(id)).toList();
    if(hidden.isNotEmpty) {
      final picked=await showModalBottomSheet<String>(context:context,builder:(context)=>SafeArea(
        child:ListView(shrinkWrap:true,children:[
          for(final id in hidden) ListTile(title:Text(dashboardCardLabels.containsKey(id)?context.t(dashboardCardLabels[id]!):widget.shortcutName(current.shortcuts.firstWhere((s)=>s.id==id))),
            leading:const Icon(Icons.add),onTap:()=>Navigator.pop(context,id)),
          ListTile(key:const ValueKey('menu-new-custom'),title:Text(context.t('K\u0131sayol ekle')),
            leading:const Icon(Icons.menu_book_outlined),onTap:()=>Navigator.pop(context,'custom')),
        ])));
      if(picked==null || !mounted) return;
      if(picked!='custom') {
        await _save(current.copyWith(menuCards:[...current.menuOrder,picked]));return;
      }
    }
    final shortcut=await showModalBottomSheet<HomeShortcut>(context:context,
      isScrollControlled:true,builder:(_)=>const ShortcutPicker());
    if(shortcut==null || !mounted) return;
    final prefs=AppPreferences.instance.value;
    if(prefs.shortcuts.any((s)=>s.id==shortcut.id)) {
      if(prefs.menuOrder.contains(shortcut.id)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.t('shortcutAlreadyHere'))));
      } else { await _save(prefs.copyWith(menuCards:[...prefs.menuOrder,shortcut.id])); }
      return;
    }
    if(prefs.shortcuts.length>=24) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.t('En fazla 24 k\u0131sayol ekleyebilirsin.'))));
      return;
    }
    await _save(prefs.copyWith(shortcuts:[...prefs.shortcuts,shortcut],
      dashboardCards:prefs.dashboardOrder,menuCards:[...prefs.menuOrder,shortcut.id]));
  }
  @override
  Widget build(BuildContext context) {
    final preferences = widget.preferences;
    const icons = {'home': Icons.home_outlined, 'exit': Icons.arrow_back_rounded,
      'page': Icons.numbers_rounded, 'search': Icons.search, 'meal': Icons.menu_book_outlined,
      'bookmarks': Icons.bookmarks_outlined, 'hatim': Icons.auto_stories_outlined,
      'history': Icons.history, 'settings': Icons.settings_outlined,
      'support': Icons.support_agent};
    final custom = {for (final shortcut in preferences.shortcuts) shortcut.id: shortcut};
    final order = preferences.menuOrder
      .where((id) => id != 'settings' && id != 'support' &&
        (dashboardCardLabels.containsKey(id) || custom.containsKey(id))).toList();
    IconData iconFor(String id) => icons[id] ?? (custom[id]?.kind == ShortcutKind.juz
      ? Icons.library_books_outlined : Icons.article_outlined);
    Widget item(String id) {
      final tile = ListTile(
        leading: Icon(iconFor(id)),
        title: Text(id == 'support' ? context.t('Destek ve geri bildirim')
          : custom.containsKey(id) ? widget.shortcutName(custom[id]!) : context.t(dashboardCardLabels[id]!)),
        onTap: widget.ready || id == 'settings' || id == 'support' ? () => widget.onSelected(id) : null,

      );
      return DragTarget<DashboardDrag>(key:ValueKey('home-menu-$id'),
        onWillAcceptWithDetails:(_)=>true,
        onAcceptWithDetails:(details)=>_accept(details.data,before:id),
        builder:(context,candidates,rejected)=>LongPressDraggable<DashboardDrag>(
          data:DashboardDrag(id,source:'menu'),maxSimultaneousDrags:_saving?0:1,
          onDragStarted:()=>_startDrag(id),onDragEnd:(_)=>_endDrag(),
          onDragUpdate:(details)=>DashboardDrag.position=details.globalPosition,
          feedback:Material(elevation:8,borderRadius:BorderRadius.circular(20),
            child:Padding(padding:const EdgeInsets.all(16),child:Icon(iconFor(id)))),
          childWhenDragging:Opacity(opacity:.3,child:tile),child:tile));
    }
    return DragTarget<DashboardDrag>(key:const ValueKey('menu-drop'),
      onWillAcceptWithDetails:(_)=>true,onAcceptWithDetails:(details)=>_accept(details.data),
      builder:(context,candidates,rejected)=>Drawer(width: (MediaQuery.sizeOf(context).width * .94).clamp(0.0, 400.0),
      child: MotifSurface(menu:true,child:SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('KuranApp', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700))),
        const Divider(height: 1),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8), itemCount: order.length,
          itemBuilder: (context, index) => item(order[index]))),
        ValueListenableBuilder<bool>(valueListenable:DashboardDrag.active,builder:(context,dragging,_)=>
          !dragging?const SizedBox.shrink():DragTarget<DashboardDrag>(key:const ValueKey('menu-home-drop'),
            onAcceptWithDetails:(details) async {
              final message=await ShortcutTransfer.put('home',details.data.id);
              if(mounted) setState(()=>_notice=message);
            },builder:(context,candidates,rejected)=>ListTile(leading:const Icon(Icons.home_outlined),
              title:Text(context.t('shortcutAddHome')),tileColor:candidates.isEmpty?null:
                Theme.of(context).colorScheme.primaryContainer))),
        Align(alignment:Alignment.centerRight,child:IconButton.filledTonal(
          key:const ValueKey('menu-add'),tooltip:context.t('K\u0131sayol ekle'),
          onPressed:_saving?null:_addShortcut,icon:const Icon(Icons.add))),
        if(_notice!=null) Padding(padding:const EdgeInsets.all(8),child:Text(context.t(_notice!),
          style:TextStyle(color:Theme.of(context).colorScheme.error))),
        const Divider(height: 1),
        if(preferences.menuOrder.contains('settings')) item('settings'),
        if(preferences.menuOrder.contains('support')) item('support'),
      ]))),
    ));
  }
}

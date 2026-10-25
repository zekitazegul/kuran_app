import 'app_preferences.dart';

/// Each surface keeps its own copy; dropping onto another surface adds one copy.
class ShortcutTransfer {
  static String canonical(String id, String area) => area=='bottom'
    ? id=='search' ? 'surahs' : id=='page' ? 'search' : id
    : id=='surahs' ? 'search' : id;
  static List<String> items(UiPreferences prefs,String area) => [...switch(area) {
    'bottom'=>prefs.bottomShortcuts,'menu'=>prefs.menuOrder,_=>prefs.dashboardOrder,
  }];
  static Future<String?> put(String area,String id,{String? before, bool reorder=false}) async {
    final prefs=AppPreferences.instance.value;
    id=canonical(id,area);
    final order=items(prefs,area);
    final originalTarget=before==null ? -1 : order.indexOf(canonical(before,area));
    if(order.contains(id)) {
      if(!reorder) return 'shortcutAlreadyHere';
      order.remove(id);
    } else if(area=='bottom' && order.length>=5) { return 'shortcutLimit'; }
    final target=before==null ? -1 : order.indexOf(canonical(before,area));
    final insert=reorder && originalTarget>=0 ? originalTarget.clamp(0,order.length) : target<0 ? order.length : target;
    order.insert(insert,id);
    await save(area,order);
    return null;
  }
  static Future<void> remove(String area,String id) => save(area,
    items(AppPreferences.instance.value,area)..remove(canonical(id,area)));
  static Future<void> save(String area,List<String> order) async {
    final prefs=AppPreferences.instance.value;
    await AppPreferences.instance.save(switch(area) {
      'bottom'=>prefs.copyWith(bottomShortcuts:order),
      'menu'=>prefs.copyWith(menuCards:order),
      _=>prefs.copyWith(dashboardCards:order),
    });
  }
}

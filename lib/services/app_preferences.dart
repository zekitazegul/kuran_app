import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ShortcutKind { surah, juz }

const dashboardCardLabels = {
  'hatim': 'Hatim',
  'meal': 'Meal Oku', 'listen': "Kur'an dinle", 'history': 'Okuma geçmişi',
  'search': 'Sure, cüz, sayfa', 'bookmarks': 'Ayraçlarım', 'support': 'Destek', 'settings': 'Ayarlar',
};

class HomeShortcut {
  final ShortcutKind kind;
  final int number;
  const HomeShortcut(this.kind, this.number);
  String get id => '${kind.name}:$number';
  int get firstPage => number == 1 ? 0 : (number - 1) * 20 + 1;
  Map<String, Object> toMap() => {'kind': kind.name, 'number': number};
  static HomeShortcut? fromMap(dynamic value) {
    if (value is! Map || value['number'] is! int) return null;
    final number = value['number'] as int;
    if (value['kind'] == 'surah' && number >= 1 && number <= 114) {
      return HomeShortcut(ShortcutKind.surah, number);
    }
    if (value['kind'] == 'juz' && number >= 1 && number <= 30) {
      return HomeShortcut(ShortcutKind.juz, number);
    }
    return null;
  }
}

class UiPreferences {
  static const colors = <String, Color>{
    'green': Color(0xFF164D43), 'blue': Color(0xFF245A88),
    'purple': Color(0xFF76517D), 'amber': Color(0xFF88601F),
  };
  static const defaults = [HomeShortcut(ShortcutKind.surah, 48), HomeShortcut(ShortcutKind.surah, 36)];
  final ThemeMode themeMode;
  final String color;
  final List<HomeShortcut> shortcuts;
  static const defaultBottomShortcuts = ['exit', 'bookmarks', 'surahs', 'history', 'home'];
  static const availableBottomShortcuts = ['home', 'bookmarks', 'surahs', 'history', 'settings', 'search', 'hatim', 'exit'];
  final List<String> bottomShortcuts;
  final List<String>? dashboardCards;
  List<String> get availableDashboardCards => [...dashboardCardLabels.keys, ...shortcuts.map((s) => s.id)];
  List<String> get dashboardOrder => dashboardCards ?? [
    'hatim', 'search', 'bookmarks', 'support', 'settings'];
  const UiPreferences({this.themeMode = ThemeMode.system, this.color = 'green', this.shortcuts = defaults,
    this.bottomShortcuts = defaultBottomShortcuts, this.dashboardCards});
  Color get seed => colors[color] ?? colors['green']!;
  UiPreferences copyWith({ThemeMode? themeMode, String? color, List<HomeShortcut>? shortcuts, List<String>? bottomShortcuts, List<String>? dashboardCards}) =>
    UiPreferences(themeMode: themeMode ?? this.themeMode, color: color ?? this.color,
      shortcuts: List.unmodifiable(shortcuts ?? this.shortcuts), bottomShortcuts: List.unmodifiable(bottomShortcuts ?? this.bottomShortcuts),
      dashboardCards: dashboardCards != null ? List.unmodifiable(dashboardCards) : this.dashboardCards == null && shortcuts == null ? null : List.unmodifiable([
        ...dashboardOrder.where((id) => dashboardCardLabels.containsKey(id) || (shortcuts ?? this.shortcuts).any((s) => s.id == id)),
        if (shortcuts != null) ...shortcuts.where((s) => !this.shortcuts.any((old) => old.id == s.id)).map((s) => s.id),
      ]));
  Map<String, Object> toMap() => {'theme': themeMode.name, 'color': color,
    'shortcuts': shortcuts.map((s) => s.toMap()).toList(), 'bottomShortcuts': bottomShortcuts, 'navigationVersion': 2,
    'dashboardCards': dashboardOrder, 'dashboardVersion': 1};
  factory UiPreferences.fromMap(Map<dynamic, dynamic>? data) {
    if (data == null) return const UiPreferences();
    final modes = ThemeMode.values.where((m) => m.name == data['theme']);
    final parsed = <HomeShortcut>[];
    if (data['shortcuts'] is List) {
      for (final entry in data['shortcuts'] as List) {
        final shortcut = HomeShortcut.fromMap(entry);
        if (shortcut != null && !parsed.any((s) => s.id == shortcut.id) && parsed.length < 24) parsed.add(shortcut);
      }
    }
    final bottom = data['bottomShortcuts'] is List
      ? (data['bottomShortcuts'] as List).whereType<String>().where(availableBottomShortcuts.contains).toSet().take(6).toList()
      : [...defaultBottomShortcuts];
    if (data['navigationVersion'] != 2 && !bottom.contains('exit') && bottom.length < 6) bottom.add('exit');
    return UiPreferences(themeMode: modes.isEmpty ? ThemeMode.system : modes.first,
      dashboardCards: data['dashboardCards'] is List ? List.unmodifiable({
        if (data['dashboardVersion'] != 1) 'hatim',
        ...(data['dashboardCards'] as List)
        .whereType<String>().where((id) => dashboardCardLabels.containsKey(id) ||
          (data['shortcuts'] is List ? parsed : defaults).any((s) => s.id == id))}) : data.isEmpty ? null : [
            'hatim', 'meal', 'listen', 'history', 'search', 'bookmarks',
            ...(data['shortcuts'] is List ? parsed : defaults).map((s) => s.id), 'support', 'settings'],
      bottomShortcuts: List.unmodifiable(bottom.take(6)),
      color: colors.containsKey(data['color']) ? data['color'] as String : 'green',
      shortcuts: data['shortcuts'] is List ? List.unmodifiable(parsed) : defaults);
  }
}

class AppPreferences extends ValueNotifier<UiPreferences> {
  AppPreferences._() : super(const UiPreferences());
  static final instance = AppPreferences._();
  void restore(Map<dynamic, dynamic>? data) { value = UiPreferences.fromMap(data); }
  Future<void> save(UiPreferences preferences) async {
    await const MethodChannel('com.zekitazegul.kuranapp/reading').invokeMethod<void>('saveUiPreferences', {'preferences': preferences.toMap()});
    value = preferences;
  }
}

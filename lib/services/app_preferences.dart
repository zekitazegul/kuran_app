import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ShortcutKind { surah, juz }

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
  const UiPreferences({this.themeMode = ThemeMode.system, this.color = 'green', this.shortcuts = defaults});
  Color get seed => colors[color] ?? colors['green']!;
  UiPreferences copyWith({ThemeMode? themeMode, String? color, List<HomeShortcut>? shortcuts}) =>
    UiPreferences(themeMode: themeMode ?? this.themeMode, color: color ?? this.color,
      shortcuts: List.unmodifiable(shortcuts ?? this.shortcuts));
  Map<String, Object> toMap() => {'theme': themeMode.name, 'color': color,
    'shortcuts': shortcuts.map((s) => s.toMap()).toList()};
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
    return UiPreferences(themeMode: modes.isEmpty ? ThemeMode.system : modes.first,
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

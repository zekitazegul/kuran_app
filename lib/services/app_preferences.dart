import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ShortcutKind { surah, juz }

const dashboardCardLabels = {
  'home':'Ana sayfa', 'exit':'Geri / \u00c7\u0131k\u0131\u015f', 'page':'Sayfaya git',
  'hatim': 'Hatim',
  'meal': 'Meal Oku', 'history': 'Okuma geçmişi',
  'search': 'Sureler', 'bookmarks': 'Ayraçlarım', 'support': 'Destek', 'settings': 'Ayarlar',
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
  static const motifs = ['cream','white','sage','sky','lavender','sand'];
  final String backgroundMotif;
  final String menuMotif;
  final double motifStrength;
  final int demoRevision;
  final List<HomeShortcut> shortcuts;
  static const defaultBottomShortcuts = ['surahs', 'home', 'exit'];
  static const availableBottomShortcuts = ['home', 'bookmarks', 'surahs', 'history', 'settings', 'search', 'hatim', 'exit', 'meal', 'support'];
  final List<String> bottomShortcuts;
  final List<String>? dashboardCards;
  final List<String>? menuCards;
  List<String> get menuOrder => menuCards ?? {...dashboardOrder, ...dashboardCardLabels.keys, ...shortcuts.map((s)=>s.id)}.toList();
  final List<String> _personalCards;
  final List<List<String>>? customPages;
  List<List<String>> get personalPages {
    final seen = <String>{};
    final pages = <List<String>>[];
    var emptyPage = false;
    for (final page in customPages ?? [_personalCards]) {
      if (page.isEmpty) emptyPage = true;
      for (final id in page) {
        if (seen.add(id)) pages.add(List<String>.unmodifiable([id]));
      }
    }
    if (emptyPage) pages.add(<String>[]);
    return pages;
  }
  List<String> get personalCards => personalPages.isEmpty ? const [] : personalPages.first;
  List<String> get availableDashboardCards => [...dashboardCardLabels.keys, ...shortcuts.map((s) => s.id)];
  List<String> get dashboardOrder => dashboardCards ?? ['hatim', 'history'];
  const UiPreferences({this.themeMode = ThemeMode.system, this.color = 'green', this.backgroundMotif='cream',this.menuMotif='white',this.motifStrength=.18,this.demoRevision=0, this.shortcuts = defaults,
    // Preserve the public legacy parameter while storing pages separately.
    // ignore: prefer_initializing_formals
    this.bottomShortcuts = defaultBottomShortcuts, this.dashboardCards, this.menuCards, List<String> personalCards = const [], this.customPages}) : _personalCards = personalCards;
  Color get seed => colors[color] ?? colors['green']!;
  UiPreferences copyWith({ThemeMode? themeMode, String? color, String? backgroundMotif, String? menuMotif, double? motifStrength, int? demoRevision, List<HomeShortcut>? shortcuts, List<String>? bottomShortcuts, List<String>? dashboardCards, List<String>? menuCards, List<String>? personalCards, List<List<String>>? personalPages}) =>
    UiPreferences(demoRevision:demoRevision??this.demoRevision,backgroundMotif:backgroundMotif??this.backgroundMotif,menuMotif:menuMotif??this.menuMotif,motifStrength:motifStrength??this.motifStrength,menuCards: menuCards ?? this.menuCards, customPages: List.unmodifiable((personalPages ?? (personalCards == null ? this.personalPages : [personalCards])).map((page) => List<String>.unmodifiable(page.where((id) => dashboardCardLabels.containsKey(id) || (shortcuts ?? this.shortcuts).any((s) => s.id == id))))), themeMode: themeMode ?? this.themeMode, color: color ?? this.color,
      shortcuts: List.unmodifiable(shortcuts ?? this.shortcuts), bottomShortcuts: List.unmodifiable((bottomShortcuts ?? this.bottomShortcuts).where((id) =>
        availableBottomShortcuts.contains(id) || (shortcuts ?? this.shortcuts).any((s) => s.id == id)).toSet().take(5)),
      dashboardCards: dashboardCards != null ? List.unmodifiable(dashboardCards) : this.dashboardCards == null && shortcuts == null ? null : List.unmodifiable([
        ...dashboardOrder.where((id) => dashboardCardLabels.containsKey(id) || (shortcuts ?? this.shortcuts).any((s) => s.id == id)),
        if (shortcuts != null) ...shortcuts.where((s) => !this.shortcuts.any((old) => old.id == s.id)).map((s) => s.id),
      ]));
  Map<String, Object> toMap() => {'theme': themeMode.name, 'color': color,
    'motifStyleVersion':2,'demoRevision':demoRevision,'backgroundMotif':backgroundMotif,'menuMotif':menuMotif,'motifStrength':motifStrength,
    'shortcuts': shortcuts.map((s) => s.toMap()).toList(), 'bottomShortcuts': bottomShortcuts, 'navigationVersion': 2,
    'personalPages': personalPages, 'personalCards': personalCards, 'dashboardCards': dashboardOrder, 'menuCards': menuOrder, 'dashboardVersion': 1, 'homeLayoutVersion': 3};
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
      ? (data['bottomShortcuts'] as List).whereType<String>().where((id) => availableBottomShortcuts.contains(id) || (data['shortcuts'] is List ? parsed : defaults).any((s) => s.id == id)).toSet().take(5).toList()
      : [...defaultBottomShortcuts];
    if (data['navigationVersion'] != 2 && !bottom.contains('exit') && bottom.length < 5) bottom.add('exit');
    final validShortcuts = data['shortcuts'] is List ? parsed : defaults;
    List<String> parsePage(List page) => List.unmodifiable(page.whereType<String>().where((id) => dashboardCardLabels.containsKey(id) || validShortcuts.any((s) => s.id == id)).toSet());
    final legacyCards = data['homeLayoutVersion'] == 3 ? <String>[] : [
      if (data['personalPages'] is List) ... (data['personalPages'] as List).whereType<List>().expand(parsePage),
      if (data['personalCards'] is List) ...parsePage(data['personalCards'] as List),
    ];
    return UiPreferences(demoRevision:(data['demoRevision'] as num?)?.toInt()??0,backgroundMotif:motifs.contains(data['backgroundMotif'])?data['backgroundMotif'] as String:'cream',menuMotif:motifs.contains(data['menuMotif'])?data['menuMotif'] as String:'white',motifStrength:((data['motifStrength'] as num?)?.toDouble()??.18).clamp(data['motifStyleVersion']==2 ? .04 : .18,.4),menuCards: data['menuCards'] is List ? List<String>.unmodifiable((data['menuCards'] as List).whereType<String>().toSet()) : null, customPages: data['homeLayoutVersion'] == 3 && data['personalPages'] is List ? List.unmodifiable((data['personalPages'] as List).whereType<List>().map(parsePage)) : const [],
      personalCards: data['personalCards'] is List ? parsePage(data['personalCards'] as List) : const [], themeMode: modes.isEmpty ? ThemeMode.system : modes.first,
      dashboardCards: data['dashboardCards'] is List ? List.unmodifiable({
        if (data['dashboardVersion'] != 1) 'hatim',
        ...(data['dashboardCards'] as List)
        .whereType<String>().where((id) => dashboardCardLabels.containsKey(id) ||
          (data['shortcuts'] is List ? parsed : defaults).any((s) => s.id == id)), ...legacyCards}) : data.isEmpty ? null : [
            'hatim', 'meal', 'history', 'search', 'bookmarks',
            ...(data['shortcuts'] is List ? parsed : defaults).map((s) => s.id), 'support', 'settings'],
      bottomShortcuts: List.unmodifiable(bottom.take(5)),
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

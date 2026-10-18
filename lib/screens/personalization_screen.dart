import '../widgets/screen_title.dart';
import 'package:flutter/material.dart';
import '../data/surahs.dart';
import '../l10n/translations.dart';
import '../services/app_preferences.dart';
import '../widgets/app_bottom_bar.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});
  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  bool _saving = false;
  Future<void> _save(UiPreferences preferences) async {
    if (_saving) return;
    setState(() => _saving = true);
    try { await AppPreferences.instance.save(preferences); }
    catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Tercih kaydedilemedi.'))));
    } finally { if (mounted) setState(() => _saving = false); }
  }
  String _name(HomeShortcut shortcut) => shortcut.kind == ShortcutKind.juz
    ? context.t('Cüz {number}', {'number': shortcut.number})
    : shortcut.number == 36 ? context.t('Yasin') : surahName(surahs[shortcut.number - 1], context.language);

  Future<void> _addShortcut() async {
    final shortcut = await showModalBottomSheet<HomeShortcut>(context: context,
      isScrollControlled: true, builder: (_) => const _ShortcutPicker());
    if (shortcut == null || !mounted) return;
    final preferences = AppPreferences.instance.value;
    if (preferences.shortcuts.any((s) => s.id == shortcut.id)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Bu kısayol zaten ekli.'))));
      return;
    }
    if (preferences.shortcuts.length >= 24) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('En fazla 24 kısayol ekleyebilirsin.'))));
      return;
    }
    await _save(preferences.copyWith(shortcuts: [...preferences.shortcuts, shortcut]));
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<UiPreferences>(
    valueListenable: AppPreferences.instance,
    builder: (context, preferences, _) => Scaffold(
      appBar: AppBar(title: ScreenTitle(context, context.t('Görünüm ve kısayollar')), actions: const <Widget>[]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(context.t('Alt çubuk kısayolları'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(context.t('Kısayolları seçebilir, sıralayabilir ve kaldırabilirsin.')),
        for (var i = 0; i < preferences.bottomShortcuts.length; i++)
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(bottomShortcutIcon(preferences.bottomShortcuts[i])),
            title: Text(bottomShortcutLabel(context, preferences.bottomShortcuts[i])),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(tooltip: context.t('Yukarı taşı'), icon: const Icon(Icons.arrow_upward),
                onPressed: _saving || i == 0 ? null : () {
                  final items = [...preferences.bottomShortcuts];
                  final item = items.removeAt(i); items.insert(i - 1, item);
                  _save(preferences.copyWith(bottomShortcuts: items));
                }),
              IconButton(tooltip: context.t('Kısayolu kaldır'), icon: const Icon(Icons.delete_outline),
                onPressed: _saving
                  ? null : () => _save(preferences.copyWith(bottomShortcuts:
                    preferences.bottomShortcuts.where((id) => id != preferences.bottomShortcuts[i]).toList()))),
            ])),
        if (preferences.bottomShortcuts.length < 6)
          Wrap(spacing: 8, children: [
            for (final id in [...UiPreferences.availableBottomShortcuts, ...preferences.shortcuts.map((s) => s.id)].where((id) => !preferences.bottomShortcuts.contains(id)))
              ActionChip(avatar: const Icon(Icons.add, size: 18),
                label: Text(bottomShortcutLabel(context, id)),
                onPressed: _saving ? null : () => _save(preferences.copyWith(
                  bottomShortcuts: [...preferences.bottomShortcuts, id]))),
          ]),
        TextButton(onPressed: _saving ? null : () => _save(preferences.copyWith(bottomShortcuts: UiPreferences.defaultBottomShortcuts)),
          child: Text(context.t('Alt çubuğu sıfırla'))),
        const SizedBox(height: 24),
        Text(context.t('Tema'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          for (final entry in const {ThemeMode.system: 'Sistem', ThemeMode.light: 'Açık', ThemeMode.dark: 'Koyu'}.entries)
            ChoiceChip(label: Text(context.t(entry.value)), selected: preferences.themeMode == entry.key,
              onSelected: _saving ? null : (_) => _save(preferences.copyWith(themeMode: entry.key))),
        ]),
        const SizedBox(height: 24),
        Text(context.t('Renk'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final entry in const {'green': 'Yeşil', 'blue': 'Mavi', 'purple': 'Mor', 'amber': 'Altın'}.entries)
            ChoiceChip(label: Text(context.t(entry.value)),
              avatar: CircleAvatar(backgroundColor: UiPreferences.colors[entry.key], radius: 8),
              selected: preferences.color == entry.key,
              onSelected: _saving ? null : (_) => _save(preferences.copyWith(color: entry.key))),
        ]),
        const SizedBox(height: 12),
        Text(context.t('Tema ve renk yalnızca arayüzü değiştirir; Kur’an sayfalarının görünümü korunur.')),
        const SizedBox(height: 28),
        Text(context.t('Ana ekran kartları'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(context.t('Kartları ana ekranda uzun basıp sürükleyerek sırala veya çöp sepetine bırak. Kaldırılan kartları buradan geri ekleyebilirsin.')),
        for (final id in preferences.availableDashboardCards) SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(dashboardCardLabels.containsKey(id) ? context.t(dashboardCardLabels[id]!)
            : _name(preferences.shortcuts.firstWhere((shortcut) => shortcut.id == id))),
          value: preferences.dashboardOrder.contains(id),
          onChanged: _saving ? null : (visible) => _save(preferences.copyWith(dashboardCards: visible
            ? [...preferences.dashboardOrder, id] : preferences.dashboardOrder.where((card) => card != id).toList())),
        ),
        const SizedBox(height: 28),
        Text(context.t('Ana ekran kısayolları'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(context.t('İstediğin sure veya cüzü ekle. Oklarla sıralamayı değiştirebilir, çöp kutusuyla kaldırabilirsin.')),
        const SizedBox(height: 12),
        for (var i = 0; i < preferences.shortcuts.length; i++) Card(child: ListTile(
          title: Text(_name(preferences.shortcuts[i])),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(tooltip: context.t('Yukarı taşı'), icon: const Icon(Icons.arrow_upward, size: 20),
              onPressed: _saving || i == 0 ? null : () {
                final items = [...preferences.shortcuts];
                final item = items.removeAt(i); items.insert(i - 1, item);
                _save(preferences.copyWith(shortcuts: items));
              }),
            IconButton(tooltip: context.t('Aşağı taşı'), icon: const Icon(Icons.arrow_downward, size: 20),
              onPressed: _saving || i == preferences.shortcuts.length - 1 ? null : () {
                final items = [...preferences.shortcuts];
                final item = items.removeAt(i); items.insert(i + 1, item);
                _save(preferences.copyWith(shortcuts: items));
              }),
            IconButton(tooltip: context.t('Kısayolu kaldır'), icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: _saving ? null : () => _save(preferences.copyWith(shortcuts:
                preferences.shortcuts.where((s) => s.id != preferences.shortcuts[i].id).toList()))),
          ]),
        )),
        OutlinedButton.icon(onPressed: _saving ? null : _addShortcut,
          icon: const Icon(Icons.add), label: Text(context.t('Kısayol ekle'))),
        TextButton(onPressed: _saving ? null : () => _save(preferences.copyWith(shortcuts: UiPreferences.defaults)),
          child: Text(context.t('Varsayılan kısayolları geri getir'))),
      ]),
    ),
  );
}

class _ShortcutPicker extends StatefulWidget {
  const _ShortcutPicker();
  @override
  State<_ShortcutPicker> createState() => _ShortcutPickerState();
}
class _ShortcutPickerState extends State<_ShortcutPicker> {
  ShortcutKind kind = ShortcutKind.surah;
  String query = '';
  @override
  Widget build(BuildContext context) {
    final items = kind == ShortcutKind.surah
      ? surahs.where((s) => matchesSurah(s, query)).map((s) => HomeShortcut(kind, s.number)).toList()
      : List.generate(30, (i) => HomeShortcut(kind, i + 1)).where((s) =>
          query.trim().isEmpty || s.number.toString() == query.trim()).toList();
    return SafeArea(child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(height: MediaQuery.sizeOf(context).height * .75,
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(context.t('Kısayol ekle'),
            style: Theme.of(context).textTheme.titleLarge)),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: Text(context.t('Sureler')), selected: kind == ShortcutKind.surah,
              onSelected: (_) => setState(() { kind = ShortcutKind.surah; query = ''; })),
            ChoiceChip(label: Text(context.t('Cüzler')), selected: kind == ShortcutKind.juz,
              onSelected: (_) => setState(() { kind = ShortcutKind.juz; query = ''; })),
          ]),
          Padding(padding: const EdgeInsets.all(16), child: TextField(key: ValueKey(kind),
            decoration: InputDecoration(labelText: context.t(kind == ShortcutKind.surah ? 'Sure adı veya numarası' : 'Cüz numarası'),
              prefixIcon: const Icon(Icons.search)), onChanged: (value) => setState(() => query = value))),
          Expanded(child: items.isEmpty ? Center(child: Text(context.t('Sonuç bulunamadı.'))) : ListView.builder(
            itemCount: items.length, itemBuilder: (_, index) {
              final item = items[index];
              return ListTile(title: Text(item.kind == ShortcutKind.surah
                ? '${item.number}. ${surahName(surahs[item.number - 1], context.language)}'
                : context.t('Cüz {number}', {'number': item.number})),
                trailing: const Icon(Icons.add), onTap: () => Navigator.pop(context, item));
            })),
        ])),
    ));
  }
}

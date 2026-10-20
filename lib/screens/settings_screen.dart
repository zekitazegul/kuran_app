import '../widgets/screen_title.dart';
import '../widgets/app_distribution.dart';
import '../widgets/personal_page_scope.dart';
import '../widgets/compact_confirmation_dialog.dart';
import '../data/quran_edition.dart';
import 'personalization_screen.dart';
import 'sources_screen.dart';
import '../widgets/support_card.dart';
import 'about_screen.dart';
import '../l10n/translations.dart';
import 'package:flutter/material.dart';
import '../services/reading_store.dart';
import '../services/quran_audio.dart';
import 'guide_screen.dart';
import 'information_screen.dart';
import '../widgets/quran_artwork.dart';

class SettingsScreen extends StatefulWidget {
  final ReadingStore store;
  const SettingsScreen({super.key, required this.store});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _saving = false;
  final _audio = QuranAudio();
  bool _audioLoading = true;
  @override
  void initState() { super.initState(); _loadReciter(); }
  Future<void> _loadReciter() async {
    try { await _audio.load(); } catch (_) { /* Other settings remain available. */ }
    finally { if (mounted) setState(() => _audioLoading = false); }
  }
  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t(text))));

  Future<void> _removeDownload(QuranEdition edition) async {
    if (_saving) return;
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => CompactConfirmationDialog(
      title: Text(dialogContext.t('Hattı cihazımdan kaldır')),
      content: Text(dialogContext.t('{edition} dosyaları cihazdan silinecek. Ayraçların ve son okuduğun sayfa korunacak. Tekrar okumak için bu hattı yeniden indirmen gerekir.',
        {'edition': dialogContext.t(edition.name)})),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(dialogContext.t('Vazgeç'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(dialogContext.t('Kaldır')))],
    ));
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await widget.store.removeDownload(editionId: edition.id);
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      if (mounted) _message('Hat cihazından kaldırıldı.');
    } catch (_) { if (mounted) _message('Hat kaldırılamadı. Tekrar dene.'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PersonalPageScope.of(context) != null ? null : AppBar(automaticallyImplyLeading: PersonalPageScope.of(context) == null, title: PersonalPageScope.of(context) == null ? ScreenTitle(context, context.t('Ayarlar')) : null, actions: const <Widget>[]),
    body: ListView(padding: EdgeInsets.all(20), children: [
      Center(child: QuranArtwork(size: 110, decorative: true)),
      SizedBox(height: 16),
      const AppDistribution(),
      _section('reading', 'Görünüm ve okuma', Icons.auto_stories_outlined, [
      Card(child: ListTile(leading: const Icon(Icons.palette_outlined),
        title: Text(context.t('Görünüm ve kısayollar')),
        subtitle: Text(context.t('Tema, renk ve ana ekran kısayolları')),
        trailing: const Icon(Icons.chevron_right),
        onTap: _saving ? null : () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const PersonalizationScreen())))),
      Card(child: SwitchListTile(
        secondary: Icon(Icons.auto_stories_outlined),
        title: Text(context.t('Sayfa çevirme animasyonu')),
        value: widget.store.pageAnimations,
        onChanged: _saving ? null : (value) async {
          setState(() => _saving = true);
          try { await widget.store.setPageAnimations(value); }
          catch (_) { if (mounted) _message('Tercih kaydedilemedi.'); }
          finally { if (mounted) setState(() => _saving = false); }
        },
      )),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: DropdownButtonFormField<String>(
        key: ValueKey('page-effect-${widget.store.pageEffect}'),
        initialValue: widget.store.pageEffect,
        isExpanded: true,
        decoration: InputDecoration(labelText: context.t('Sayfa geçiş efekti')),
        items: [
          DropdownMenuItem(value: 'slide', child: Text(context.t('Parmağı takip eden kaydırma'))),
          DropdownMenuItem(value: 'curl', child: Text(context.t('Kâğıt kıvrımı'))),
        ],
        onChanged: _saving || !widget.store.pageAnimations ? null : (effect) async {
          if (effect == null) return;
          setState(() => _saving = true);
          try { await widget.store.setPageEffect(effect); }
          catch (_) { if (mounted) _message('Tercih kaydedilemedi.'); }
          finally { if (mounted) setState(() => _saving = false); }
        },
      ))),
      ]),
      _section('audio', 'Ses ve dinleme', Icons.headphones_outlined, [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: DropdownButtonFormField<String>(
        key: ValueKey('default-reciter-${_audio.reciter}'), initialValue: _audio.reciter,
        isExpanded: true, decoration: InputDecoration(labelText: context.t('Varsayılan Kur’an okuyucusu')),
        items: [for (final entry in _audio.reciters.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value))],
        onChanged: _saving || _audioLoading ? null : (id) async {
          if (id == null) return;
          setState(() => _saving = true);
          try { await _audio.selectReciter(id); }
          catch (_) { if (mounted) _message('Tercih kaydedilemedi.'); }
          finally { if (mounted) setState(() => _saving = false); }
        },
      ))),
      ]),
      _section('editions', 'Kur’an hattı', Icons.menu_book_outlined, [
      Card(child: Column(children: [
        for (final edition in widget.store.editions) ListTile(
          enabled: !_saving, leading: Icon(Icons.menu_book_outlined),
          title: Text(context.t(edition.name)), subtitle: Text(context.t(edition.description)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            edition.id == widget.store.edition.id
              ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
              : const Icon(Icons.circle_outlined),
            const SizedBox(width: 4),
            IconButton(key: ValueKey('remove-edition-${edition.id}'),
              tooltip: context.t('{edition} · Cihazdan kaldır', {'edition': context.t(edition.name)}),
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving || !(widget.store.downloadedEditions.contains(edition.id) ||
                (edition.id == widget.store.edition.id && (widget.store.downloadedBytes > 0 || widget.store.downloaded.isNotEmpty)))
                ? null : () => _removeDownload(edition)),
          ]),
          onTap: edition.id == widget.store.edition.id || _saving ? null : () async {
            setState(() => _saving = true);
            try {
              await widget.store.selectEdition(edition.id);
              if (mounted && !widget.store.ready) _message('Bu hattı ana ekrandan indirebilirsin.');
            } catch (_) { if (mounted) _message('Hat seçimi kaydedilemedi.'); }
            finally { if (mounted) setState(() => _saving = false); }
          },
        ),
      ])),
      ]),
      _section('help', 'Yardım ve bilgi', Icons.help_outline, [
      Card(child: Column(children: [
        ListTile(leading: const Icon(Icons.info_outline), title: Text(context.t('Uygulama hakkında')),
          trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => const AboutScreen()))),
      ListTile(leading: const Icon(Icons.copyright_outlined),
        title: Text(context.t('Kaynaklar ve telif bilgileri')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const SourcesScreen()))),
        ListTile(leading: Icon(Icons.help_outline), title: Text(context.t('Kullanım kılavuzu')),
          trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => GuideScreen()))),
        ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text(context.t('Gizlilik ve erişimler')),
          trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => InformationScreen()))),
      ])),
      ]),
      _section('support', 'Destek ve geri bildirim', Icons.favorite_outline, [
      const SupportCard(),
      ]),
      SizedBox(height: 24),
      Text(context.t('Okumak her zaman ücretsiz.'), textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall),
    ]),
  );

  Widget _section(String id, String title, IconData icon, List<Widget> children) => Card(
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      key: PageStorageKey('settings-$id'),
      leading: Icon(icon),
      title: Text(context.t(title)),
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      children: children,
    ),
  );
}

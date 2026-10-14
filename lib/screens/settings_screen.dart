import '../widgets/support_card.dart';
import 'about_screen.dart';
import '../widgets/language_selector.dart';
import '../l10n/translations.dart';
import 'package:flutter/material.dart';
import '../services/reading_store.dart';
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
  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t(text))));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t('Ayarlar')), actions: [LanguageSelector()]),
    body: ListView(padding: EdgeInsets.all(20), children: [
      Center(child: QuranArtwork(size: 110, decorative: true)),
      SizedBox(height: 16),
      _heading(context.t('OKUMA DENEYİMİ')),
      Card(child: SwitchListTile(
        secondary: Icon(Icons.auto_stories_outlined),
        title: Text(context.t('Sayfa çevirme animasyonu')),
        subtitle: Text(context.t('Kâğıt kıvrımı efektini kullan')),
        value: widget.store.pageAnimations,
        onChanged: _saving ? null : (value) async {
          setState(() => _saving = true);
          try { await widget.store.setPageAnimations(value); }
          catch (_) { if (mounted) _message('Tercih kaydedilemedi.'); }
          finally { if (mounted) setState(() => _saving = false); }
        },
      )),
      SizedBox(height: 24),
      _heading(context.t('KUR’AN HATTI')),
      Card(child: Column(children: [
        for (final edition in widget.store.editions) ListTile(
          enabled: !_saving, leading: Icon(Icons.menu_book_outlined),
          title: Text(context.t(edition.name)), subtitle: Text(context.t(edition.description)),
          trailing: edition.id == widget.store.edition.id
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            : Icon(Icons.circle_outlined),
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
      SizedBox(height: 24),
      _heading(context.t('YARDIM VE BİLGİ')),
      Card(child: Column(children: [
        ListTile(leading: const Icon(Icons.info_outline), title: Text(context.t('Uygulama hakkında')),
          trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => const AboutScreen()))),
        ListTile(leading: Icon(Icons.help_outline), title: Text(context.t('Kullanım kılavuzu')),
          trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => GuideScreen()))),
        ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text(context.t('Gizlilik ve erişimler')),
          trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => InformationScreen()))),
      ])),
      SizedBox(height: 24),
      _heading(context.t('BİRLİKTE BÜYÜTELİM')),
      const SupportCard(),
      SizedBox(height: 24),
      Text(context.t('Okumak her zaman ücretsiz.'), textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall),
    ]),
  );

  Widget _heading(String text) => Padding(padding: EdgeInsets.only(left: 8, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.4)));
}

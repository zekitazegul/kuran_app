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
  static const _supportUrl = String.fromEnvironment('SUPPORT_URL');
  bool get _supportAvailable {
    final uri = Uri.tryParse(_supportUrl);
    return uri != null && uri.scheme == 'https' &&
      ['buymeacoffee.com', 'www.buymeacoffee.com', 'ko-fi.com', 'www.ko-fi.com'].contains(uri.host);
  }

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
          catch (_) { if (mounted) _message(context.t('Tercih kaydedilemedi.')); }
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
              if (mounted && !widget.store.ready) _message(context.t('Bu hattı ana ekrandan indirebilirsin.'));
            } catch (_) { if (mounted) _message(context.t('Hat seçimi kaydedilemedi.')); }
            finally { if (mounted) setState(() => _saving = false); }
          },
        ),
      ])),
      SizedBox(height: 24),
      _heading(context.t('YARDIM VE BİLGİ')),
      Card(child: Column(children: [
        ListTile(leading: Icon(Icons.help_outline), title: Text(context.t('Kullanım kılavuzu')),
          trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => GuideScreen()))),
        ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text(context.t('Gizlilik ve erişimler')),
          trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => InformationScreen()))),
      ])),
      SizedBox(height: 24),
      _heading(context.t('BİRLİKTE BÜYÜTELİM')),
      Card(child: ListTile(leading: Icon(Icons.local_cafe_outlined),
        title: Text(context.t('Bir kahveyle destek ol')),
        subtitle: Text(_supportAvailable
          ? context.t('İsteğe bağlı destek · Hiçbir özellik ödeme gerektirmez')
          : context.t('Destek bağlantısı yakında')),
        trailing: _supportAvailable ? Icon(Icons.open_in_new) : null,
        onTap: !_supportAvailable ? null : () async {
          final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
            title: Text(context.t('Geliştiriciye destek')),
            content: Text(context.t('Dış ödeme sitesine yönlendirileceksin. Destek tamamen isteğe bağlıdır; okuma özelliklerini etkilemez. Ödeme bilgilerin bu uygulamada işlenmez.')),
            actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t('Vazgeç'))),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.t('Devam et')))],
          ));
          if (confirmed != true) return;
          try { await ReadingStore.channel.invokeMethod<void>('openSupport', {'url': _supportUrl}); }
          catch (_) { if (mounted) _message(context.t('Destek bağlantısı açılamadı.')); }
        },
      )),
      SizedBox(height: 24),
      Text(context.t('Okumak her zaman ücretsiz.'), textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall),
    ]),
  );

  Widget _heading(String text) => Padding(padding: EdgeInsets.only(left: 8, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.4)));
}

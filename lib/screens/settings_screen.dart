import 'package:flutter/material.dart';
import '../services/reading_store.dart';
import 'guide_screen.dart';
import 'information_screen.dart';

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

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ayarlar')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      _heading('OKUMA DENEYİMİ'),
      Card(child: SwitchListTile(
        secondary: const Icon(Icons.auto_stories_outlined),
        title: const Text('Sayfa çevirme animasyonu'),
        subtitle: const Text('Kâğıt kıvrımı efektini kullan'),
        value: widget.store.pageAnimations,
        onChanged: _saving ? null : (value) async {
          setState(() => _saving = true);
          try { await widget.store.setPageAnimations(value); }
          catch (_) { if (mounted) _message('Tercih kaydedilemedi.'); }
          finally { if (mounted) setState(() => _saving = false); }
        },
      )),
      const SizedBox(height: 24),
      _heading('KUR’AN HATTI'),
      Card(child: Column(children: [
        for (final edition in widget.store.editions) ListTile(
          enabled: !_saving, leading: const Icon(Icons.menu_book_outlined),
          title: Text(edition.name), subtitle: Text(edition.description),
          trailing: edition.id == widget.store.edition.id
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            : const Icon(Icons.circle_outlined),
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
      const SizedBox(height: 24),
      _heading('YARDIM VE BİLGİ'),
      Card(child: Column(children: [
        ListTile(leading: const Icon(Icons.help_outline), title: const Text('Kullanım kılavuzu'),
          trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => const GuideScreen()))),
        ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Gizlilik ve erişimler'),
          trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(builder: (_) => const InformationScreen()))),
      ])),
      const SizedBox(height: 24),
      _heading('BİRLİKTE BÜYÜTELİM'),
      Card(child: ListTile(leading: const Icon(Icons.local_cafe_outlined),
        title: const Text('Bir kahveyle destek ol'),
        subtitle: Text(_supportAvailable
          ? 'İsteğe bağlı destek · Hiçbir özellik ödeme gerektirmez'
          : 'Destek bağlantısı yakında'),
        trailing: _supportAvailable ? const Icon(Icons.open_in_new) : null,
        onTap: !_supportAvailable ? null : () async {
          final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
            title: const Text('Geliştiriciye destek'),
            content: const Text('Dış ödeme sitesine yönlendirileceksin. Destek tamamen isteğe bağlıdır; okuma özelliklerini etkilemez. Ödeme bilgilerin bu uygulamada işlenmez.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Devam et'))],
          ));
          if (confirmed != true) return;
          try { await ReadingStore.channel.invokeMethod<void>('openSupport', {'url': _supportUrl}); }
          catch (_) { if (mounted) _message('Destek bağlantısı açılamadı.'); }
        },
      )),
      const SizedBox(height: 24),
      Text('Okumak her zaman ücretsiz.', textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall),
    ]),
  );

  Widget _heading(String text) => Padding(padding: const EdgeInsets.only(left: 8, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.4)));
}

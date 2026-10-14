import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/reading_store.dart';

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});
  static const url = String.fromEnvironment('SUPPORT_URL', defaultValue: 'https://ko-fi.com/zetasoft');
  bool get available {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' &&
      ['buymeacoffee.com', 'www.buymeacoffee.com', 'ko-fi.com', 'www.ko-fi.com'].contains(uri.host);
  }
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(Icons.local_cafe_outlined),
        title: Text(context.t('Bir kahveyle destek ol')),
        subtitle: Text(available
          ? context.t('İsteğe bağlı destek · Hiçbir özellik ödeme gerektirmez')
          : context.t('Destek bağlantısı yakında')),
        trailing: available ? Icon(Icons.open_in_new) : null,
        onTap: !available ? null : () async {
          final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
            title: Text(context.t('Geliştiriciye destek')),
            content: Text(context.t('Dış ödeme sitesine yönlendirileceksin. Destek tamamen isteğe bağlıdır; okuma özelliklerini etkilemez. Ödeme bilgilerin bu uygulamada işlenmez.')),
            actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t('Vazgeç'))),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.t('Devam et')))],
          ));
          if (confirmed != true) return;
          try { await ReadingStore.channel.invokeMethod<void>('openSupport', {'url': url}); }
          catch (_) { if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Destek bağlantısı açılamadı.'))));
          } }
        },
      ));
}

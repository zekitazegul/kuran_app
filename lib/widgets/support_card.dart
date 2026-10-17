import 'compact_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/reading_store.dart';

class SupportCard extends StatelessWidget {
  final bool gentle;
  const SupportCard({super.key, this.gentle = false});
  static const url = String.fromEnvironment('SUPPORT_URL', defaultValue: 'https://zekitazegul.github.io/support/');
  bool get available {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' &&
      ['buymeacoffee.com', 'www.buymeacoffee.com', 'ko-fi.com', 'www.ko-fi.com', 'zekitazegul.github.io'].contains(uri.host);
  }
  Future<void> _open(BuildContext context) async {
          final confirmed = await showDialog<bool>(context: context, builder: (context) => CompactConfirmationDialog(
            title: Text(context.t('Birlikte güzelleştirelim')),
            content: Text(context.t('Destek ve geri bildirim sayfamız tarayıcıda açılacak. Mesaj göndermek ücretsiz, kahve ikramı tamamen isteğe bağlıdır.')),
            actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t('Vazgeç'))),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.t('Devam et')))],
          ));
          if (confirmed != true) return;
          if (!context.mounted) return;
          final uri = Uri.parse(url);
          final destination = uri.host == 'zekitazegul.github.io'
            ? uri.replace(queryParameters: {...uri.queryParameters, 'lang': context.language},
                fragment: '').toString()
            : url;
          try { await ReadingStore.channel.invokeMethod<void>('openSupport', {'url': destination}); }
          catch (_) { if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Destek bağlantısı açılamadı.'))));
          } }
  }

  @override
  Widget build(BuildContext context) => Card(
    color: gentle ? const Color(0xFFF0E8D8) : null,
    elevation: 0,
    child: Padding(padding: const EdgeInsets.all(20), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.favorite_outline, color: Color(0xFF8A6B39)),
          const SizedBox(width: 10), Expanded(child: Text(context.t('Birlikte güzelleştirelim'),
            style: Theme.of(context).textTheme.titleMedium))]),
        const SizedBox(height: 8),
        Text(context.t('Uygulamanın tüm özellikleri ücretsizdir. Dilersen bir fikir, teşekkür veya kahve ikramıyla katkıda bulunabilirsin.'),
          style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: available ? () => _open(context) : null,
          icon: const Icon(Icons.favorite_outline, size: 18),
          label: Text(context.t('Destek ve geri bildirim'))),
      ])),
  );
}

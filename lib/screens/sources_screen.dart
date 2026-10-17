import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../widgets/language_selector.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t('Kaynaklar ve telif bilgileri')),
      actions: const [LanguageSelector()]),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      Text(context.t('sourcesIntroduction')),
      const SizedBox(height: 20),
      for (final entry in const {
        'Bilgisayar hattı': 'computerRights',
        'Bilgisayar Hattı 2': 'computer2Rights',
        'Hüsrev hattı': 'husrevRights',
      }.entries) Card(child: Padding(padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.t(entry.key), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8), Text(context.t(entry.value)),
        ]))),
      const SizedBox(height: 20),
      const Card(child: Padding(padding: EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mishary Rashid Alafasy · EveryAyah'),
          SizedBox(height: 8),
          SelectableText('https://everyayah.com/data/Alafasy_128kbps/'),
          SizedBox(height: 12),
          Text('Abu Bakr Ash-Shatri · EveryAyah'),
          SizedBox(height: 8),
          SelectableText('https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_128kbps/'),
        ]))),
      Text(context.t('sourcesNotice')),
      const SizedBox(height: 16),
      Text(context.t('Reklamsız ve ücretsiz'), style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(context.t('noAdsPolicy')),
    ]),
  );
}

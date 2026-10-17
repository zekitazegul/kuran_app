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
      _section(context, 'Kaynaklar hakkında', Text(context.t('sourcesIntroduction'))),
      for (final entry in const {
        'Süleyman Feyzullahoğlu Hattı': 'computerRights',
        'Yakupzâde İzzet Efendi Hattı': 'computer2Rights',
        'Hüsrev hattı': 'husrevRights',
      }.entries) _section(context, entry.key, Text(context.t(entry.value))),
      _section(context, 'Mishary Rashid Alafasy · EveryAyah',
        _audioSource(context, 'Mishary Rashid Alafasy', 'https://everyayah.com/data/Alafasy_128kbps/')),
      _section(context, 'Abu Bakr Ash-Shatri · EveryAyah',
        _audioSource(context, 'Abu Bakr Ash-Shatri', 'https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_128kbps/')),
      _section(context, 'Telif ve kullanım koşulları', Text(context.t('sourcesNotice'))),
      _section(context, 'Reklamsız ve ücretsiz', Text(context.t('noAdsPolicy'))),
    ]),
  );

  Widget _audioSource(BuildContext context, String reciter, String url) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(context.t('audioSourceDetails', {'reciter': reciter})),
      const SizedBox(height: 12),
      Text(context.t('audioSourceRights')),
      const SizedBox(height: 12),
      SelectableText(url, key: PageStorageKey('source-url-$url'),
        style: TextStyle(color: Theme.of(context).colorScheme.primary)),
    ],
  );

  Widget _section(BuildContext context, String title, Widget content) => Card(
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(key: PageStorageKey(title), title: Text(context.t(title)),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [SizedBox(width: double.infinity, child: content)]),
  );
}

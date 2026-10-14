import 'sources_screen.dart';
import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../widgets/language_selector.dart';
import '../widgets/quran_artwork.dart';
import '../widgets/support_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t('Uygulama hakkında')),
      actions: const [LanguageSelector()]),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Center(child: QuranArtwork(size: 180, decorative: true)),
      Text('KuranApp', textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 20),
      Text(context.t('aboutDescription')),
      const SizedBox(height: 20),
      Text(context.t('Geliştirici: Zeki Tazegul'),
        style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 24),
      ListTile(leading: const Icon(Icons.copyright_outlined),
        title: Text(context.t('Kaynaklar ve telif bilgileri')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const SourcesScreen()))),
      Text(context.t('Bir kahveyle destek ol'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(context.t('supportInvitation')),
      const SizedBox(height: 12),
      const SupportCard(),
      const SizedBox(height: 16),
      Text(context.t('Okumak her zaman ücretsiz.'), textAlign: TextAlign.center),
    ]),
  );
}

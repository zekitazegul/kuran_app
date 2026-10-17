import 'sources_screen.dart';
import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../widgets/language_selector.dart';
import '../widgets/quran_artwork.dart';
import '../widgets/support_card.dart';
import '../widgets/update_dialog.dart';

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
      const SizedBox(height: 8),
      Text(context.t('Sürüm {version}', {'version': const String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: '1.0.6')}), textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 20),
      Text(context.t('aboutDescription')),
      const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.t('Okuma özellikleri'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8), Text(context.t('versionOneSummary')),
          const SizedBox(height: 20),
          Text(context.t('Kur’an dinleme'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8), Text(context.t('listeningSummary')),
          const SizedBox(height: 20),
          Text(context.t('Meal okuma'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8), Text(context.t('aboutMealSummary')),
          const SizedBox(height: 20),
          Text(context.t('Kişiselleştirme ve kullanım'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8), Text(context.t('aboutSettingsSummary')),
          const SizedBox(height: 20), Text(context.t('freeVersionPolicy')),
        ]))),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.t('Son yenilikler'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final note in latestUpdateNotes) Padding(
            padding: const EdgeInsets.only(bottom: 10), child: Text('• ${context.t(note)}')),
        ]))),
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

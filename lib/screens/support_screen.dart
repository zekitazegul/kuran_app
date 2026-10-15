import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../widgets/language_selector.dart';
import '../widgets/support_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t('Destek')), actions: const [LanguageSelector()]),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      Text(context.t('Birlikte güzelleştirelim'), style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      Text(context.t('Uygulamanın tüm özellikleri ücretsizdir. Dilersen bir fikir, teşekkür veya kahve ikramıyla katkıda bulunabilirsin.')),
      const SizedBox(height: 20), const SupportCard(),
    ]),
  );
}

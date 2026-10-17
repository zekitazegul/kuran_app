import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../widgets/language_selector.dart';
import '../widgets/support_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t('Destek')), actions: const [LanguageSelector()]),
    body: ListView(padding: const EdgeInsets.all(24), children: const [
      SupportCard(),
    ]),
  );
}

import '../widgets/language_selector.dart';
import '../l10n/translations.dart';
import 'package:flutter/material.dart';

class InformationScreen extends StatelessWidget {
  final Future<void> Function()? onContinue;
  const InformationScreen({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t('Gizlilik ve uygulama erişimleri')), actions: [LanguageSelector()]),
    body: ListView(padding: EdgeInsets.all(24), children: [
      Icon(Icons.privacy_tip_outlined, size: 64),
      SizedBox(height: 24),
      Text(context.t('Uygulama neye erişir?'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      SizedBox(height: 16),
      Text(context.t('privacyBody')),
      SizedBox(height: 24),
      if (onContinue != null) FilledButton(onPressed: () async {
        try { await onContinue!(); } catch (_) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Bilgilendirme kaydedilemedi. Tekrar deneyin.'))));
        }
      }, child: Text(context.t('Anladım, devam et'))),
    ]),
  );
}

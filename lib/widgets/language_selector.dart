import 'package:flutter/material.dart';
import '../services/app_language.dart';
import '../l10n/translations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: context.t('Dil seç'),
    onSelected: (code) async {
      try { await AppLanguage.instance.change(code); }
      catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.t('Dil tercihi kaydedilemedi.'))));
        }
      }
    },
    itemBuilder: (_) => const [
      PopupMenuItem(value: 'tr', child: Text('Türkçe')),
      PopupMenuItem(value: 'en', child: Text('English')),
      PopupMenuItem(value: 'nl', child: Text('Nederlands')),
    ],
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(
      mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.language, size: 20),
        const SizedBox(width: 4), Text((AppLanguage.instance.value?.languageCode ?? 'tr').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w600)),
      ])),
  );
}

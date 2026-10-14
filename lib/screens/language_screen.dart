import 'package:flutter/material.dart';
import '../services/app_language.dart';
import '../widgets/quran_artwork.dart';

class LanguageScreen extends StatefulWidget {
  final VoidCallback onSelected;
  const LanguageScreen({super.key, required this.onSelected});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}
class _LanguageScreenState extends State<LanguageScreen> {
  bool _saving = false;
  String? _error;
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(
    child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440), child: Column(children: [
        const QuranArtwork(size: 180, decorative: true),
        const SizedBox(height: 24),
        const Text('Dil / Language / Taal', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        for (final entry in const {'tr': 'Türkçe', 'en': 'English', 'nl': 'Nederlands'}.entries)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SizedBox(width: double.infinity,
            child: FilledButton(onPressed: _saving ? null : () async {
              setState(() { _saving = true; _error = null; });
              try {
                await AppLanguage.instance.change(entry.key);
                if (mounted) widget.onSelected();
              } catch (_) {
                if (mounted) setState(() => _error = 'Tekrar dene / Try again / Probeer opnieuw');
              } finally { if (mounted) setState(() => _saving = false); }
            }, child: Text(entry.value)))),
        if (_error != null) Text(_error!),
      ])),
    ),
  )));
}

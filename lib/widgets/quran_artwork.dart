import '../l10n/translations.dart';
import 'package:flutter/material.dart';

/// Shared artwork for the home screen, guide and Android launcher identity.
class QuranArtwork extends StatelessWidget {
  final double size;
  final bool decorative;
  const QuranArtwork({super.key, this.size = 180, this.decorative = false});

  @override
  Widget build(BuildContext context) => Image.asset('assets/branding/quran.png',
    width: size, height: size, fit: BoxFit.contain,
    cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round().clamp(96, 1024).toInt(),
    excludeFromSemantics: decorative,
    semanticLabel: decorative ? null : context.t('Ahşap rahle üzerinde altın bezemeli yeşil Kur’an-ı Kerim'));
}

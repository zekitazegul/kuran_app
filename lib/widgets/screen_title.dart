import 'package:flutter/material.dart';
import '../l10n/translations.dart';

String uppercaseScreenTitle(String text, String language) {
  if (language == 'tr') text = text.replaceAll('i', 'İ').replaceAll('ı', 'I');
  return text.toUpperCase();
}

class ScreenTitle extends Text {
  ScreenTitle(BuildContext context, String text, {
    super.key, int? maxLines, TextOverflow? overflow, TextStyle? style, super.textAlign,
  }) : super(uppercaseScreenTitle(text, context.language),
    maxLines: maxLines ?? 1, overflow: overflow ?? TextOverflow.ellipsis,
    style: (style ?? const TextStyle()).copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1));
}

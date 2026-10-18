import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/verse_counts.dart';
import '../data/surahs.dart';
import '../l10n/translations.dart';
import '../services/verse_regions.dart';

String verseSelectionLabel(List<VerseRegion> verses) {
  final first = verses.first;
  final last = verses.last;
  return verses.length == 1 ? '${first.surah}:${first.verse}' :
    '${first.surah}:${first.verse} – ${last.surah}:${last.verse}';
}

Future<String?> showVerseActions(BuildContext context, VerseRegion verse, Offset anchor, {List<VerseRegion>? selection}) {
  final verses = selection ?? [verse];
  final size = MediaQuery.sizeOf(context);
  return showMenu<String>(context: context,
    position: RelativeRect.fromLTRB(anchor.dx.clamp(16, size.width - 16),
      anchor.dy.clamp(16, size.height - 16), 16, 16),
    items: [
      PopupMenuItem(enabled: false, child: Text(verseSelectionLabel(verses))),
      for (final action in const {'verseAudio':'verseAudio', 'verseMeal':'Meal Oku', 'verseMemorize':'verseMemorize'}.entries)
        PopupMenuItem(value: action.key, child: Text(context.t(action.value))),
    ]);
}

Future<void> showVerseMeal(BuildContext context, VerseRegion verse, {List<VerseRegion>? selection}) async {
  final verses = selection ?? [verse];
  await showDialog<void>(context: context, builder: (context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 520,
      maxHeight: MediaQuery.sizeOf(context).height * .65),
      child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [Expanded(child: Text('${context.t('Meal Oku')} · ${verseSelectionLabel(verses)}',
          style: Theme.of(context).textTheme.titleMedium)),
          IconButton(tooltip: context.t('Kapat'), onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
        Text(context.t('verseMealSource'), style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 12),
        Flexible(child: FutureBuilder<String>(future: Future.wait(verses.map(_translation)).then((texts) =>
          texts.asMap().entries.map((e) => verses.length == 1 ? e.value :
            '${verses[e.key].surah}:${verses[e.key].verse}\n${e.value}').join('\n\n')), builder: (context, snapshot) {
          if (snapshot.hasError) return Text(context.t('Meal açılamadı. Tekrar dene.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(child: SelectableText(snapshot.data!, style: const TextStyle(fontSize: 20, height: 1.55)));
        })),
      ])),
    ),
  ));
}

Map<String, String>? _meal;
Future<String> _translation(VerseRegion verse) {
  String value(Map<String,String> data) => data['${verse.surah}:${verse.verse}'] ?? (throw StateError('Missing translation'));
  if (_meal != null) return Future.value(value(_meal!));
  return rootBundle.loadString('assets/meal/translation.json', cache: false).then((text) {
    _meal = {for (final v in (jsonDecode(text)['verses'] as List)) '${v['surah']}:${v['verse']}': v['text'] as String};
    return value(_meal!);
  });
}

Future<(int, int, int)?> showMemorizeRange(BuildContext context, VerseRegion verse, {List<VerseRegion>? selection}) async {
  final crossSurah = selection != null && selection.first.surah != selection.last.surah;
  final start = TextEditingController(text: '${selection?.first.verse ?? 1}');
  final end = TextEditingController(text: '${selection?.last.verse ?? verseCounts[verse.surah - 1]}');
  final repeats = TextEditingController(text: '3');
  final form = GlobalKey<FormState>();
  final result = await showDialog<(int, int, int)>(context: context, builder: (context) => AlertDialog(
    title: Text(context.t('verseMemorize')),
    content: SingleChildScrollView(child: Form(key: form, autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (selection != null) Text(verseSelectionLabel(selection)),
      if (!crossSurah) Text(context.t('verseRepeatHint', {'surah': verse.surah, 'max': verseCounts[verse.surah - 1]})),
      for (final field in crossSurah ? <(TextEditingController, String)>[] : [(start, 'verseStart'), (end, 'verseEnd')])
        TextFormField(controller: field.$1, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: context.t(field.$2)),
          validator: (value) {
            final first = int.tryParse(start.text);
            final n = int.tryParse(value ?? '');
            if (n != null && n > verseCounts[verse.surah - 1]) {
              return context.t('verseSurahLimit', {
                'surah': surahName(surahs[verse.surah - 1], context.language),
                'count': verseCounts[verse.surah - 1],
              });
            }
            return n == null || n < 1 || n > verseCounts[verse.surah - 1] ||
              (field.$1 == end && (first == null || n < first)) ? context.t('verseInvalidRange') : null;
          }),
      TextFormField(controller: repeats, keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: context.t('verseRepeatCount')),
        validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1 ||
          (int.tryParse(value ?? '') ?? 0) > 999 ? context.t('verseInvalidRepeats') : null),
    ]))),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t('İptal'))),
      FilledButton(onPressed: () {
        if (form.currentState!.validate()) Navigator.pop(context, (int.parse(start.text), int.parse(end.text), int.parse(repeats.text)));
      }, child: Text(context.t('verseRepeatStart')))],
  ));
  await Future<void>.delayed(const Duration(milliseconds: 300));
  start.dispose(); end.dispose(); repeats.dispose();
  return result;
}

import 'package:flutter/material.dart';
import '../data/surahs.dart';
import '../l10n/translations.dart';

class SearchableSurahField extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  const SearchableSurahField({super.key, required this.value, this.onChanged});

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(context: context, isScrollControlled: true,
      builder: (_) => _SurahSearch(selected: value));
    if (selected != null) onChanged?.call(selected);
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onChanged == null ? null : () => _open(context),
    child: InputDecorator(
      decoration: InputDecoration(labelText: context.t('Sureler'), enabled: onChanged != null),
      child: Row(children: [
        Expanded(child: Text('$value. ${surahName(surahs[value - 1], context.language)}', overflow: TextOverflow.ellipsis)),
        const Icon(Icons.arrow_drop_down),
      ]),
    ),
  );
}

class _SurahSearch extends StatefulWidget {
  final int selected;
  const _SurahSearch({required this.selected});
  @override
  State<_SurahSearch> createState() => _SurahSearchState();
}

class _SurahSearchState extends State<_SurahSearch> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = surahs.where((surah) => matchesSurah(surah, _query)).toList();
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(top: false, child: SizedBox(height: MediaQuery.sizeOf(context).height * .65,
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: TextField(
            key: const ValueKey('surah-search-input'), autofocus: true,
            decoration: InputDecoration(labelText: context.t('Sure adı veya numarası'), prefixIcon: const Icon(Icons.search)),
            onChanged: (query) => setState(() => _query = query),
          )),
          Expanded(child: filtered.isEmpty ? Center(child: Text(context.t('Sonuç bulunamadı.')))
            : ListView.builder(itemCount: filtered.length, itemBuilder: (context, index) {
              final surah = filtered[index];
              return ListTile(key: ValueKey('surah-search-result-${surah.number}'),
                selected: surah.number == widget.selected,
                title: Text('${surah.number}. ${surahName(surah, context.language)}'),
                onTap: () => Navigator.pop(context, surah.number));
            })),
        ]))),
    );
  }
}

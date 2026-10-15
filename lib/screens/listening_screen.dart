import 'dart:async';
import 'package:flutter/material.dart';
import '../data/surahs.dart';
import '../data/verse_counts.dart';
import '../l10n/translations.dart';
import '../services/quran_audio.dart';
import '../widgets/language_selector.dart';

class ListeningScreen extends StatefulWidget {
  final int initialSurah;
  const ListeningScreen({super.key, this.initialSurah = 1});
  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}
class _ListeningScreenState extends State<ListeningScreen> {
  final _audio = QuranAudio();
  final _verse = TextEditingController(text: '1');
  late int _surah;
  bool _singleVerse = false;
  bool _busy = true;
  bool _loading = false;
  String? _error;
  Timer? _timer;
  @override
  void initState() {
    super.initState(); _surah = widget.initialSurah;
    _run(_audio.load);
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_busy || _loading || _audio.playing == null) return;
      _loading = true;
      try { await _audio.load(); if (mounted) setState(() {}); }
      catch (_) { /* A later refresh or user action can retry. */ }
      finally { _loading = false; }
    });
  }
  Future<void> _run(Future<void> Function() action) async {
    setState(() { _busy = true; _error = null; });
    try { await action(); }
    catch (_) { if (mounted) _error = 'Ses işlemi tamamlanamadı. Tekrar dene.'; }
    finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  void dispose() {
    _timer?.cancel(); _verse.dispose();
    _audio.stop().catchError((Object _) {});
    super.dispose();
  }
  Future<void> _download(AudioTrack track) async {
    final yes = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(dialogContext.t('Ses dosyasını indir')),
      content: Text(dialogContext.t('Bir kez indir, çevrimdışı dinle. Boyut: {size} MB', {'size': (track.bytes / 1000000).toStringAsFixed(1)})),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(dialogContext.t('Vazgeç'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(dialogContext.t('İndirmeyi başlat')))],
    ));
    if (yes == true && mounted) await _run(() => _audio.download(track));
  }
  Future<void> _remove(AudioTrack track) async {
    final yes = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(dialogContext.t('Ses dosyasını cihazımdan sil')),
      content: Text(dialogContext.t('Bu ses kaydı silinecek. Kur’an sayfaların ve ayraçların korunacak.')),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(dialogContext.t('Vazgeç'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(dialogContext.t('Kaldır')))],
    ));
    if (yes == true && mounted) await _run(() => _audio.remove(track));
  }
  @override
  Widget build(BuildContext context) {
    final verse = _singleVerse ? int.tryParse(_verse.text) : null;
    final valid = !_singleVerse || (verse != null && verse >= 1 && verse <= verseCounts[_surah - 1]);
    final track = valid ? _audio.find(_surah, verse) : null;
    final downloaded = track != null && _audio.downloaded.contains(track.id);
    return Scaffold(
      appBar: AppBar(title: Text(context.t('Dinle')), actions: const [LanguageSelector()]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        DropdownButtonFormField<int>(initialValue: _surah, isExpanded: true,
          decoration: InputDecoration(labelText: context.t('Sureler')),
          items: [for (final s in surahs) DropdownMenuItem(value: s.number,
            child: Text('${s.number}. ${surahName(s, context.language)}', overflow: TextOverflow.ellipsis))],
          onChanged: _busy ? null : (value) { if (value != null) setState(() { _surah = value; _verse.text = '1'; }); }),
        const SizedBox(height: 16),
        Wrap(spacing: 8, children: [
          ChoiceChip(label: Text(context.t('Surenin tamamı')), selected: !_singleVerse,
            onSelected: _busy ? null : (_) => setState(() => _singleVerse = false)),
          ChoiceChip(label: Text(context.t('Seçilen ayet')), selected: _singleVerse,
            onSelected: _busy ? null : (_) => setState(() => _singleVerse = true)),
        ]),
        if (_singleVerse) Padding(padding: const EdgeInsets.only(top: 16), child: TextField(
          controller: _verse, keyboardType: TextInputType.number, enabled: !_busy,
          decoration: InputDecoration(labelText: context.t('Ayet numarası'),
            helperText: '1–${verseCounts[_surah - 1]}', errorText: valid ? null : context.t('Geçerli bir ayet numarası yaz.')),
          onChanged: (_) => setState(() {}))),
        const SizedBox(height: 24),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) ...[
          Text(context.t(_error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          TextButton(onPressed: _busy ? null : () => _run(_audio.load), child: Text(context.t('Tekrar dene'))),
        ],
        if (!_busy && _error == null && track == null && valid) Card(child: Padding(padding: const EdgeInsets.all(20),
          child: Text(context.t('Bu seçim için ses kaydı henüz eklenmedi. Kayıtlar eklendiğinde bir kez indirip ücretsiz ve çevrimdışı dinleyebilirsin.')))),
        if (track != null) ...[
          FilledButton.icon(onPressed: _busy ? null : downloaded
            ? () => _run(() => _audio.play(track)) : () => _download(track),
            icon: Icon(downloaded ? Icons.play_arrow : Icons.download),
            label: Text(context.t(downloaded ? 'Dinle' : 'Ses dosyasını indir'))),
        ],
        if (_audio.playing != null) OutlinedButton.icon(onPressed: _busy ? null : () => _run(_audio.stop),
          icon: const Icon(Icons.stop), label: Text(context.t('Durdur'))),
        const SizedBox(height: 24),
        Text(context.t('İndirilen sesler'), style: Theme.of(context).textTheme.titleLarge),
        if (_audio.downloaded.isEmpty) Text(context.t('Henüz indirilmiş ses dosyası yok.')),
        for (final item in _audio.tracks.where((t) => _audio.downloaded.contains(t.id))) Card(child: ListTile(
          title: Text(surahName(surahs[item.surah - 1], context.language)),
          subtitle: item.verse == null ? Text(context.t('Surenin tamamı')) : Text(context.t('Ayet {number}', {'number': item.verse!})),
          leading: IconButton(tooltip: context.t('Dinle'), icon: const Icon(Icons.play_arrow),
            onPressed: _busy ? null : () => _run(() => _audio.play(item))),
          trailing: IconButton(tooltip: context.t('Ses dosyasını cihazımdan sil'), icon: const Icon(Icons.delete_outline),
            onPressed: _busy ? null : () => _remove(item)),
        )),
      ]),
    );
  }
}

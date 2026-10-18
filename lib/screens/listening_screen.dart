import '../widgets/screen_title.dart';
import '../widgets/personal_page_scope.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/compact_confirmation_dialog.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/surahs.dart';
import '../data/verse_counts.dart';
import '../l10n/translations.dart';
import '../services/quran_audio.dart';
import '../widgets/searchable_surah_field.dart';

class ListeningScreen extends StatefulWidget {
  final int initialSurah;
  final bool embedded;
  const ListeningScreen({super.key, this.initialSurah = 1, this.embedded = false});
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
  final _selected = <String>{};

  void _select(AudioTrack track) {
    if (_busy || _audio.playing != null) return;
    setState(() {
      if (!_selected.add(track.id)) _selected.remove(track.id);
    });
  }

  Future<void> _removeSelected() async {
    if (_busy || _audio.playing != null || _selected.isEmpty) return;
    final tracks = _audio.tracks.where((track) => _selected.contains(track.id)).toList();
    final yes = await showDialog<bool>(context: context, builder: (dialogContext) => CompactConfirmationDialog(
      title: Text(dialogContext.t('Seçilen sesleri sil')),
      content: Text(dialogContext.t('{count} ses kaydı silinecek. Kur’an sayfaların ve ayraçların korunacak.', {'count': tracks.length})),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(dialogContext.t('Vazgeç'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(dialogContext.t('Kaldır')))],
    ));
    if (yes == true && mounted) {
      await _run(() async {
        try {
          for (final track in tracks) {
            await _audio.remove(track);
            _selected.remove(track.id);
          }
        } finally {
          await _audio.load();
          _selected.retainAll(_audio.downloaded);
        }
      });
    }
  }
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
    final yes = await showDialog<bool>(context: context, builder: (dialogContext) => CompactConfirmationDialog(
      title: Text(dialogContext.t('Ses dosyasını indir')),
      content: Text(dialogContext.t('Bir kez indir, çevrimdışı dinle. Boyut: {size} MB', {'size': (track.bytes / 1000000).toStringAsFixed(1)})),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(dialogContext.t('Vazgeç'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(dialogContext.t('İndirmeyi başlat')))],
    ));
    if (yes == true && mounted) await _run(() => _audio.download(track));
  }
  Future<void> _remove(AudioTrack track) async {
    final yes = await showDialog<bool>(context: context, builder: (dialogContext) => CompactConfirmationDialog(
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
    final isPlaying = _audio.playing != null;
    final downloaded = track != null && _audio.downloaded.contains(track.id);
    final screen = Scaffold(
      appBar: widget.embedded && _selected.isEmpty ? null : AppBar(
        leading: _selected.isEmpty ? null : IconButton(tooltip: context.t('Seçimi iptal et'),
          onPressed: _busy ? null : () => setState(_selected.clear), icon: const Icon(Icons.close)),
        title: ScreenTitle(context, _selected.isEmpty ? context.t("Kur'an dinle") : context.t('{count} seçildi', {'count': _selected.length})),
        actions: _selected.isEmpty ? const <Widget>[] : [
          IconButton(key: const ValueKey('audio-delete-selected'), tooltip: context.t('Seçilen sesleri sil'),
            onPressed: _busy || isPlaying ? null : _removeSelected, icon: const Icon(Icons.delete_outline)),
        ]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        SearchableSurahField(key: const ValueKey('listening-surah'), value: _surah,
          onChanged: _busy || isPlaying ? null : (value) {
            if (mounted) setState(() { _surah = value; _verse.text = '1'; });
          }),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(key: ValueKey('reciter-${_audio.reciter}'),
          initialValue: _audio.reciter, isExpanded: true,
          decoration: InputDecoration(labelText: context.t('Okuyucu')),
          items: [for (final entry in _audio.reciters.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value))],
          onChanged: _busy || isPlaying || _selected.isNotEmpty ? null : (id) { if (id != null) _run(() => _audio.selectReciter(id)); }),
        const SizedBox(height: 12),
        Text(context.t('Durdurma iste\u011fi ayet sonunda uygulan\u0131r.')),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: ChoiceChip(label: Text(context.t('Sure')), selected: !_singleVerse,
            onSelected: _busy || isPlaying ? null : (_) => setState(() => _singleVerse = false))),
          const SizedBox(width: 8),
          Expanded(child: ChoiceChip(label: Text(context.t('Ayet')), selected: _singleVerse,
            onSelected: _busy || isPlaying ? null : (_) => setState(() => _singleVerse = true))),
        ]),
        if (_singleVerse) Padding(padding: const EdgeInsets.only(top: 16), child: TextField(
          controller: _verse, keyboardType: TextInputType.number, enabled: !_busy && !isPlaying,
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
        if (track != null || isPlaying)
          FilledButton.icon(
            onPressed: _busy || _audio.stopPending || _selected.isNotEmpty ? null : isPlaying
              ? () => _run(_audio.stop)
              : downloaded ? () => _run(() => _audio.play(track))
              : () => _download(track!),
            icon: Icon(isPlaying ? Icons.stop : downloaded ? Icons.play_arrow : Icons.download),
            label: Text(context.t(isPlaying
              ? (_audio.stopPending ? 'Ayet sonunda duracak' : 'Durdur')
              : downloaded ? 'Dinle' : 'Ses dosyas\u0131n\u0131 indir'))),
        if (isPlaying && _audio.currentVerse != null)
          Text(context.t('Okunan ayet: {number}', {'number': _audio.currentVerse!})),
        if (_audio.playbackError != null) Text(context.t('Ses işlemi tamamlanamadı. Tekrar dene.')),
        const SizedBox(height: 24),
        Text(context.t('İndirilen sesler'), style: Theme.of(context).textTheme.titleLarge),
        if (_audio.downloaded.isEmpty) Text(context.t('Henüz indirilmiş ses dosyası yok.')),
        for (final item in _audio.tracks.where((t) => t.page == null && _audio.downloaded.contains(t.id) &&
          (t.verse == null || !_audio.downloaded.contains(_audio.find(t.surah, null)?.id)))) Card(child: ListTile(
          key: ValueKey('downloaded-audio-${item.id}'), selected: _selected.contains(item.id),
          onLongPress: _busy || isPlaying ? null : () => _select(item),
          onTap: _selected.isEmpty || _busy || isPlaying ? null : () => _select(item),
          title: Text(surahName(surahs[item.surah - 1], context.language)),
          subtitle: item.verse == null ? Text(context.t('Surenin tamamı')) : Text(context.t('Ayet {number}', {'number': item.verse!})),
          leading: _selected.isNotEmpty ? Checkbox(value: _selected.contains(item.id),
            onChanged: _busy || isPlaying ? null : (_) => _select(item))
            : IconButton(tooltip: context.t('Dinle'), icon: const Icon(Icons.play_arrow),
            onPressed: _busy || isPlaying ? null : () => _run(() => _audio.play(item))),
          trailing: _selected.isNotEmpty ? null : IconButton(tooltip: context.t('Ses dosyasını cihazımdan sil'), icon: const Icon(Icons.delete_outline),
            onPressed: _busy || isPlaying ? null : () => _remove(item)),
        )),
      ]),
    );
    final swipeable = PersonalPageSwipe(onNavigate: (delta) => AppNavigation.instance.switchPage?.call(delta), child: screen);
    if (widget.embedded) return swipeable;
    return PopScope(canPop: _selected.isEmpty, onPopInvokedWithResult: (didPop, _) {
      if (!didPop && !_busy) setState(_selected.clear);
    }, child: swipeable);
  }
}

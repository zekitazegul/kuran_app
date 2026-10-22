import '../widgets/screen_title.dart';

import 'dart:async';

import '../services/prayer_audio_library.dart';
import '../widgets/prayer_download_dialog.dart';

import 'package:flutter/material.dart';

import '../services/reading_store.dart';
import '../l10n/translations.dart';

const hatimPrayer =
    'Allah’ım! Okuduğumuz Kur’an’ı kabul eyle. Kur’an’ı kalplerimize nur, hayatımıza rehber eyle. Bize onu anlamayı ve onunla yaşamayı nasip eyle. Bizleri, ailelerimizi ve bütün müminleri bağışla. Hastalarımıza şifa, dertlilerimize ferahlık ver. Dünyada ve ahirette bize iyilik ver. Duamızı kabul eyle. Âmin.';

class HatimPrayerScreen extends StatefulWidget {
  final ReadingStore? store;
  const HatimPrayerScreen({super.key, this.store});
  @override
  State<HatimPrayerScreen> createState() => _HatimPrayerScreenState();
}

class _HatimPrayerScreenState extends State<HatimPrayerScreen>
    with WidgetsBindingObserver {
  bool playing = false;
  bool downloaded = false;
  bool loadingAudio = true;
  int _playRequest = 0;
  String? error;
  double _dragDistance = 0;
  bool _restarting = false;
  Future<void> _restart() async {
    if (_restarting) return;
    setState(() => _restarting = true);
    try {
      await widget.store!.saveHatim(
        widget.store!.hatimPages.toList(),
        read: false,
        resume: widget.store!.edition.firstPage,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          error = context.t('Tercih kaydedilemedi.');
          _restarting = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadRecording();
  }

  Future<void> loadRecording() async {
    try {
      final ready =
          await ReadingStore.channel.invokeMethod<bool>(
            'isHatimPrayerDownloaded',
          ) ==
          true;
      if (!mounted) return;
      setState(() {
        downloaded = ready;
        loadingAudio = false;
      });
      if (ready) await playRecording();
    } catch (_) {
      if (mounted) {
        setState(() {
          loadingAudio = false;
          error = context.t('prayerAudioError');
        });
      }
    }
  }

  Future<void> requestRecording() async {
    setState(() => loadingAudio = true);
    try {
      final library = await PrayerAudioLibrary.load();
      if (!mounted) return;
      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PrayerDownloadDialog(library: library),
      );
      if (!mounted || accepted != true) return;
      setState(() {
        downloaded = true;
        loadingAudio = false;
      });
      unawaited(playRecording());
    } catch (_) {
      if (mounted) setState(() => error = context.t('prayerDownloadError'));
    } finally {
      if (mounted) setState(() => loadingAudio = false);
    }
  }

  Future<void> playRecording() async {
    final request = ++_playRequest;
    setState(() {
      playing = true;
      error = null;
    });
    try {
      await ReadingStore.channel.invokeMethod<void>('playHatimPrayer');
    } catch (_) {
      if (mounted && request == _playRequest) {
        setState(() => error = context.t('prayerAudioError'));
      }
    } finally {
      if (mounted && request == _playRequest) setState(() => playing = false);
    }
  }

  Future<void> stop() async {
    ++_playRequest;
    try {
      await ReadingStore.channel.invokeMethod<void>('stopHatimPrayer');
    } catch (_) {}
    if (mounted) setState(() => playing = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(stop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: ScreenTitle(context, context.t('Hatim duası'))),
    body: GestureDetector(
      onHorizontalDragStart: (_) => _dragDistance = 0,
      onHorizontalDragUpdate: (details) => _dragDistance += details.delta.dx,
      onHorizontalDragEnd: (details) {
        if (_dragDistance < -24 || (details.primaryVelocity ?? 0) < -80) {
          Navigator.pop(context);
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: Text(context.t('Okumaya dön')),
          ),
          Icon(
            widget.store?.hatimComplete == true
                ? Icons.task_alt
                : Icons.headphones_outlined,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            context.t(
              widget.store?.hatimComplete == true
                  ? 'Hatminiz tamamlandı'
                  : 'Hatim duası',
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Text(context.t('prayerRecordingDetails')),
          if (error != null) Text(error!),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: loadingAudio
                ? null
                : playing
                ? stop
                : downloaded
                ? playRecording
                : requestRecording,
            icon: Icon(playing ? Icons.stop : Icons.volume_up),
            label: Text(
              context.t(
                playing
                    ? 'Durdur'
                    : downloaded
                    ? 'Tekrar dinle'
                    : 'prayerDownloadTitle',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.t('prayerTurkishExample'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(hatimPrayer, style: TextStyle(fontSize: 22, height: 1.7)),
          if (widget.store != null)
            TextButton(
              onPressed: _restarting ? null : _restart,
              child: Text(context.t('Yeni hatme başla')),
            ),
        ],
      ),
    ),
  );
}

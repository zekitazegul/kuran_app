import 'package:flutter/material.dart';

import '../services/prayer_audio_library.dart';
import '../l10n/translations.dart';
import '../services/reading_store.dart';

class PrayerDownloadDialog extends StatefulWidget {
  const PrayerDownloadDialog({super.key, required this.library});
  final PrayerAudioLibrary library;

  @override
  State<PrayerDownloadDialog> createState() => _PrayerDownloadDialogState();
}

class _PrayerDownloadDialogState extends State<PrayerDownloadDialog> {
  bool downloading = false;
  double progress = 0;
  String? error;

  @override
  void dispose() {
    widget.library.cancel();
    super.dispose();
  }

  Future<void> download() async {
    setState(() {
      downloading = true;
      error = null;
    });
    try {
      await widget.library.download((received, total) {
        final next = received / total;
        if (mounted && (next * 100).floor() != (progress * 100).floor()) {
          setState(() => progress = next);
        }
      });
      final verified = await ReadingStore.channel.invokeMethod<bool>(
        'isHatimPrayerDownloaded',
      );
      if (verified != true) throw StateError('Recording verification failed');
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          downloading = false;
          error = context.t('prayerDownloadError');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(context.t('prayerDownloadTitle')),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('prayerDownloadHint', {
            'size': (widget.library.totalBytes / 1000000).ceil(),
          }),
        ),
        if (downloading) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text(
            '${context.t('updateDownloading')} %${(progress * 100).floor()}',
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(context.t('downloadCancel')),
      ),
      if (!downloading)
        FilledButton(
          onPressed: download,
          child: Text(
            context.t(error == null ? 'downloadAccept' : 'prayerRetry'),
          ),
        ),
    ],
  );
}

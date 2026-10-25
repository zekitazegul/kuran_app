import 'package:flutter/services.dart';

class AudioTrack {
  final String id;
  final int surah;
  final int? verse;
  final int? page;
  final int bytes;
  const AudioTrack({required this.id, required this.surah, required this.bytes, this.verse, this.page});
  factory AudioTrack.fromMap(Map data) => AudioTrack(id: data['id'] as String,
    surah: data['surah'] as int, verse: data['verse'] as int?, page: data['page'] as int?, bytes: (data['bytes'] as num).toInt());
}

/// Ayah recordings are cached locally and sequenced by the native player.
class QuranAudio {
  static const channel = MethodChannel('com.zekitazegul.kuranapp/reading');
  List<AudioTrack> tracks = [];
  Set<String> downloaded = {};
  String? playing;
  bool stopPending = false;
  bool paused = false;
  int? currentSurah;
  int repeatTotal = 0, repeatCurrent = 0, repeatRemaining = 0, repeatCompleted = 0;
  bool memorizing = false;
  int? currentVerse;
  String? playbackError;
  String reciter = 'shatri';
  Map<String, String> reciters = {'shatri': 'Abu Bakr Ash-Shatri', 'alafasy': 'Mishary Rashid Alafasy',
    'minshawi': 'Muhammad Siddiq Al-Minshawi', 'abdulbasit': 'Abdul Basit Abdus Samad',
    'maher': 'Mahir al Muaiqly'};
  Future<void> load() async {
    final result = await channel.invokeMapMethod<String, dynamic>('loadAudio');
    if (result == null) throw StateError('Audio state unavailable');
    tracks = (result['tracks'] as List).map((entry) => AudioTrack.fromMap(entry as Map)).toList();
    downloaded = Set<String>.from(result['downloaded'] as List);
    playing = result['playing'] as String?;
    stopPending = result['stopPending'] == true;
    paused = result['paused'] == true;
    currentSurah = result['currentSurah'] as int?;
    repeatTotal = result['repeatTotal'] as int? ?? 0;
    repeatCurrent = result['repeatCurrent'] as int? ?? 0;
    repeatRemaining = result['repeatRemaining'] as int? ?? 0;
    repeatCompleted = result['repeatCompleted'] as int? ?? 0;
    memorizing = result['memorizing'] == true;
    currentVerse = result['currentVerse'] as int?;
    playbackError = result['error'] as String?;
    reciter = result['reciter'] as String? ?? 'shatri';
    if (result['reciters'] is List) {
      reciters = {for (final entry in result['reciters'] as List) entry['id'] as String: entry['name'] as String};
    }
  }
  Future<void> selectReciter(String id) async {
    if (playing != null) throw StateError('Current verse must finish first');
    await channel.invokeMethod<void>('selectAudioReciter', {'id': id});
    await load();
  }
  AudioTrack? find(int surah, int? verse) {
    for (final track in tracks) {
      if (track.page == null && track.surah == surah && track.verse == verse) return track;
    }
    return null;
  }
  AudioTrack? findPage(int page) {
    for (final track in tracks) { if (track.page == page) return track; }
    return null;
  }
  Future<void> download(AudioTrack track) async {
    if (downloaded.contains(track.id)) return;
    await channel.invokeMethod<void>('downloadAudio', {'id': track.id});
    downloaded.add(track.id);
  }
  Future<void> play(AudioTrack track, {int repetitions = 1}) async {
    if (playing != null) throw StateError('Current verse must finish first');
    if (!downloaded.contains(track.id)) throw StateError('Download required');
    await channel.invokeMethod<void>('playAudio', {'id': track.id, 'repetitions': repetitions});
    playing = track.id;
    stopPending = false;
    currentVerse = track.verse ?? 1;
  }
  Future<void> pause() async { await channel.invokeMethod<void>('pauseAudio'); await load(); }
  Future<void> resume() async { await channel.invokeMethod<void>('resumeAudio'); await load(); }
  Future<void> replay() async { await channel.invokeMethod<void>('replayAudio'); await load(); }
  Future<void> stopImmediately() async { await channel.invokeMethod<void>('stopAudioImmediately'); await load(); }
  Future<void> stop() async {
    await channel.invokeMethod<void>('stopAudio');
    if (playing != null) stopPending = true;
  }
  Future<void> playRange(int surah, int first, int last, {int repetitions = 3, bool cumulative = false}) async {
    await channel.invokeMethod<void>('playAudioRange', {
      'surah': surah, 'first': first, 'last': last, 'repetitions': repetitions, 'cumulative': cumulative,
    });
    await load();
  }
  Future<void> playSelection(List<AudioTrack> tracks, {int repetitions = 1, bool cumulative = false}) async {
    if (playing != null) throw StateError('Current verse must finish first');
    if (tracks.isEmpty || tracks.any((track) => !downloaded.contains(track.id))) {
      throw StateError('Download required');
    }
    await channel.invokeMethod<void>('playAudioSelection', {'ids': tracks.map((track) => track.id).toList(), 'repetitions': repetitions, 'cumulative': cumulative});
    await load();
  }
  Future<void> advanceMemorization() async {
    await channel.invokeMethod<void>('advanceMemorization');
    await load();
  }
  Future<void> remove(AudioTrack track) async {
    if (playing != null) throw StateError('Current verse must finish first');
    await channel.invokeMethod<void>('removeAudio', {'id': track.id});
    downloaded.remove(track.id);
    if (playing == track.id) playing = null;
  }
}

import 'package:flutter/services.dart';

class AudioTrack {
  final String id;
  final int surah;
  final int? verse;
  final int bytes;
  const AudioTrack({required this.id, required this.surah, required this.bytes, this.verse});
  factory AudioTrack.fromMap(Map data) => AudioTrack(id: data['id'] as String,
    surah: data['surah'] as int, verse: data['verse'] as int?, bytes: (data['bytes'] as num).toInt());
}

/// Local, free listening state. Recordings are deliberately absent until
/// licensed sources and their exact checksums are added to assets/audio.json.
class QuranAudio {
  static const channel = MethodChannel('com.zekitazegul.kuranapp/reading');
  List<AudioTrack> tracks = [];
  Set<String> downloaded = {};
  String? playing;
  Future<void> load() async {
    final result = await channel.invokeMapMethod<String, dynamic>('loadAudio');
    if (result == null) throw StateError('Audio state unavailable');
    tracks = (result['tracks'] as List).map((entry) => AudioTrack.fromMap(entry as Map)).toList();
    downloaded = Set<String>.from(result['downloaded'] as List);
    playing = result['playing'] as String?;
  }
  AudioTrack? find(int surah, int? verse) {
    for (final track in tracks) {
      if (track.surah == surah && track.verse == verse) return track;
    }
    return null;
  }
  Future<void> download(AudioTrack track) async {
    if (downloaded.contains(track.id)) return;
    await channel.invokeMethod<void>('downloadAudio', {'id': track.id});
    downloaded.add(track.id);
  }
  Future<void> play(AudioTrack track) async {
    if (!downloaded.contains(track.id)) throw StateError('Download required');
    await channel.invokeMethod<void>('playAudio', {'id': track.id});
    playing = track.id;
  }
  Future<void> stop() async {
    await channel.invokeMethod<void>('stopAudio');
    playing = null;
  }
  Future<void> remove(AudioTrack track) async {
    await channel.invokeMethod<void>('removeAudio', {'id': track.id});
    downloaded.remove(track.id);
    if (playing == track.id) playing = null;
  }
}

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Supply actual decoded test images now that the root screen opens the reader.
void cacheReadingImages(String directory, Iterable<int> pages) {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawColor(Colors.white, BlendMode.src);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(2,2); picture.dispose();
  for (final page in pages) {
    final provider = FileImage(File('$directory/page${page.toString().padLeft(3,'0')}.png'));
    PaintingBinding.instance.imageCache.putIfAbsent(provider, () =>
      OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image.clone()))));
  }
  image.dispose();
  addTearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
}

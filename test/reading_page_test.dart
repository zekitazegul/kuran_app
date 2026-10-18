import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/widgets/reading_page.dart';

void main() {
  testWidgets('changing a page clears the old image until the next image arrives', (tester) async {
    final picture = ui.PictureRecorder();
    Canvas(picture).drawColor(Colors.white, BlendMode.src);
    final drawing = picture.endRecording();
    final image = drawing.toImageSync(2, 2);
    drawing.dispose();
    final first = FileImage(File('/first-page.png'));
    final second = FileImage(File('/pending-page.png'));
    final pending = Completer<ImageInfo>();
    final cache = PaintingBinding.instance.imageCache;
    cache.putIfAbsent(first, () => OneFrameImageStreamCompleter(
      SynchronousFuture(ImageInfo(image: image.clone()))));
    cache.putIfAbsent(second, () => OneFrameImageStreamCompleter(pending.future));
    Widget page(ImageProvider provider) => MaterialApp(home: ReadingPage(image: provider));
    await tester.pumpWidget(page(first));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpWidget(page(second));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(ImageInfo(image: image.clone()));
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpWidget(const SizedBox());
    cache.clear();
    cache.clearLiveImages();
    image.dispose();
    expect(tester.takeException(), isNull);
  });
}

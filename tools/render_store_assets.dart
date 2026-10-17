// Run: flutter test tools/render_store_assets.dart
// Renders the existing app identity with Canvas; does not alter the source logo.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('render Google Play brand assets', (tester) async {
    await tester.runAsync(() async {
      final fontPath = Platform.environment['STORE_FONT'] ?? 'C:/Windows/Fonts/segoeui.ttf';
      final loader = FontLoader('StoreFont')
        ..addFont(File(fontPath).readAsBytes().then((bytes) => ByteData.sublistView(bytes)));
      await loader.load();
      final codec = await ui.instantiateImageCodec(await File('assets/branding/quran.png').readAsBytes());
      final artwork = (await codec.getNextFrame()).image;
      final output = Directory('publishing/google-play/graphics')..createSync(recursive: true);
      Future<void> render(String name, int width, int height, void Function(ui.Canvas) draw) async {
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        canvas.drawColor(const ui.Color(0xFFFFFCF5), ui.BlendMode.src);
        draw(canvas);
        final picture = recorder.endRecording();
        final image = await picture.toImage(width, height);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('${output.path}/$name').writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose(); picture.dispose();
      }
      void logo(ui.Canvas canvas, ui.Rect target) => canvas.drawImageRect(artwork,
        ui.Rect.fromLTWH(0, 0, artwork.width.toDouble(), artwork.height.toDouble()),
        target, ui.Paint()..filterQuality = ui.FilterQuality.high);
      void text(ui.Canvas canvas, String text, double size, double x, double y, double width) {
        final builder = ui.ParagraphBuilder(ui.ParagraphStyle(fontFamily: 'StoreFont', fontSize: size))
          ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF164D43)))..addText(text);
        final paragraph = builder.build()..layout(ui.ParagraphConstraints(width: width));
        canvas.drawParagraph(paragraph, ui.Offset(x, y)); paragraph.dispose();
      }
      await render('icon-512.png', 512, 512,
        (canvas) => logo(canvas, const ui.Rect.fromLTWH(24, 24, 464, 464)));
      for (final entry in const {
        'tr-TR': ['Oku · Dinle · Devam et', 'Kur’an ve Türkçe meal'],
        'en-US': ['Read · Listen · Continue', 'Quran and Turkish translation'],
        'nl-NL': ['Lees · Luister · Ga verder', 'Koran en Turkse vertaling'],
      }.entries) {
        await render('feature-${entry.key}-1024x500.png', 1024, 500, (canvas) {
          canvas.drawRect(const ui.Rect.fromLTWH(52, 78, 72, 5), ui.Paint()..color = const ui.Color(0xFF9E7C45));
          text(canvas, 'KuranApp', 76, 48, 108, 600);
          text(canvas, entry.value[0], 31, 52, 235, 610);
          text(canvas, entry.value[1], 23, 52, 302, 610);
          logo(canvas, const ui.Rect.fromLTWH(664, 70, 330, 330));
        });
      }
      artwork.dispose(); codec.dispose();
    });
  });
}

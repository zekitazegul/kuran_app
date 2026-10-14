import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Coordinates measured in the original 538.583 × 779.528 point PDF.
Rect readingCrop(int page) {
  if (page == 0) return const Rect.fromLTRB(132.5, 264.3, 305.4, 513.8);
  if (page == 1) return const Rect.fromLTRB(232.4, 266.0, 405.4, 513.6);
  return const Rect.fromLTRB(78.5, 63.8, 461, 715);
}

Rect normalizedReadingCrop(int page) {
  final crop = readingCrop(page);
  return Rect.fromLTRB(crop.left / 538.583, crop.top / 779.528,
    crop.right / 538.583, crop.bottom / 779.528);
}

/// Crops only at drawing time, so full-page images and downloads are preserved.
class ReadingPage extends StatefulWidget {
  final ImageProvider image;
  final Rect? crop;
  const ReadingPage({super.key, required this.image, this.crop});
  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _image;
  bool _failed = false;
  @override
  void didChangeDependencies() { super.didChangeDependencies(); _resolve(); }
  @override
  void didUpdateWidget(ReadingPage old) {
    super.didUpdateWidget(old);
    if (old.image != widget.image) _resolve();
  }
  void _resolve() {
    if (_listener != null) _stream?.removeListener(_listener!);
    _stream = widget.image.resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener((info, _) {
      final image = info.image.clone();
      if (!mounted) { image.dispose(); return; }
      setState(() { _image?.dispose(); _image = image; _failed = false; });
    }, onError: (Object error, StackTrace? stack) {
      if (mounted) setState(() => _failed = true);
    });
    _stream!.addListener(_listener!);
  }
  @override
  void dispose() {
    if (_listener != null) _stream?.removeListener(_listener!);
    _image?.dispose(); super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (_failed) return const Center(child: Text('Sayfa görüntüsü okunamadı.'));
    if (_image == null) return const Center(child: CircularProgressIndicator());
    return CustomPaint(painter: _ReadingPainter(_image!, widget.crop));
  }
}

class _ReadingPainter extends CustomPainter {
  final ui.Image image;
  final Rect? crop;
  _ReadingPainter(this.image, this.crop);
  @override
  void paint(Canvas canvas, Size size) {
    final source = sourceRect(image, crop);
    final fitted = applyBoxFit(BoxFit.contain, source.size, size);
    canvas.drawImageRect(image, source,
      Alignment.center.inscribe(fitted.destination, Offset.zero & size),
      Paint()..filterQuality = FilterQuality.high);
  }
  @override
  bool shouldRepaint(_ReadingPainter old) => old.image != image || old.crop != crop;
}

Rect sourceRect(ui.Image image, Rect? crop) => crop == null
    ? Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble())
    : Rect.fromLTRB(crop.left * image.width, crop.top * image.height,
        crop.right * image.width, crop.bottom * image.height);

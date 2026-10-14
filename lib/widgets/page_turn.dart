import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Rolls the outgoing page around a curved fold, revealing the next page.
class PageTurn extends StatefulWidget {
  final ImageProvider image;
  final Animation<double> animation;
  final bool toRight;
  final Widget underneath;
  const PageTurn({super.key, required this.image, required this.animation,
    required this.toRight, required this.underneath});

  @override
  State<PageTurn> createState() => _PageTurnState();
}

class _PageTurnState extends State<PageTurn> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _image;

  @override
  void didChangeDependencies() { super.didChangeDependencies(); _resolve(); }

  @override
  void didUpdateWidget(PageTurn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _resolve();
  }

  void _resolve() {
    if (_listener != null) _stream?.removeListener(_listener!);
    _stream = widget.image.resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener((info, _) {
      final image = info.image.clone();
      if (!mounted) { image.dispose(); return; }
      setState(() { _image?.dispose(); _image = image; });
    }, onError: (Object error, StackTrace? stack) {
      if (mounted) setState(() { _image?.dispose(); _image = null; });
    });
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) _stream?.removeListener(_listener!);
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    widget.underneath,
    AnimatedBuilder(animation: widget.animation, builder: (context, _) {
      if (_image == null) return const SizedBox.shrink();
      return CustomPaint(painter: _CurlPainter(_image!,
        Curves.easeInOutCubic.transform(widget.animation.value), widget.toRight));
    }),
  ]);
}

class _CurlPainter extends CustomPainter {
  final ui.Image image;
  final double progress;
  final bool toRight;
  _CurlPainter(this.image, this.progress, this.toRight);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final fitted = applyBoxFit(BoxFit.contain,
      Size(image.width.toDouble(), image.height.toDouble()), size);
    final page = Alignment.center.inscribe(fitted.destination, Offset.zero & size);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(toRight ? page.right : page.left, page.top);
    if (toRight) canvas.scale(-1, 1);
    final w = page.width, h = page.height;
    if (progress == 0) {
      canvas.save();
      if (toRight) { canvas.translate(w, 0); canvas.scale(-1, 1); }
      canvas.drawImageRect(image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), Rect.fromLTWH(0, 0, w, h), Paint()..filterQuality = FilterQuality.high);
      canvas.restore(); canvas.restore(); return;
    }
    final radius = w * 0.12;
    final fold = w - progress * (w + radius * math.pi);
    canvas.drawRect(Rect.fromLTWH(math.max(0.0, fold), 0, radius * 1.8, h),
      Paint()..shader = const LinearGradient(colors: [Colors.black26, Colors.transparent])
        .createShader(Rect.fromLTWH(math.max(0.0, fold), 0, radius * 1.8, h)));
    // Narrow strips follow a cylindrical curve; the reverse side is blank paper.
    const strips = 160;
    for (int i = 0; i < strips; i++) {
      final x = w * i / strips;
      final strip = w / strips;
      final angle = ((x - fold) / radius).clamp(0.0, math.pi);
      if (x > fold + radius * math.pi) continue;
      final dx = x <= fold ? x : fold + radius * math.sin(angle);
      final nextAngle = ((x + strip - fold) / radius).clamp(0.0, math.pi);
      final nextX = x + strip <= fold ? x + strip : fold + radius * math.sin(nextAngle);
      final lift = math.sin(angle / 2) * h * 0.025;
      final dest = Rect.fromLTWH(math.min(dx, nextX), -lift, (nextX - dx).abs() + 0.6, h + lift * 2);
      if (angle > math.pi / 2) {
        canvas.drawRect(dest, Paint()..color = Color.lerp(const Color(0xFFFFF9EA), const Color(0xFFD8CCB4), math.sin(angle))!);
      } else {
        final srcX = (toRight ? w - x - strip : x) / w * image.width;
        canvas.save();
        if (toRight) { canvas.translate(dest.left + dest.right, 0); canvas.scale(-1, 1); }
        canvas.drawImageRect(image, Rect.fromLTWH(srcX, 0, strip / w * image.width, image.height.toDouble()), dest, Paint()..filterQuality = FilterQuality.medium);
        canvas.restore();
        if (angle > 0) canvas.drawRect(dest, Paint()..color = Colors.black.withValues(alpha: math.sin(angle) * 0.22));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CurlPainter oldDelegate) => oldDelegate.image != image || oldDelegate.progress != progress || oldDelegate.toRight != toRight;
}

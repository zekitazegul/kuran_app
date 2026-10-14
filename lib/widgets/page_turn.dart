import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'page_fold.dart';

/// Interactive paper fold with a moving crease and a shaded reverse side.
class PageTurn extends StatefulWidget {
  final ImageProvider image;
  final Animation<double> animation;
  final bool toRight;
  final Widget underneath;
  final double touchHeight;
  final double dragTilt;
  const PageTurn({super.key, required this.image, required this.animation,
    required this.toRight, required this.underneath,
    this.touchHeight = 0.85, this.dragTilt = 0});

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
        widget.animation.value, widget.toRight, widget.touchHeight, widget.dragTilt));
    }),
  ]);
}

class _CurlPainter extends CustomPainter {
  final ui.Image image;
  final double progress;
  final bool toRight;
  final double touchHeight;
  final double dragTilt;
  _CurlPainter(this.image, this.progress, this.toRight, this.touchHeight, this.dragTilt);

  Path _path(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) { path.lineTo(point.dx, point.dy); }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final fitted = applyBoxFit(BoxFit.contain,
      Size(image.width.toDouble(), image.height.toDouble()), size);
    final page = Alignment.center.inscribe(fitted.destination, Offset.zero & size);
    final source = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    if (progress <= 0.001) {
      canvas.drawImageRect(image, source, page, Paint()..filterQuality = FilterQuality.high);
      return;
    }
    final anchor = Offset(toRight ? page.left : page.right,
      (size.height * touchHeight).clamp(page.top, page.bottom).toDouble());
    final travel = page.width * 2.1 * progress;
    final finger = anchor + Offset(toRight ? travel : -travel,
      dragTilt * (1 - progress));
    final fold = PageFold(anchor, finger);
    final corners = [page.topLeft, page.topRight, page.bottomRight, page.bottomLeft];
    final visible = _path(fold.clip(corners, folded: false));
    final foldedPoints = fold.clip(corners, folded: true);
    final back = _path(foldedPoints.map(fold.reflect).toList());
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // The stationary part remains in place, rather than sliding off-screen.
    canvas.save(); canvas.clipPath(visible);
    canvas.drawImageRect(image, source, page, Paint()..filterQuality = FilterQuality.high);
    canvas.restore();
    if (foldedPoints.length >= 3) {
      canvas.drawShadow(back, Colors.black.withValues(alpha: 0.55), 14, false);
      canvas.drawPath(back, Paint()..color = const Color(0xFFFFFBEF));
      canvas.save(); canvas.clipPath(back);
      // A faint reverse-side impression makes the turning sheet translucent.
      final nx = fold.normal.dx, ny = fold.normal.dy;
      final dot = nx * fold.midpoint.dx + ny * fold.midpoint.dy;
      canvas.transform((Matrix4.identity()
        ..setValues(1 - 2 * nx * nx, -2 * nx * ny, 0, 0,
          -2 * nx * ny, 1 - 2 * ny * ny, 0, 0,
          0, 0, 1, 0, 2 * nx * dot, 2 * ny * dot, 0, 1))
        .storage);
      canvas.drawImageRect(image, source, page,
        Paint()..color = Colors.white.withValues(alpha: 0.055)..filterQuality = FilterQuality.medium);
      canvas.restore();
      // Broad rounded lighting around the crease suggests the paper's curvature.
      final band = (page.width * 0.08).clamp(12.0, 55.0).toDouble();
      final a = fold.midpoint - fold.normal * band;
      final b = fold.midpoint + fold.normal * band;
      final shader = ui.Gradient.linear(a, b,
        [const Color(0xFF9F927A), const Color(0xFFFFFEF8), const Color(0xFFE5D9BF)], [0, .5, 1]);
      canvas.save(); canvas.clipPath(back);
      canvas.drawRect(page.inflate(page.width), Paint()..shader = shader);
      canvas.restore();
      canvas.drawPath(back, Paint()..style = PaintingStyle.stroke
        ..strokeWidth = 0.7..color = const Color(0xFFBAAA8C));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CurlPainter old) => old.image != image || old.progress != progress ||
    old.toRight != toRight || old.touchHeight != touchHeight || old.dragTilt != dragTilt;
}

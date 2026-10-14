import 'dart:math' as math;

enum ReaderTapRegion { nextPage, previousPage, fullscreen }

ReaderTapRegion readerTapRegion(double x, double width, double centimeterWidth) {
  final edge = math.min(centimeterWidth, width * .2);
  if (x < edge) return ReaderTapRegion.nextPage;
  if (x > width - edge) return ReaderTapRegion.previousPage;
  return ReaderTapRegion.fullscreen;
}

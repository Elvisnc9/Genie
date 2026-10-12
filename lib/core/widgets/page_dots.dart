import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Onboarding page indicator. Not animated on a timer: it is driven by the
/// pager's continuous [page] value, so the teal pill stretches and slides
/// exactly with the user's finger.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.page});

  final int count;

  /// Current page, fractional while scrolling (e.g. 1.4).
  final double page;

  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    final current = page.round().clamp(0, count - 1);
    const d = GenieSizes.pageDot;
    const a = GenieSizes.pageDotActive;
    final width = a + (count - 1) * (d + _gap);
    return Semantics(
      label: 'Page ${current + 1} of $count',
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(width, d),
          painter: _DotsPainter(count: count, page: page.clamp(0, count - 1).toDouble()),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.count, required this.page});

  final int count;
  final double page;

  @override
  void paint(Canvas canvas, Size size) {
    const d = GenieSizes.pageDot;
    const extra = GenieSizes.pageDotActive - d;
    final paint = Paint()..isAntiAlias = true;
    var x = 0.0;
    for (var i = 0; i < count; i++) {
      // 1 when this dot is the current page, falling to 0 one page away.
      final t = (1 - (page - i).abs()).clamp(0.0, 1.0);
      final w = d + extra * t;
      paint.color = Color.lerp(GenieColors.dotInactive, GenieColors.teal, t)!;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, w, d), const Radius.circular(d / 2)), paint);
      x += w + PageDots._gap;
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.page != page || old.count != count;
}

import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Genie's AI mark: a filled four-point star with concave sides.
class SparkleIcon extends StatelessWidget {
  const SparkleIcon({super.key, this.size = GenieSizes.iconSmall, this.color = GenieColors.teal});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(child: CustomPaint(size: Size.square(size), painter: _SparklePainter(color)));
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    // Control points pulled toward the centre give the pinched, concave sides.
    const pinch = 0.14;
    final path =
        Path()
          ..moveTo(cx, 0)
          ..quadraticBezierTo(cx + w * pinch, cy - h * pinch, w, cy)
          ..quadraticBezierTo(cx + w * pinch, cy + h * pinch, cx, h)
          ..quadraticBezierTo(cx - w * pinch, cy + h * pinch, 0, cy)
          ..quadraticBezierTo(cx - w * pinch, cy - h * pinch, cx, 0)
          ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}

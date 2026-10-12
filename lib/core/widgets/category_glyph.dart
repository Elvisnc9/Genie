import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// The furniture category icons. Lucide where it has the shape; drawn line
/// glyphs (same 24 grid, 1.8 stroke, round caps) for a dining chair and a
/// pedestal table. Takes its colour and size from the surrounding IconTheme.
class CategoryGlyph extends StatelessWidget {
  const CategoryGlyph(this.categoryId, {super.key, this.size});

  final String categoryId;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? GenieSizes.icon;
    final color = theme.color ?? GenieColors.ink;
    final path = switch (categoryId) {
      'chairs' => _chair,
      'tables' => _table,
      _ => null,
    };
    if (path == null) {
      return Icon(
        switch (categoryId) {
          'armchairs' => GenieIcons.armchairs,
          'sofas' => GenieIcons.sofas,
          'lighting' => GenieIcons.lighting,
          'plants' => GenieIcons.plants,
          _ => GenieIcons.place,
        },
        size: s,
        color: color,
      );
    }
    return ExcludeSemantics(child: CustomPaint(size: Size.square(s), painter: _LinePainter(path, color)));
  }

  static Path _chair() =>
      Path()
        ..addRRect(RRect.fromLTRBR(7, 3, 17, 11, const Radius.circular(1.5)))
        ..moveTo(7, 11)
        ..lineTo(7, 21)
        ..moveTo(17, 11)
        ..lineTo(17, 21)
        ..moveTo(5.5, 13.5)
        ..lineTo(18.5, 13.5);

  static Path _table() =>
      Path()
        ..addOval(const Rect.fromLTRB(3.5, 5, 20.5, 9.5))
        ..moveTo(12, 9.5)
        ..lineTo(12, 20.5)
        ..moveTo(8, 20.5)
        ..lineTo(16, 20.5);
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.path, this.color);

  final Path Function() path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    canvas.drawPath(
      path(),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.color != color;
}

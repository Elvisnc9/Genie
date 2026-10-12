import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'glass_surface.dart';
import 'sparkle_icon.dart';

/// A placed-piece / colour-read pin: soft white halo, white disc, teal dot.
class PinDot extends StatelessWidget {
  const PinDot({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GenieColors.card.withValues(alpha: 0.55),
            boxShadow: [BoxShadow(color: GenieShadows.tint(0.12), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Center(
            child: Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: const BoxDecoration(color: GenieColors.card, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Container(
                width: size * 0.36,
                height: size * 0.36,
                decoration: const BoxDecoration(color: GenieColors.teal, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Soft sage wall": a glass pill with the colour Genie read from the room.
class ColorReadPill extends StatelessWidget {
  const ColorReadPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w600);
    return Semantics(
      label: 'Colour read: $label',
      child: GlassSurface(
        borderRadius: GenieRadii.pillAll,
        padding: const EdgeInsets.fromLTRB(5, 5, GenieSpace.sm, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: GenieColors.card, width: 1.5),
              ),
            ),
            const SizedBox(width: 7),
            ExcludeSemantics(child: Text(label, style: style)),
          ],
        ),
      ),
    );
  }
}

/// Sparkle drawn into the scene (white on photos, teal on the AI suggestion).
class SceneSparkle extends StatelessWidget {
  const SceneSparkle({super.key, required this.size, this.color = GenieColors.sparkle});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: size * 0.6)],
      ),
      child: SparkleIcon(size: size, color: color),
    );
  }
}

/// The dashed teal outline marking where a suggestion would fit.
class DashedBox extends StatelessWidget {
  const DashedBox({super.key, this.radius = 16, this.color = GenieColors.teal, this.fill});

  final double radius;
  final Color color;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashedRRectPainter(radius, color, fill));
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter(this.radius, this.color, this.fill);

  final double radius;
  final Color color;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    if (fill != null) canvas.drawRRect(rrect, Paint()..color = fill!);
    _dash(
      canvas,
      Path()..addRRect(rrect.deflate(0.8)),
      Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) => old.color != color || old.radius != radius || old.fill != fill;
}

/// Draws [path] as dashes.
void _dash(Canvas canvas, Path path, Paint paint, {double dash = 6, double gap = 5}) {
  for (final metric in path.computeMetrics()) {
    var d = 0.0;
    while (d < metric.length) {
      canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), paint);
      d += dash + gap;
    }
  }
}

/// Teal inner glow around the screen edge while AI mode is on.
class EdgeGlow extends StatelessWidget {
  const EdgeGlow({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: GenieMotion.base,
        curve: GenieMotion.easeOut,
        child: const RepaintBoundary(child: CustomPaint(painter: _EdgeGlowPainter(), size: Size.infinite)),
      ),
    );
  }
}

class _EdgeGlowPainter extends CustomPainter {
  const _EdgeGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const depth = 16.0;
    final rect = Offset.zero & size;
    final strong = GenieColors.teal.withValues(alpha: 0.28);
    final clear = GenieColors.teal.withValues(alpha: 0);
    void band(Rect r, Alignment from, Alignment to) {
      canvas.drawRect(
        r,
        Paint()..shader = LinearGradient(begin: from, end: to, colors: [strong, clear]).createShader(r),
      );
    }

    band(Rect.fromLTWH(0, 0, size.width, depth), Alignment.topCenter, Alignment.bottomCenter);
    band(Rect.fromLTWH(0, size.height - depth, size.width, depth), Alignment.bottomCenter, Alignment.topCenter);
    band(Rect.fromLTWH(0, 0, depth, size.height), Alignment.centerLeft, Alignment.centerRight);
    band(Rect.fromLTWH(size.width - depth, 0, depth, size.height), Alignment.centerRight, Alignment.centerLeft);
    canvas.drawRect(
      rect.deflate(1.5),
      Paint()
        ..color = GenieColors.teal.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_EdgeGlowPainter old) => false;
}

/// The placement reticle: white ring, teal tint, centre dot.
class Reticle extends StatelessWidget {
  const Reticle({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: size, painter: const _ReticlePainter());
  }
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawOval(r, Paint()..color = GenieColors.teal.withValues(alpha: 0.26));
    canvas.drawOval(
      r.deflate(1.2),
      Paint()
        ..color = GenieColors.card
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    canvas.drawCircle(r.center, 5, Paint()..color = GenieColors.card);
  }

  @override
  bool shouldRepaint(_ReticlePainter old) => false;
}

/// The detected floor: a thin white outline with a dot grid.
class FloorGridPainter extends CustomPainter {
  const FloorGridPainter({required this.quad, this.skip});

  /// Corners: top-left, top-right, bottom-right, bottom-left.
  final List<Offset> quad;

  /// A grid point to leave empty (under the reticle).
  final (double, double)? skip;

  static const columns = [0.16, 0.33, 0.5, 0.67, 0.84];
  static const rows = [0.13, 0.35, 0.6, 0.86];

  Offset _at(double u, double v) {
    final top = Offset.lerp(quad[0], quad[1], u)!;
    final bottom = Offset.lerp(quad[3], quad[2], u)!;
    return Offset.lerp(top, bottom, v)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final outline =
        Paint()
          ..color = GenieColors.card.withValues(alpha: 0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(Path()..addPolygon(quad, true), outline);
    final dot = Paint()..color = GenieColors.card.withValues(alpha: 0.9);
    for (final v in rows) {
      for (final u in columns) {
        if (skip != null && skip!.$1 == u && skip!.$2 == v) continue;
        canvas.drawCircle(_at(u, v), 2.4, dot);
      }
    }
  }

  @override
  bool shouldRepaint(FloorGridPainter old) => old.quad != quad;
}

/// The turntable: a soft floor disc with a dashed teal edge, a solid trail and
/// a handle at [angle] (radians, 0 = right, clockwise).
class TurntablePainter extends CustomPainter {
  const TurntablePainter({required this.angle, this.trail = 0.55});

  final double angle;
  final double trail;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawOval(r, Paint()..color = GenieColors.turntable);
    final edge =
        Paint()
          ..color = GenieColors.teal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round;
    _dash(canvas, Path()..addOval(r.deflate(0.8)), edge, dash: 5, gap: 5);

    // Solid trail behind the handle.
    canvas.drawArc(
      r.deflate(0.8),
      angle + trail,
      -trail,
      false,
      Paint()
        ..color = GenieColors.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );

    final c = r.center;
    final handle = Offset(c.dx + math.cos(angle) * (r.width / 2 - 0.8), c.dy + math.sin(angle) * (r.height / 2 - 0.8));
    canvas.drawCircle(handle, 13, Paint()..color = GenieColors.teal.withValues(alpha: 0.18));
    canvas.drawCircle(handle, 7.5, Paint()..color = GenieColors.teal);
  }

  @override
  bool shouldRepaint(TurntablePainter old) => old.angle != angle;
}

/// A thin measurement line with a value chip in the middle ("80 cm").
class MeasureLine extends StatelessWidget {
  const MeasureLine({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelMedium!.copyWith(fontSize: 13, fontFeatures: const [FontFeature.tabularFigures()]);
    return Semantics(
      label: 'Width $label',
      excludeSemantics: true,
      child: Row(
        children: [
          const Expanded(child: Divider(color: GenieColors.measure, thickness: 1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(
              color: GenieColors.card,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Text(label, style: style),
          ),
          const Expanded(child: Divider(color: GenieColors.measure, thickness: 1)),
        ],
      ),
    );
  }
}

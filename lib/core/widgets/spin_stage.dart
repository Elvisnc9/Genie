import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../models/fabric.dart';
import '../theme/theme.dart';
import 'design_canvas.dart';
import 'labels.dart';
import 'scene_marks.dart';

/// Where the chair and turntable sit, in the 390 × 844 design space.
class StageLayout {
  const StageLayout({required this.chair, required this.turntable, this.measureY, this.spinChip});

  final Rect chair;
  final Rect turntable;
  final double? measureY;
  final Offset? spinChip;

  static const onboarding = StageLayout(
    chair: GenieArt.chairRect,
    turntable: GenieArt.turntable,
    measureY: GenieArt.measureY,
    spinChip: GenieArt.spinChip,
  );

  static const detail = StageLayout(chair: GenieArt.detailChair, turntable: GenieArt.detailTurntable);
}

/// The chair on its turntable, in design space. Shared with the detail
/// screen's stand-in viewer.
class SpinStage extends StatefulWidget {
  const SpinStage({
    super.key,
    required this.fabric,
    required this.spinning,
    this.layout = StageLayout.onboarding,
    this.measureLabel,
    this.showSpinChip = true,
    this.image,
    this.fallback = const Icon(GenieIcons.armchairs),
    this.heroTag,
  });

  final Fabric fabric;
  final StageLayout layout;
  final Widget fallback;

  /// Shared with the catalog tile for the Hero flight.
  final Object? heroTag;
  final bool spinning;
  final String? measureLabel;
  final bool showSpinChip;

  /// Overrides [fabric]'s render (e.g. pieces with one image).
  final String? image;

  @override
  State<SpinStage> createState() => _SpinStageState();
}

class _SpinStageState extends State<SpinStage> with SingleTickerProviderStateMixin {
  /// Turntable angle in radians; the handle starts near the front, slightly
  /// left (as in the mockup).
  late final AnimationController _angle = AnimationController.unbounded(vsync: this, value: math.pi * 0.55);

  static const _autoSpeed = 2 * math.pi / 14; // one turn every 14s
  static const _rock = 0.32; // max perspective turn of the flat render (rad)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAuto();
  }

  @override
  void didUpdateWidget(SpinStage old) {
    super.didUpdateWidget(old);
    if (old.spinning != widget.spinning) _syncAuto();
  }

  void _syncAuto() {
    if (widget.spinning && !context.reduceMotion) {
      _angle.animateWith(_ConstantSpin(_angle.value, _autoSpeed));
    } else if (!widget.spinning) {
      _angle.stop();
    }
  }

  void _onDragUpdate(DragUpdateDetails d, double radius) {
    _angle.stop();
    _angle.value += d.delta.dx / radius;
  }

  void _onDragEnd(DragEndDetails d, double radius) {
    final v = d.velocity.pixelsPerSecond.dx / radius;
    // Momentum: glide out with friction, then settle back into the slow spin.
    _angle.animateWith(FrictionSimulation(0.12, _angle.value, v)).whenCompleteOrCancel(() {
      if (mounted && widget.spinning && !_angle.isAnimating) _syncAuto();
    });
  }

  Widget _maybeHero(Widget child) =>
      widget.heroTag == null ? child : Hero(tag: widget.heroTag!, transitionOnUserGestures: true, child: child);

  @override
  void dispose() {
    _angle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = widget.layout.turntable;
    final image = widget.image ?? widget.fabric.image;
    return DesignCanvas(
      children: [
        Positioned.fromRect(
          rect: tt,
          child: AnimatedBuilder(
            animation: _angle,
            builder: (context, _) => CustomPaint(painter: TurntablePainter(angle: _angle.value)),
          ),
        ),
        Positioned.fromRect(
          rect: widget.layout.chair,
          child: AnimatedBuilder(
            animation: _angle,
            builder: (context, child) {
              // Facing the camera when the handle is at the front.
              final turn = math.sin(_angle.value - math.pi / 2) * _rock;
              return Transform(
                alignment: Alignment.center,
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.0011)
                      ..rotateY(turn),
                child: child,
              );
            },
            child: _maybeHero(
              AnimatedSwitcher(
                duration: GenieMotion.base,
                switchInCurve: GenieMotion.easeOut,
                switchOutCurve: GenieMotion.easeOut,
                layoutBuilder:
                    (current, previous) =>
                        Stack(fit: StackFit.expand, children: [...previous, if (current != null) current]),
                child:
                    image == null
                        ? IconTheme(
                          key: const ValueKey('none'),
                          data: const IconThemeData(size: 96, color: GenieColors.ink3),
                          child: Center(child: widget.fallback),
                        )
                        : Image.asset(image, key: ValueKey(image), fit: BoxFit.contain, gaplessPlayback: true),
              ),
            ),
          ),
        ),
        if (widget.measureLabel != null && widget.layout.measureY != null)
          Positioned(
            left: GenieArt.measureSpan.$1,
            width: GenieArt.measureSpan.$2 - GenieArt.measureSpan.$1,
            top: widget.layout.measureY! - 14,
            height: 28,
            child: MeasureLine(label: widget.measureLabel!),
          ),
        if (widget.showSpinChip && widget.layout.spinChip != null)
          Positioned(
            left: widget.layout.spinChip!.dx,
            top: widget.layout.spinChip!.dy,
            child: const ExcludeSemantics(child: InfoChip(label: '360°', icon: GenieIcons.spin)),
          ),
        // Drag anywhere over the stage to spin.
        Positioned(
          left: 0,
          right: 0,
          top: widget.layout.chair.top,
          bottom: GenieArt.canvas.height - tt.bottom - 10,
          child: Semantics(
            label: 'Turntable. Drag to spin.',
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (d) => _onDragUpdate(d, tt.width / 2),
              onHorizontalDragEnd: (d) => _onDragEnd(d, tt.width / 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Constant angular speed, forever (until stopped).
class _ConstantSpin extends Simulation {
  _ConstantSpin(this.start, this.speed);

  final double start;
  final double speed;

  @override
  double x(double time) => start + speed * time;

  @override
  double dx(double time) => speed;

  @override
  bool isDone(double time) => false;
}

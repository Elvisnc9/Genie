import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Motion tokens. Physical, quick and quiet.
///
/// Rules of thumb (Emil Kowalski's decision order):
/// - Anything the user touches runs on a spring, so it can be interrupted and
///   keeps its velocity.
/// - Fixed durations are only for colour/opacity changes and system-driven
///   transitions; they stay under 300ms.
/// - Never ease-in on UI. Never scale from 0.
abstract final class GenieMotion {
  // Curves
  /// Strong ease-out for entering/state changes.
  static const Curve easeOut = Cubic(0.23, 1, 0.32, 1);

  /// Strong ease-in-out for things moving across the screen.
  static const Curve easeInOut = Cubic(0.77, 0, 0.175, 1);

  /// iOS-like drawer/sheet curve, for system-driven sheet moves.
  static const Curve drawer = Cubic(0.32, 0.72, 0, 1);

  // Durations
  /// Selection colour, ring and fill crossfades.
  static const Duration fast = Duration(milliseconds: 160);

  /// Content crossfades (swatch recolour, small text swaps).
  static const Duration base = Duration(milliseconds: 220);

  /// Screen-level crossfades (splash to next screen).
  static const Duration slow = Duration(milliseconds: 280);

  /// Stagger between items that enter together.
  static const Duration stagger = Duration(milliseconds: 60);

  // Springs (Apple-style duration + bounce; bounce stays at 0.1–0.3 or 0)
  /// Press feedback scale. No bounce: it should feel firm.
  static final SpringDescription press = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 220),
  );

  /// Toggle knobs and segmented thumbs. A hint of life.
  static final SpringDescription toggle = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 320),
    bounce: 0.15,
  );

  /// Sheet and drag snapping. Critically damped so it lands, no wobble.
  static final SpringDescription snap = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 400),
  );

  /// Onboarding pop-ins (rare, first-run: the delight budget lives here).
  static final SpringDescription popIn = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 500),
    bounce: 0.2,
  );

  // Scales
  static const double pressScale = 0.97;
  static const double pressScaleLarge = 0.95; // big round buttons need more travel to read
  static const double popInFrom = 0.85;
}

extension GenieMotionContext on BuildContext {
  /// True when the user asked the OS to remove animations. Movement is then
  /// replaced by short fades or instant changes.
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;
}

/// A single double driven by springs. Retargeting mid-flight keeps the current
/// velocity, so every interaction is interruptible.
class SpringValue {
  SpringValue({required TickerProvider vsync, double value = 0})
    : _controller = AnimationController.unbounded(vsync: vsync, value: value);

  final AnimationController _controller;

  Animation<double> get animation => _controller;
  double get value => _controller.value;
  double get velocity => _controller.velocity;

  /// Springs to [target]. With [instant], jumps there (reduced motion, first
  /// build).
  void animateTo(double target, SpringDescription spring, {bool instant = false, double? velocity}) {
    if (instant) {
      _controller.value = target;
      return;
    }
    _controller.animateWith(SpringSimulation(spring, _controller.value, target, velocity ?? _controller.velocity));
  }

  /// Follows a finger directly (drag), cancelling any running spring.
  void set(double value) {
    _controller.stop();
    _controller.value = value;
  }

  void dispose() => _controller.dispose();
}

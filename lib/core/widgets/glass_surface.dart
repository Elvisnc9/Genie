import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Frosted white glass for controls floating over the camera or photos:
/// white 74%, blur 22, a 1px white edge at 75% and a soft neutral shadow.
///
/// Only use it where something busy sits underneath. On the plain warm
/// background, use a white card instead.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = GenieRadii.cardAll,
    this.padding = EdgeInsets.zero,
    this.circle = false,
    this.tint,
    this.shadow = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool circle;

  /// Optional fill override (e.g. a teal-soft tint when AI is on).
  final Color? tint;
  final bool shadow;

  static const double blur = 22;

  @override
  Widget build(BuildContext context) {
    final shape = circle ? BoxShape.circle : BoxShape.rectangle;
    final radius = circle ? null : borderRadius;

    Widget glass = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint ?? GenieColors.glassFill,
          shape: shape,
          borderRadius: radius,
          border: Border.all(color: GenieColors.glassBorder),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );

    glass = circle ? ClipOval(child: glass) : ClipRRect(borderRadius: borderRadius, child: glass);

    if (!shadow) return glass;
    return DecoratedBox(
      decoration: BoxDecoration(shape: shape, borderRadius: radius, boxShadow: GenieShadows.glass),
      child: glass,
    );
  }
}

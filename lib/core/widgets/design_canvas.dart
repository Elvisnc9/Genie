import 'package:flutter/widgets.dart';

import '../theme/art.dart';

/// A 390 × 844 stage scaled to cover the screen, like the illustrations.
/// Children are positioned in design coordinates, so marks drawn on top of a
/// picture stay on the same spot of the picture on any screen size.
class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.children, this.alignment = Alignment.center});

  final List<Widget> children;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: alignment,
        child: SizedBox.fromSize(size: GenieArt.canvas, child: Stack(clipBehavior: Clip.none, children: children)),
      ),
    );
  }
}

/// Positions [child] centred on [center] in design space.
class CenteredAt extends StatelessWidget {
  const CenteredAt({super.key, required this.center, required this.size, required this.child});

  final Offset center;
  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size.width / 2,
      top: center.dy - size.height / 2,
      width: size.width,
      height: size.height,
      child: child,
    );
  }
}

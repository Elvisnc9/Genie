import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// Shared measurements for the onboarding pages (from the mockups).
class OnboardingMetrics {
  const OnboardingMetrics({required this.safeTop, required this.bottomInset, required this.size});

  factory OnboardingMetrics.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return OnboardingMetrics(
      safeTop: mq.padding.top,
      // Bottom controls sit 40 above the bottom edge, and clear the nav bar.
      // (The mockups put Next 40 from the bottom edge on a 34pt home bar.)
      bottomInset: math.max(GenieSpace.bottomControls, mq.padding.bottom + 6),
      size: mq.size,
    );
  }

  final double safeTop;
  final double bottomInset;
  final Size size;

  /// The wordmark's centre sits 20 below the status bar; the headline starts
  /// 67 below it.
  static const double topBarOffset = -4;
  static const double headlineOffset = 67;

  /// Space reserved under the body copy for dots + Next, plus [gap].
  double bottomReserve([double gap = GenieSpace.xxxl]) => bottomInset + GenieSizes.buttonHeight + gap;
}

/// Parallax for a page's content, driven by the pager (not a timer): text
/// drifts a little faster than the page and fades as it leaves.
class Parallax extends StatelessWidget {
  const Parallax({
    super.key,
    required this.page,
    required this.index,
    required this.child,
    this.factor = 48,
    this.fade = true,
  });

  final ValueNotifier<double> page;
  final int index;
  final double factor;
  final bool fade;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    return ValueListenableBuilder<double>(
      valueListenable: page,
      child: child,
      builder: (context, p, child) {
        final offset = p - index;
        Widget c = Transform.translate(offset: Offset(-offset * factor, 0), child: child);
        if (fade) c = Opacity(opacity: (1 - offset.abs() * 1.1).clamp(0.0, 1.0), child: c);
        return c;
      },
    );
  }
}

/// The art behind a story page. Moves at 70% of the page's speed, so the
/// scene feels deeper than the text on it.
class ArtLayer extends StatelessWidget {
  const ArtLayer({super.key, required this.page, required this.index, required this.child});

  final ValueNotifier<double> page;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    final w = MediaQuery.sizeOf(context).width;
    return ValueListenableBuilder<double>(
      valueListenable: page,
      child: RepaintBoundary(child: child),
      builder:
          (context, p, child) =>
              Transform.translate(offset: Offset((p - index).clamp(-1.0, 1.0) * w * 0.3, 0), child: child),
    );
  }
}

/// Headline + body + whatever sits above the body, over the art.
class StoryCopy extends StatelessWidget {
  const StoryCopy({
    super.key,
    required this.page,
    required this.index,
    required this.headline,
    required this.body,
    this.aboveBody,
    this.bodyMaxWidth = 315,
    this.bodyGap = GenieSpace.xxxl + GenieSpace.xs,
    this.aboveBodyGap = GenieSpace.xl,
  });

  final ValueNotifier<double> page;
  final int index;
  final String headline;
  final String body;
  final Widget? aboveBody;
  final double bodyMaxWidth;

  /// Space between the body copy and the Next button (differs per page in
  /// the mockups).
  final double bodyGap;
  final double aboveBodyGap;

  @override
  Widget build(BuildContext context) {
    final m = OnboardingMetrics.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        GenieSpace.gutter,
        m.safeTop + OnboardingMetrics.headlineOffset,
        GenieSpace.gutter,
        m.bottomReserve(bodyGap),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Parallax(
            page: page,
            index: index,
            child: Semantics(header: true, child: Text(headline, style: text.displayLarge)),
          ),
          const Spacer(),
          if (aboveBody != null) ...[aboveBody!, SizedBox(height: aboveBodyGap)],
          Parallax(
            page: page,
            index: index,
            factor: 72,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bodyMaxWidth),
              child: Text(body, style: text.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft fades from the art into the warm background at the top and bottom,
/// so the copy always reads.
class ArtFades extends StatelessWidget {
  const ArtFades({super.key, this.bottomStart = 0.66, this.topHeight = 150});

  /// Fraction of the screen height where the bottom fade begins.
  final double bottomStart;
  final double topHeight;

  @override
  Widget build(BuildContext context) {
    const bg = GenieColors.bg;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: topHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bg.withValues(alpha: 0.55), bg.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [bottomStart, bottomStart + 0.1, 1],
                  colors: [bg.withValues(alpha: 0), bg, bg],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed illustration plate positioned like the mockup.
class ArtPlate extends StatelessWidget {
  const ArtPlate(this.asset, {super.key, this.overlays = const []});

  final String asset;
  final List<Widget> overlays;

  @override
  Widget build(BuildContext context) {
    return DesignCanvas(
      children: [
        Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill, gaplessPlayback: true, excludeFromSemantics: true)),
        ...overlays,
      ],
    );
  }
}

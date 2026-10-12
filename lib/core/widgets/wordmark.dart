import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

enum WordmarkTone { ink, white }

/// The thin "GENIE" wordmark. Ink on light screens, white over the camera.
///
/// Standard widths: [GenieSizes.wordmarkSplash], [GenieSizes.wordmarkHeader],
/// [GenieSizes.wordmarkFooter].
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.width = GenieSizes.wordmarkHeader, this.tone = WordmarkTone.ink});

  final double width;
  final WordmarkTone tone;

  static const ink = 'assets/brand/genie-logo-ink.png';
  static const white = 'assets/brand/genie-logo-white.png';
  static const double _aspect = 838 / 141;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Genie',
      image: true,
      child: Image.asset(
        tone == WordmarkTone.ink ? ink : white,
        width: width,
        height: width / _aspect,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}

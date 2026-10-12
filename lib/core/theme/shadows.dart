import 'package:flutter/painting.dart';

import 'colors.dart';

/// Neutral shadows only. Every surface declares its elevation once:
/// a shadow, never a shadow plus a border (glass is the exception, where the
/// 1px border is the material's edge highlight, not elevation).
abstract final class GenieShadows {
  /// Glass controls floating over the camera or photos.
  static const glass = [
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 10), blurRadius: 30), // black 12%
  ];

  /// White cards and grouped lists sitting on the warm background.
  static const card = [
    BoxShadow(color: Color(0x0D141518), offset: Offset(0, 6), blurRadius: 18), // ink 5%
    BoxShadow(color: Color(0x08141518), offset: Offset(0, 1), blurRadius: 2), // ink 3%
  ];

  /// Floating solid buttons (primary pill, circle buttons on light screens).
  static const raised = [
    BoxShadow(color: Color(0x1A141518), offset: Offset(0, 10), blurRadius: 26), // ink 10%
  ];

  /// Toggle and segmented thumbs.
  static const knob = [
    BoxShadow(color: Color(0x29000000), offset: Offset(0, 2), blurRadius: 6), // black 16%
  ];

  /// Neutral shadow at an arbitrary opacity, for one-off depth cues.
  static Color tint(double opacity) => GenieColors.shadow.withValues(alpha: opacity);
}

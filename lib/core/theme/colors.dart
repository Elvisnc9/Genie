import 'package:flutter/painting.dart';

/// Genie's palette, taken from the mockups. Light theme only.
///
/// Teal is the one accent: primary buttons, selection, toggles, reticle.
/// Everything else is warm neutrals.
abstract final class GenieColors {
  // Surfaces
  static const bg = Color(0xFFF6F5F1); // warm white app background
  static const card = Color(0xFFFFFFFF);
  static const splash = Color(0xFFFFFFFF); // the splash is pure white
  static const tileBg = Color(0xFFF3F1EC); // product image tiles, icon wells, stat cells
  static const track = Color(0xFFEFEDE8); // segmented control track

  // Ink
  static const ink = Color(0xFF141518); // primary text
  static const ink2 = Color(0xFF5E636B); // secondary text (5.5:1 on bg)
  static const ink3 = Color(0xFF6C7178); // labels, captions (4.5:1 on bg)
  static const line = Color(0xFFE9E7E1); // hairlines, card edges

  // Accent
  static const teal = Color(0xFF0F7B7A);
  static const tealDark = Color(0xFF0B6463); // pressed primary
  static const tealSoft = Color(0xFFE2F0EE); // tinted icon wells, chips

  // Status
  static const danger = Color(0xFFB4472A);
  static const dangerSoft = Color(0xFFFBEAE4);
  static const badgeBg = Color(0xFFFDE6D7); // "New" badge
  static const badgeFg = Color(0xFF7A3A17);

  // Controls
  static const toggleOff = Color(0xFFDDDBD5);
  static const dotInactive = Color(0xFFCFCCC5);
  static const onAccent = Color(0xFFFFFFFF);

  // Scene marks
  static const turntable = Color(0xFFECEAE4); // turntable floor disc
  static const measure = Color(0xFFBDB9B0); // measurement lines
  static const sparkle = Color(0xFFFFFFFF);

  // Glass: controls floating over the camera or photos.
  static const glassFill = Color(0xBDFFFFFF); // white 74%
  static const glassBorder = Color(0xBFFFFFFF); // white 75%

  // Neutral shadow/scrim base. Shadows are never coloured.
  static const shadow = Color(0xFF000000);
  static const scrim = Color(0xFF000000);
}

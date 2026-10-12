import 'package:flutter/material.dart';

import 'colors.dart';

/// Bricolage Grotesque for display, Manrope for everything else.
/// Both are bundled (assets/fonts), so the app never fetches fonts at runtime.
abstract final class GenieFonts {
  static const display = 'BricolageGrotesque';
  static const body = 'Manrope';
}

/// Display tracking: about −3.5% of the font size.
double _tight(double size) => -0.035 * size;

/// The type scale. Screens read these through `Theme.of(context).textTheme`;
/// nothing outside this file builds a TextStyle from scratch.
///
/// | Role            | Use                                   |
/// |-----------------|---------------------------------------|
/// | displayLarge    | Onboarding headlines (42)             |
/// | displayMedium   | Screen titles (36)                    |
/// | headlineMedium  | Product names (28)                    |
/// | headlineSmall   | Sheet titles (26)                     |
/// | titleMedium     | Row and card titles (16, 700)         |
/// | titleSmall      | Product card names (14, 700)          |
/// | bodyLarge       | Onboarding and detail body (15.5)     |
/// | bodyMedium      | Row subtitles (14)                    |
/// | bodySmall       | Captions, dimensions (12.5)           |
/// | labelLarge      | Buttons (16, 800)                     |
/// | labelMedium     | Chips, quiet actions, segments (14)   |
/// | labelSmall      | Eyebrows, uppercase (11.5, 800, +10%) |
abstract final class GenieType {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: GenieFonts.display,
      fontSize: 42,
      fontWeight: FontWeight.w700,
      height: 1.04,
      letterSpacing: -1.47, // _tight(42)
      color: GenieColors.ink,
    ),
    displayMedium: TextStyle(
      fontFamily: GenieFonts.display,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.08,
      letterSpacing: -1.26, // _tight(36)
      color: GenieColors.ink,
    ),
    displaySmall: TextStyle(
      fontFamily: GenieFonts.display,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -1.12,
      color: GenieColors.ink,
    ),
    headlineLarge: TextStyle(
      fontFamily: GenieFonts.display,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -1.05,
      color: GenieColors.ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: GenieFonts.display,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.98,
      color: GenieColors.ink,
    ),
    headlineSmall: TextStyle(
      fontFamily: GenieFonts.display,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.12,
      letterSpacing: -0.91,
      color: GenieColors.ink,
    ),
    titleLarge: TextStyle(
      fontFamily: GenieFonts.body,
      fontSize: 18,
      fontWeight: FontWeight.w800,
      height: 1.3,
      letterSpacing: -0.2,
      color: GenieColors.ink,
    ),
    titleMedium: TextStyle(
      fontFamily: GenieFonts.body,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.1,
      color: GenieColors.ink,
    ),
    titleSmall: TextStyle(
      fontFamily: GenieFonts.body,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.05,
      color: GenieColors.ink,
    ),
    bodyLarge: TextStyle(
      fontFamily: GenieFonts.body,
      fontSize: 15,
      letterSpacing: -0.15,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: GenieColors.ink2,
    ),
    bodyMedium: TextStyle(
      fontFamily: GenieFonts.body,
      fontSize: 13.5,
      letterSpacing: -0.05,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: GenieColors.ink2,
    ),
    bodySmall: TextStyle(
      fontFamily: GenieFonts.body,
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: GenieColors.ink3,
    ),
    labelLarge: TextStyle(
      fontFamily: GenieFonts.body,
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.2,
      color: GenieColors.ink,
    ),
    labelMedium: TextStyle(
      fontFamily: GenieFonts.body,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: GenieColors.ink,
    ),
    labelSmall: TextStyle(
      fontFamily: GenieFonts.body,
      fontSize: 11.5,
      fontWeight: FontWeight.w800,
      height: 1.2,
      letterSpacing: 1.15, // +10%
      color: GenieColors.ink3,
    ),
  );

  /// For one-off display sizes outside the scale (keeps the tracking rule).
  static TextStyle display(double size) =>
      textTheme.displayLarge!.copyWith(fontSize: size, letterSpacing: _tight(size));
}

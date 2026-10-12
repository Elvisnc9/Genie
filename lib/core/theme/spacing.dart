/// 8-pt rhythm, with 4 for tight internal gaps.
abstract final class GenieSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Side padding for screen content (headlines, body, buttons).
  static const double gutter = 24;

  /// Side inset for grouped cards (settings groups, permission rows).
  static const double groupInset = 20;

  /// Distance of bottom controls above the safe area.
  static const double bottomControls = 40;
}

/// Fixed component sizes from the mockups.
abstract final class GenieSizes {
  /// Smallest tappable area anywhere in the app.
  static const double minTouch = 48;

  static const double buttonHeight = 56;
  static const double iconButton = 48;
  static const double addButton = 78;
  static const double shutter = 52;
  static const double iconWell = 36;
  static const double categoryTile = 52;
  static const double swatch = 30;
  static const double swatchSmall = 24;

  static const double icon = 22;
  static const double iconSmall = 18;

  static const double toggleWidth = 50;
  static const double toggleHeight = 30;
  static const double toggleSmallWidth = 38;
  static const double toggleSmallHeight = 23;

  static const double wordmarkSplash = 190;
  static const double wordmarkHeader = 96;
  static const double wordmarkFooter = 72;

  static const double pageDot = 6;
  static const double pageDotActive = 24;
}

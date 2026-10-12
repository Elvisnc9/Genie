import 'package:flutter/painting.dart';

/// Illustration assets and where things sit inside them.
///
/// Coordinates are in the mockups' 390 × 844 design space (see design/).
/// `DesignCanvas` scales that space to the screen the same way the art is
/// scaled (cover), so overlays stay pinned to the right spot in the picture.
abstract final class GenieArt {
  static const canvas = Size(390, 844);

  // Placeholders cut from the mockups by tool/extract_art.py.
  static const onboardingRoom = 'assets/images/onboarding_room.jpg';
  static const onboardingAiRoom = 'assets/images/onboarding_ai_room.jpg';
  static const cameraPreview = 'assets/images/camera_preview.jpg';
  static const homeRoom = 'assets/images/home_room.jpg';
  static const luneTerracotta = 'assets/images/chair_lune_terracotta.png';
  static const lastDesignThumb = 'assets/images/collection_reading_corner.jpg';

  // Onboarding 1: the Lune armchair already in the room.
  static const roomPin = Offset(327, 461);
  static const roomSparkles = [(Offset(294.5, 404), 18.0), (Offset(361, 425), 10.0)];
  static const roomCard = Rect.fromLTWH(96, 521, 274, 78);

  // Onboarding 2: the turntable.
  static const chairRect = Rect.fromLTWH(63, 246.6, 270.2, 280.6);
  static const turntable = Rect.fromLTRB(30, 498, 360, 582);
  static const measureY = 274.0;
  static const measureSpan = (58.0, 332.0);
  static const spinChip = Offset(24, 420);

  // Detail: the same chair render, higher up the screen.
  static const detailChair = Rect.fromLTWH(81.4, 129.9, 222, 231);
  static const detailTurntable = Rect.fromLTRB(34, 356.7, 355.3, 433.3);
  static const detailSpinLabelY = 454.7;

  // Onboarding 3: colour reads and the suggestion.
  static const wallPin = Offset(205, 315);
  static const sofaPin = Offset(49, 445);
  static const wallSwatch = Color(0xFFC3C7B5);
  static const sofaSwatch = Color(0xFF8E9F86);
  static const suggestionBox = Rect.fromLTRB(301, 382, 370, 529);
  static const suggestionSparkle = Offset(335, 456);

  // Home: the floor Genie "found" in the placeholder room.
  static const floorQuad = [Offset(60.7, 480.7), Offset(330, 478.7), Offset(384, 690), Offset(5.3, 695.3)];
  static const reticleCenter = Offset(195.3, 590);
  static const reticleSize = Size(157, 52);

  /// Rough scale of the placeholder floor at the reticle, for true-size
  /// stand-ins until AR measures it: points per centimetre.
  static const ptPerCm = 0.95;
}

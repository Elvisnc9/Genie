import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Every icon the app uses, in one place. Lucide, round caps and joins.
/// Swap the stroke weight here (e.g. `LucideIcons.camera300`) and it changes
/// everywhere. The AI sparkle is not here: it is a filled shape, see
/// `SparkleIcon`.
abstract final class GenieIcons {
  // Navigation and actions
  static const IconData back = LucideIcons.chevronLeft;
  static const IconData chevron = LucideIcons.chevronRight;
  static const IconData next = LucideIcons.arrowRight;
  static const IconData close = LucideIcons.x;
  static const IconData check = LucideIcons.check;
  static const IconData add = LucideIcons.plus;
  static const IconData share = LucideIcons.share;
  static const IconData favourite = LucideIcons.heart;
  static const IconData search = LucideIcons.search;
  static const IconData settings = LucideIcons.slidersHorizontal;
  static const IconData view3d = LucideIcons.rotate3d;
  static const IconData place = LucideIcons.box;
  static const IconData spin = LucideIcons.rotate3d;

  // Permissions and settings
  static const IconData camera = LucideIcons.camera;
  static const IconData photos = LucideIcons.images;
  static const IconData floorGrid = LucideIcons.grid3x3;
  static const IconData units = LucideIcons.ruler;
  static const IconData haptics = LucideIcons.vibrate;
  static const IconData savedDesigns = LucideIcons.image;
  static const IconData clear = LucideIcons.trash2;
  static const IconData replayIntro = LucideIcons.circleQuestionMark;
  static const IconData privacy = LucideIcons.shield;
  static const IconData trueScale = LucideIcons.ruler;

  // Categories
  static const IconData armchairs = LucideIcons.armchair;
  static const IconData sofas = LucideIcons.sofa;
  // Chairs and Tables use drawn glyphs (Lucide has no dining chair or
  // pedestal table): see CategoryGlyph.
  static const IconData lighting = LucideIcons.lampFloor;
  static const IconData plants = LucideIcons.plantPot;
}

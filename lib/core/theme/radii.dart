import 'package:flutter/painting.dart';

abstract final class GenieRadii {
  static const double pill = 999;
  static const double card = 22;
  static const double group = 22;
  static const double tile = 16;
  static const double chip = 15;
  static const double stat = 14;
  static const double segment = 12;
  static const double iconWell = 11;
  static const double badge = 8;
  static const double sheet = 32;

  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius groupAll = BorderRadius.all(Radius.circular(group));
  static const BorderRadius tileAll = BorderRadius.all(Radius.circular(tile));
  static const BorderRadius chipAll = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius statAll = BorderRadius.all(Radius.circular(stat));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius iconWellAll = BorderRadius.all(Radius.circular(iconWell));
  static const BorderRadius sheetTop = BorderRadius.vertical(top: Radius.circular(sheet));
}

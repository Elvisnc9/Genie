/// Measurement units shown across the app. Catalog data is stored in cm.
enum Units {
  cm,
  inches;

  String get label => switch (this) {
    Units.cm => 'cm',
    Units.inches => 'in',
  };

  /// Formats a length given in centimetres, e.g. `80 cm` or `31.5 in`.
  String format(num centimetres) => '${_number(centimetres)} $label';

  /// Formats a footprint, e.g. `80 × 74 cm`.
  String formatPair(num a, num b) => '${_number(a)} × ${_number(b)} $label';

  String _number(num centimetres) {
    if (this == Units.cm) return '${centimetres.round()}';
    final rounded = (centimetres / 2.54 * 2).round() / 2; // nearest half inch
    return rounded == rounded.roundToDouble() ? rounded.toStringAsFixed(0) : rounded.toStringAsFixed(1);
  }
}

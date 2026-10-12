import 'package:flutter_test/flutter_test.dart';
import 'package:genie/core/models/units.dart';

void main() {
  test('cm formats whole centimetres', () {
    expect(Units.cm.format(80), '80 cm');
    expect(Units.cm.formatPair(80, 74), '80 × 74 cm');
  });

  test('inches round to the nearest half inch', () {
    expect(Units.inches.format(80), '31.5 in');
    expect(Units.inches.format(254), '100 in');
    expect(Units.inches.formatPair(48, 46), '19 × 18 in');
  });
}

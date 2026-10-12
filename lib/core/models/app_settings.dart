import 'units.dart';

class AppSettings {
  const AppSettings({this.aiSuggestions = true, this.floorGrid = true, this.units = Units.cm, this.haptics = false});

  /// Defaults match the settings mockup.
  static const defaults = AppSettings();

  final bool aiSuggestions;
  final bool floorGrid;
  final Units units;
  final bool haptics;

  AppSettings copyWith({bool? aiSuggestions, bool? floorGrid, Units? units, bool? haptics}) => AppSettings(
    aiSuggestions: aiSuggestions ?? this.aiSuggestions,
    floorGrid: floorGrid ?? this.floorGrid,
    units: units ?? this.units,
    haptics: haptics ?? this.haptics,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.aiSuggestions == aiSuggestions &&
      other.floorGrid == floorGrid &&
      other.units == units &&
      other.haptics == haptics;

  @override
  int get hashCode => Object.hash(aiSuggestions, floorGrid, units, haptics);
}

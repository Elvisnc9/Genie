import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/units.dart';
import 'preferences.dart';

/// User settings, persisted and applied live: every screen watches this.
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    const d = AppSettings.defaults;
    return AppSettings(
      aiSuggestions: prefs.getBool(PrefKeys.aiSuggestions) ?? d.aiSuggestions,
      floorGrid: prefs.getBool(PrefKeys.floorGrid) ?? d.floorGrid,
      units: Units.values.asNameMap()[prefs.getString(PrefKeys.units)] ?? d.units,
      haptics: prefs.getBool(PrefKeys.haptics) ?? d.haptics,
    );
  }

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  void setAiSuggestions(bool v) {
    state = state.copyWith(aiSuggestions: v);
    unawaited(_prefs.setBool(PrefKeys.aiSuggestions, v));
  }

  void setFloorGrid(bool v) {
    state = state.copyWith(floorGrid: v);
    unawaited(_prefs.setBool(PrefKeys.floorGrid, v));
  }

  void setUnits(Units v) {
    state = state.copyWith(units: v);
    unawaited(_prefs.setString(PrefKeys.units, v.name));
  }

  void setHaptics(bool v) {
    state = state.copyWith(haptics: v);
    unawaited(_prefs.setBool(PrefKeys.haptics, v));
  }
}

/// Convenience selectors.
final unitsProvider = Provider<Units>((ref) => ref.watch(settingsProvider.select((s) => s.units)));

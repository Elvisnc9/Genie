import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's SharedPreferences. Loaded once in main() and injected with an
/// override, so every reader is synchronous.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

abstract final class PrefKeys {
  static const onboardingDone = 'onboarding_done';
  static const aiSuggestions = 'settings_ai_suggestions';
  static const floorGrid = 'settings_floor_grid';
  static const units = 'settings_units';
  static const haptics = 'settings_haptics';
  static const savedDesigns = 'saved_designs';
}

/// Whether the intro has been completed (or skipped). Settings › Replay the
/// intro clears it.
final onboardingDoneProvider = NotifierProvider<OnboardingDone, bool>(OnboardingDone.new);

class OnboardingDone extends Notifier<bool> {
  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(PrefKeys.onboardingDone) ?? false;

  Future<void> set(bool done) async {
    state = done;
    await ref.read(sharedPreferencesProvider).setBool(PrefKeys.onboardingDone, done);
  }
}

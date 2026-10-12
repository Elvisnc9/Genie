import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genie/core/data/preferences.dart';
import 'package:genie/core/data/settings_controller.dart';
import 'package:genie/core/feedback/haptics.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('haptics follow the persisted setting, off by default', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(container.dispose);

    expect(container.read(hapticsEnabledProvider), isFalse);
    container.read(settingsProvider.notifier).setHaptics(true);
    expect(container.read(hapticsEnabledProvider), isTrue);
    expect(prefs.getBool(PrefKeys.haptics), isTrue);
  });
}

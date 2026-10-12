import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_controller.dart';

/// Whether haptic feedback is on (Settings › Haptics, off by default).
final hapticsEnabledProvider = Provider<bool>((ref) => ref.watch(settingsProvider.select((s) => s.haptics)));

enum HapticKind { none, selection, light, medium }

extension HapticsRef on WidgetRef {
  /// Plays [kind] if the user has haptics on.
  void haptic(HapticKind kind) {
    if (kind == HapticKind.none || !read(hapticsEnabledProvider)) return;
    switch (kind) {
      case HapticKind.selection:
        HapticFeedback.selectionClick();
      case HapticKind.light:
        HapticFeedback.lightImpact();
      case HapticKind.medium:
        HapticFeedback.mediumImpact();
      case HapticKind.none:
        break;
    }
  }
}

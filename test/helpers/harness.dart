import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genie/core/feedback/haptics.dart';
import 'package:genie/core/theme/theme.dart';

/// Wraps [child] in the real theme and a ProviderScope.
Widget harness(Widget child, {bool reduceMotion = false}) {
  return ProviderScope(
    overrides: [hapticsEnabledProvider.overrideWithValue(false)],
    child: MaterialApp(
      theme: GenieTheme.light,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

/// Loads the bundled fonts so goldens render real type instead of boxes.
Future<void> loadGenieFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('assets/fonts/$f').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load(GenieFonts.display, [
    'BricolageGrotesque-SemiBold.ttf',
    'BricolageGrotesque-Bold.ttf',
    'BricolageGrotesque-ExtraBold.ttf',
  ]);
  await load(GenieFonts.body, [
    'Manrope-Medium.ttf',
    'Manrope-SemiBold.ttf',
    'Manrope-Bold.ttf',
    'Manrope-ExtraBold.ttf',
  ]);
  // Lucide ships inside its package; load it so icons show in goldens.
  final lucide = FontLoader('packages/lucide_icons_flutter/Lucide');
  lucide.addFont(rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'));
  await lucide.load();
}

@Tags(['screens'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genie/app/app.dart';
import 'package:genie/core/data/camera_permission.dart';
import 'package:genie/core/data/catalog_repository.dart';
import 'package:genie/core/data/preferences.dart';
import 'package:genie/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/onboarding_flow_test.dart' show FakeCamera;
import '../helpers/harness.dart';

/// Full-screen captures at the mockups' 390 × 844, for side-by-side review
/// against design/. Regenerate: flutter test --update-goldens test/screens
const _assets = [
  GenieArt.onboardingRoom,
  GenieArt.onboardingAiRoom,
  GenieArt.cameraPreview,
  GenieArt.homeRoom,
  GenieArt.luneTerracotta,
  GenieArt.lastDesignThumb,
  'assets/images/chair_lune_oat.png',
  'assets/images/chair_lune_sage.png',
  'assets/images/chair_lune_navy.png',
  'assets/images/piece_arc_lamp.png',
  'assets/images/piece_nord.png',
  'assets/images/collection_living_room.jpg',
  'assets/brand/genie-logo-ink.png',
  'assets/brand/genie-logo-white.png',
];

final _catalog = CatalogRepository.parse(File('assets/data/catalog.json').readAsStringSync());

void main() {
  setUpAll(loadGenieFonts);

  Future<void> boot(WidgetTester tester, {required bool onboarded}) async {
    tester.view.physicalSize = const Size(390, 844) * 2;
    tester.view.devicePixelRatio = 2;
    tester.view.padding = const FakeViewPadding(top: 47 * 2, bottom: 34 * 2);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({if (onboarded) PrefKeys.onboardingDone: true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          cameraPermissionServiceProvider.overrideWithValue(FakeCamera(CameraAccess.granted)),
          catalogProvider.overrideWith((ref) => _catalog),
        ],
        child: const GenieApp(),
      ),
    );
    final el = tester.element(find.byType(GenieApp));
    await tester.runAsync(() async {
      for (final a in _assets) {
        await precacheImage(AssetImage(a), el);
      }
    });
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> shoot(WidgetTester tester, String name) async {
    debugDisableShadows = false;
    try {
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump(const Duration(milliseconds: 900));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
    } finally {
      debugDisableShadows = true;
    }
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
  }

  testWidgets('splash', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          cameraPermissionServiceProvider.overrideWithValue(FakeCamera(CameraAccess.granted)),
        ],
        child: const GenieApp(),
      ),
    );
    final el = tester.element(find.byType(GenieApp));
    await tester.runAsync(() => precacheImage(const AssetImage('assets/brand/genie-logo-ink.png'), el));
    await tester.pump(const Duration(milliseconds: 600));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/01-splash.png'));
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('onboarding', (tester) async {
    await boot(tester, onboarded: false);
    await shoot(tester, '02-onboarding-1');
    await next(tester);
    await shoot(tester, '03-onboarding-2');
    await next(tester);
    await shoot(tester, '04-onboarding-3');
    await next(tester);
    await shoot(tester, '05-onboarding-4');
  });

  testWidgets('home, sheet, detail, settings', (tester) async {
    await boot(tester, onboarded: true);
    await tester.pump(const Duration(seconds: 2)); // floor found
    await shoot(tester, '06-home');

    await tester.tap(find.bySemanticsLabel('Add a piece'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await shoot(tester, '07-sheet');

    await tester.tap(find.text('Lune armchair').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await shoot(tester, '08-detail');

    await tester.tap(find.text('Place in my room'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await shoot(tester, '06b-home-placed');

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await shoot(tester, '09-settings');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genie/app/app.dart';
import 'package:genie/core/data/camera_permission.dart';
import 'package:genie/core/data/preferences.dart';
import 'package:genie/features/home/home_screen.dart';
import 'package:genie/features/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeCamera extends CameraPermissionService {
  FakeCamera(this.answer);

  CameraAccess answer;
  int requests = 0;

  @override
  Future<CameraAccess> status() async => CameraAccess.unknown;

  @override
  Future<CameraAccess> request() async {
    requests++;
    return answer;
  }

  @override
  Future<bool> openSettings() async => true;
}

Future<SharedPreferences> freshPrefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Future<void> pumpApp(WidgetTester tester, SharedPreferences prefs, FakeCamera camera) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        cameraPermissionServiceProvider.overrideWithValue(camera),
      ],
      child: const GenieApp(),
    ),
  );
  // Splash holds ~700ms, then crossfades.
  await tester.pump(const Duration(milliseconds: 1200));
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

void main() {
  testWidgets('first launch: splash → onboarding; Skip → camera page; Allow → Home', (tester) async {
    final prefs = await freshPrefs();
    final camera = FakeCamera(CameraAccess.granted);
    await pumpApp(tester, prefs, camera);

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text("Design the room\nyou're standing in."), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text("One tap,\nand you're in."), findsOneWidget);

    await tester.ensureVisible(find.text('Allow camera'));
    await tester.pump(); // let the scroll land before tapping
    await tester.tap(find.text('Allow camera'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(camera.requests, 1);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(prefs.getBool(PrefKeys.onboardingDone), isTrue);
    await tester.pump(const Duration(seconds: 3)); // let Home's timers finish
  });

  testWidgets('Next walks the story pages in order', (tester) async {
    final prefs = await freshPrefs();
    await pumpApp(tester, prefs, FakeCamera(CameraAccess.granted));

    // Page 2's turntable spins forever, so pump fixed frames, not settle.
    for (final headline in ['Every piece,\nfrom every side.', 'Let Genie style\nit with you.']) {
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text(headline), findsOneWidget);
    }
  });

  testWidgets('denied camera stays on the page with a calm explainer', (tester) async {
    final prefs = await freshPrefs();
    final camera = FakeCamera(CameraAccess.denied);
    await pumpApp(tester, prefs, camera);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Allow camera'));
    await tester.pump(); // let the scroll land before tapping
    await tester.tap(find.text('Allow camera'));
    await tester.pumpAndSettle();

    expect(camera.requests, 1);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.textContaining("can't see your floor without the camera"), findsOneWidget);
    expect(prefs.getBool(PrefKeys.onboardingDone), isNot(true));
  });

  testWidgets('blocked camera offers the system settings instead', (tester) async {
    final prefs = await freshPrefs();
    await pumpApp(tester, prefs, FakeCamera(CameraAccess.blocked));

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Allow camera'));
    await tester.pump(); // let the scroll land before tapping
    await tester.tap(find.text('Allow camera'));
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('returning users skip onboarding', (tester) async {
    final prefs = await freshPrefs({PrefKeys.onboardingDone: true});
    await pumpApp(tester, prefs, FakeCamera(CameraAccess.granted));
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}

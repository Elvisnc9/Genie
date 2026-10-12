import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/theme.dart';
import '../features/detail/detail_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/privacy_screen.dart';
import '../features/settings/saved_designs_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';

abstract final class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const settings = '/settings';
  static const savedDesigns = '/settings/saved';
  static const privacy = '/settings/privacy';
  static const gallery = '/gallery';

  static String piece(String id) => '/piece/$id';
}

/// A plain crossfade, for moving between the app's big stages
/// (splash → onboarding → home).
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  transitionDuration: GenieMotion.slow,
  reverseTransitionDuration: GenieMotion.base,
  transitionsBuilder:
      (context, animation, _, child) =>
          FadeTransition(opacity: CurvedAnimation(parent: animation, curve: GenieMotion.easeOut), child: child),
);

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(path: Routes.splash, pageBuilder: (context, state) => _fade(state, const SplashScreen())),
      GoRoute(path: Routes.onboarding, pageBuilder: (context, state) => _fade(state, const OnboardingScreen())),
      GoRoute(path: Routes.home, pageBuilder: (context, state) => _fade(state, const HomeScreen())),
      GoRoute(
        path: '/piece/:id',
        builder:
            (context, state) =>
                DetailScreen(itemId: state.pathParameters['id']!, fabricId: state.uri.queryParameters['fabric']),
      ),
      GoRoute(path: Routes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(path: Routes.savedDesigns, builder: (context, state) => const SavedDesignsScreen()),
      GoRoute(path: Routes.privacy, builder: (context, state) => const PrivacyScreen()),
      GoRoute(path: Routes.gallery, builder: (context, state) => const GalleryScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

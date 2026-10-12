import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data/catalog_repository.dart';
import '../../core/data/preferences.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// Pure white, the wordmark settling in, then a crossfade onward. Stays up
/// only while the first screen's images warm up, and never much past 700ms.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  late final Animation<double> _curve = CurvedAnimation(parent: _in, curve: GenieMotion.easeOut);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (context.reduceMotion) {
      _in.value = 1;
    } else {
      _in.forward();
    }
    unawaited(_continue());
  }

  Future<void> _continue() async {
    final done = ref.read(onboardingDoneProvider);
    final warmUp = <Future<void>>[
      if (!done) ...[
        precacheImage(const AssetImage(GenieArt.onboardingRoom), context),
        precacheImage(const AssetImage(GenieArt.luneTerracotta), context),
      ] else
        precacheImage(const AssetImage(GenieArt.homeRoom), context),
      ref.read(catalogProvider.future).then((_) {}),
    ];
    await Future.wait([
      Future.wait(warmUp).timeout(const Duration(milliseconds: 900), onTimeout: () => const []),
      Future<void>.delayed(const Duration(milliseconds: 700)),
    ]);
    if (!mounted) return;
    context.go(done ? Routes.home : Routes.onboarding);
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagline = Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: GenieColors.ink3);
    return Scaffold(
      backgroundColor: GenieColors.splash,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _curve,
              child: ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.0).animate(_curve),
                child: const Wordmark(width: GenieSizes.wordmarkSplash),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + GenieSpace.xxxl + GenieSpace.xs,
            child: FadeTransition(
              opacity: _curve,
              child: Text("Design the room you're in", textAlign: TextAlign.center, style: tagline),
            ),
          ),
        ],
      ),
    );
  }
}

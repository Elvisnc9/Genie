import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data/preferences.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_layout.dart';
import 'permission_page.dart';
import 'story_pages.dart';

/// Four pages: three stories and the camera permission. The wordmark, Skip,
/// dots and Next stay fixed while the pages slide beneath them.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const pageCount = 4;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  final _page = ValueNotifier<double>(0);

  /// Pages whose entrance has played; it plays once, not on every swipe back.
  final Set<int> _seen = {0};
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _page.value = _controller.page ?? 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _page.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (context.reduceMotion) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(index, duration: const Duration(milliseconds: 420), curve: GenieMotion.drawer);
    }
  }

  Future<void> _finish() async {
    await ref.read(onboardingDoneProvider.notifier).set(true);
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final metrics = OnboardingMetrics.of(context);
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged:
                (i) => setState(() {
                  _current = i;
                  _seen.add(i);
                }),
            children: [
              RoomStoryPage(index: 0, page: _page, active: _seen.contains(0)),
              TurntableStoryPage(index: 1, page: _page, active: _seen.contains(1), visible: _current == 1),
              AiStoryPage(index: 2, page: _page, active: _seen.contains(2)),
              PermissionPage(index: 3, page: _page, onDone: _finish),
            ],
          ),
          // Fixed top bar: wordmark, and Skip until the last page.
          Positioned(
            left: GenieSpace.gutter,
            right: GenieSpace.gutter - GenieSpace.sm,
            top: metrics.safeTop + OnboardingMetrics.topBarOffset,
            height: GenieSizes.minTouch,
            child: Row(
              children: [
                const Wordmark(),
                const Spacer(),
                _FadeOnLastPage(
                  page: _page,
                  child: QuietButton(label: 'Skip', onPressed: () => _goTo(OnboardingScreen.pageCount - 1)),
                ),
              ],
            ),
          ),
          // Fixed bottom bar: dots and Next, until the last page.
          Positioned(
            left: GenieSpace.gutter,
            right: GenieSpace.gutter,
            bottom: metrics.bottomInset,
            child: _FadeOnLastPage(
              page: _page,
              child: Row(
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: _page,
                    builder: (context, p, _) => PageDots(count: OnboardingScreen.pageCount, page: p),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Next',
                    trailingIcon: GenieIcons.next,
                    onPressed: () => _goTo(math.min(_current + 1, OnboardingScreen.pageCount - 1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades its child out as the pager reaches the last page, and stops it from
/// taking taps once hidden.
class _FadeOnLastPage extends StatelessWidget {
  const _FadeOnLastPage({required this.page, required this.child});

  final ValueNotifier<double> page;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: page,
      child: child,
      builder: (context, p, child) {
        final t = ((OnboardingScreen.pageCount - 1) - p).clamp(0.0, 1.0);
        return IgnorePointer(
          ignoring: t < 0.5,
          child: ExcludeSemantics(excluding: t < 0.5, child: Opacity(opacity: t, child: child)),
        );
      },
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/router.dart';
import '../../core/data/preferences.dart';
import '../../core/data/room_controller.dart';
import '../../core/data/settings_controller.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// Simple and calm. Everything persists and applies the moment it changes.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final count = ref.read(savedDesignsProvider).length;
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No saved designs to clear.')));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear saved designs?'),
            content: Text(
              count == 1
                  ? 'Your saved design will be removed from this phone.'
                  : 'All $count saved designs will be removed from this phone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: GenieColors.ink2),
                child: const Text('Keep them'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: GenieColors.danger),
                child: const Text('Clear'),
              ),
            ],
          ),
    );
    if (ok != true || !context.mounted) return;
    ref.read(savedDesignsProvider.notifier).clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved designs cleared.')));
  }

  Future<void> _replayIntro(BuildContext context, WidgetRef ref) async {
    await ref.read(onboardingDoneProvider.notifier).set(false);
    if (context.mounted) context.go(Routes.onboarding);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final text = Theme.of(context).textTheme;
    final version = ref.watch(appVersionProvider).value;
    final mq = MediaQuery.of(context);

    return Scaffold(
      // The footer sits at the bottom when there's room, and scrolls with the
      // list when there isn't.
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                GenieSpace.groupInset,
                mq.padding.top + GenieSpace.xs,
                GenieSpace.groupInset,
                math.max(GenieSpace.md, mq.padding.bottom - 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconCircleButton(
                      icon: GenieIcons.back,
                      semanticLabel: 'Back',
                      size: 46,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: GenieSpace.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: GenieSpace.xxs),
                    child: Semantics(header: true, child: Text('Settings', style: text.displayMedium)),
                  ),
                  const SizedBox(height: GenieSpace.md),
                  SettingsGroup(
                    title: 'Designing',
                    children: [
                      SettingsRow(
                        title: 'AI suggestions',
                        subtitle: 'Show the AI switch on camera',
                        leading: const SparkleWellGlyph(),
                        tone: SettingsTone.accent,
                        toggled: s.aiSuggestions,
                        trailing: GenieToggle(value: s.aiSuggestions, onChanged: null),
                        onTap: () => c.setAiSuggestions(!s.aiSuggestions),
                      ),
                      SettingsRow(
                        title: 'Floor grid',
                        subtitle: 'Dots where Genie sees the floor',
                        icon: GenieIcons.floorGrid,
                        toggled: s.floorGrid,
                        trailing: GenieToggle(value: s.floorGrid, onChanged: null),
                        onTap: () => c.setFloorGrid(!s.floorGrid),
                      ),
                      SettingsRow(
                        title: 'Units',
                        icon: GenieIcons.units,
                        trailing: SegmentedUnits(value: s.units, onChanged: c.setUnits),
                      ),
                      SettingsRow(
                        title: 'Haptics',
                        subtitle: 'A soft tap when a piece lands',
                        icon: GenieIcons.haptics,
                        toggled: s.haptics,
                        trailing: GenieToggle(value: s.haptics, onChanged: null),
                        onTap: () => c.setHaptics(!s.haptics),
                      ),
                    ],
                  ),
                  const SizedBox(height: GenieSpace.lg),
                  SettingsGroup(
                    title: 'Your designs',
                    children: [
                      SettingsRow(
                        title: 'Saved designs',
                        icon: GenieIcons.savedDesigns,
                        chevron: true,
                        onTap: () => context.push(Routes.savedDesigns),
                      ),
                      SettingsRow(
                        title: 'Clear saved designs',
                        icon: GenieIcons.clear,
                        tone: SettingsTone.danger,
                        onTap: () => _confirmClear(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: GenieSpace.lg),
                  SettingsGroup(
                    title: 'About',
                    children: [
                      SettingsRow(
                        title: 'Replay the intro',
                        icon: GenieIcons.replayIntro,
                        chevron: true,
                        onTap: () => _replayIntro(context, ref),
                      ),
                      SettingsRow(
                        title: 'Privacy',
                        icon: GenieIcons.privacy,
                        chevron: true,
                        onTap: () => context.push(Routes.privacy),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: GenieSpace.xxl),
                  const Center(child: Wordmark(width: GenieSizes.wordmarkFooter)),
                  const SizedBox(height: GenieSpace.xxs),
                  Center(
                    child: Text(
                      version == null ? ' ' : 'Version $version',
                      style: text.bodyMedium!.copyWith(color: GenieColors.ink3),
                    ),
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

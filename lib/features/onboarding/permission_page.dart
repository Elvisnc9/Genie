import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/camera_permission.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_layout.dart';

/// "One tap, and you're in." Asks for the camera only. Granted → Home.
/// Denied → stays, with a calm line. Blocked → a way to the system settings.
/// "Not now" goes on to Home, which can ask again later.
class PermissionPage extends ConsumerStatefulWidget {
  const PermissionPage({super.key, required this.index, required this.page, required this.onDone});

  final int index;
  final ValueNotifier<double> page;
  final Future<void> Function() onDone;

  @override
  ConsumerState<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends ConsumerState<PermissionPage> with WidgetsBindingObserver {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Coming back from system settings: if the camera is now allowed, go on.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final wasBlocked = ref.read(cameraAccessProvider) == CameraAccess.blocked;
    ref.read(cameraAccessProvider.notifier).refresh().then((access) {
      if (mounted && wasBlocked && access == CameraAccess.granted) widget.onDone();
    });
  }

  Future<void> _allow() async {
    final controller = ref.read(cameraAccessProvider.notifier);
    if (ref.read(cameraAccessProvider) == CameraAccess.blocked) {
      await controller.openSettings();
      return;
    }
    setState(() => _busy = true);
    final access = await controller.request();
    if (!mounted) return;
    setState(() => _busy = false);
    if (access == CameraAccess.granted) await widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final m = OnboardingMetrics.of(context);
    final text = Theme.of(context).textTheme;
    final access = ref.watch(cameraAccessProvider);
    final blocked = access == CameraAccess.blocked;

    final note = switch (access) {
      CameraAccess.denied =>
        "No problem. Genie can't see your floor without the camera, so tap Allow camera when you're ready.",
      CameraAccess.blocked => 'Camera access is off for Genie. Turn it on in Settings, then come back.',
      _ => null,
    };

    // Fills the screen; if the copy can't fit (tiny screen, huge text), the
    // page scrolls instead of clipping the buttons.
    return ColoredBox(
      color: GenieColors.bg,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                GenieSpace.gutter,
                m.safeTop + OnboardingMetrics.topBarOffset + GenieSizes.minTouch + GenieSpace.md,
                GenieSpace.gutter,
                m.bottomInset - 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The preview shrinks first on short screens.
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: Parallax(
                        page: widget.page,
                        index: widget.index,
                        fade: false,
                        factor: 24,
                        child: const _ViewfinderCard(),
                      ),
                    ),
                  ),
                  const SizedBox(height: GenieSpace.xxl),
                  Parallax(
                    page: widget.page,
                    index: widget.index,
                    child: Semantics(header: true, child: Text("One tap,\nand you're in.", style: text.displayLarge)),
                  ),
                  const SizedBox(height: GenieSpace.sm + 2),
                  Parallax(
                    page: widget.page,
                    index: widget.index,
                    factor: 72,
                    child: Text(
                      "No account. No sign-up. Genie only needs your camera to see the room you're designing.",
                      style: text.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: GenieSpace.xl + 2),
                  const _PermissionRows(),
                  const SizedBox(height: GenieSpace.xl),
                  AnimatedSize(
                    duration: GenieMotion.base,
                    curve: GenieMotion.easeOut,
                    alignment: Alignment.topCenter,
                    child:
                        note == null
                            ? const SizedBox(width: double.infinity)
                            : Padding(
                              padding: const EdgeInsets.only(bottom: GenieSpace.md),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(note, style: text.bodyMedium, textAlign: TextAlign.center),
                              ),
                            ),
                  ),
                  PrimaryButton(
                    label: blocked ? 'Open settings' : 'Allow camera',
                    expand: true,
                    busy: _busy,
                    onPressed: _allow,
                  ),
                  const SizedBox(height: GenieSpace.xs),
                  Center(child: QuietButton(label: 'Not now', onPressed: widget.onDone)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderCard extends StatelessWidget {
  const _ViewfinderCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Camera view with the floor found',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(26)),
          boxShadow: GenieShadows.raised,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(26)),
          // A known aspect ratio gives the card a real height even before
          // the image decodes, so the page can tell when it needs to scroll.
          child: AspectRatio(
            aspectRatio: 342 / 250,
            child: Image.asset(
              GenieArt.cameraPreview,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionRows extends StatelessWidget {
  const _PermissionRows();

  @override
  Widget build(BuildContext context) {
    final label = Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 13.5);
    return SettingsGroup(
      children: [
        SettingsRow(
          title: 'Camera',
          subtitle: 'Maps your floor and walls',
          icon: GenieIcons.camera,
          tone: SettingsTone.accent,
          trailing: Text('Required', style: label.copyWith(color: GenieColors.teal, fontWeight: FontWeight.w800)),
        ),
        SettingsRow(
          title: 'Photos',
          subtitle: 'Saves your shots, asked later',
          icon: GenieIcons.photos,
          trailing: Text('Optional', style: label.copyWith(color: GenieColors.ink2, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

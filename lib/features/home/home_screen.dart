import 'dart:async';
import 'dart:math' as math;

import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/ar/genie_ar.dart';
import '../../core/data/camera_permission.dart';
import '../../core/data/catalog_repository.dart';
import '../../core/data/room_controller.dart';
import '../../core/data/settings_controller.dart';
import '../../core/feedback/haptics.dart';
import '../../core/models/furniture_item.dart';
import '../../core/models/placed_piece.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../catalog/catalog_sheet.dart';

/// The camera. Until AR is wired up (Phase 6) the feed is a still of a room,
/// with the AR layer (floor, reticle, placed pieces) drawn on top of it.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum _Scan { searching, found }

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  _Scan _scan = _Scan.searching;
  bool _ai = false;
  Timer? _scanTimer;
  Timer? _toastTimer;
  String? _toast;

  /// The live AR session (null on the placeholder camera).
  GenieAr? _ar;

  /// A piece waiting for the reticle to find floor before it can land.
  PlacedPiece? _pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Simulated plane detection: the floor is "found" after a short look.
    _scanTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted || _ar != null) return;
      setState(() => _scan = _Scan.found);
      ref.haptic(HapticKind.light);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanTimer?.cancel();
    _toastTimer?.cancel();
    _ar?.removeListener(_onArChanged);
    _ar?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.read(cameraAccessProvider.notifier).refresh();
  }

  void _say(String message) {
    _toastTimer?.cancel();
    setState(() => _toast = message);
    _toastTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  Future<void> _openCatalog() async {
    final placed = await showCatalogSheet(context);
    if (placed != null && mounted) _onPlaced(placed);
  }

  GenieAr _arSession() {
    final ar = _ar ??= GenieAr();
    ar.removeListener(_onArChanged);
    ar.addListener(_onArChanged);
    return ar;
  }

  /// Floor found or lost under the reticle (live camera).
  void _onArChanged() {
    final ar = _ar;
    if (ar == null || !mounted) return;
    final next = ar.floorFound ? _Scan.found : _Scan.searching;
    if (next != _scan) {
      setState(() => _scan = next);
      if (next == _Scan.found) ref.haptic(HapticKind.selection);
    }
    final pending = _pending;
    if (pending != null && ar.floorFound) {
      _pending = null;
      _onPlaced(pending);
    }
  }

  Future<void> _onPlaced(PlacedPiece piece) async {
    final item = ref.read(catalogProvider).value?.item(piece.itemId);
    if (item == null) return;
    final ar = _ar;
    if (ar != null && ar.ready) {
      switch (await ar.place(item, uid: piece.uid)) {
        case PlaceOutcome.placed:
          break;
        case PlaceOutcome.noFloor:
          _pending = piece;
          _say('Point at the floor to place the ${item.name}');
          return;
        case PlaceOutcome.noModel:
          _say('The ${item.name} has no 3D model yet');
          return;
        case PlaceOutcome.failed:
          _say("Couldn't place the ${item.name}. Try again");
          return;
      }
    }
    if (!mounted) return;
    ref.haptic(HapticKind.light);
    _say('${item.name} placed · true scale');
  }

  Future<void> _capture() async {
    final pieces = ref.read(placedPiecesProvider);
    if (pieces.isEmpty) {
      _say('Add a piece first, then save the design');
      return;
    }
    final shot = await _ar?.snapshot();
    if (shot != null) ref.read(lastShotProvider.notifier).set(shot);
    ref.read(savedDesignsProvider.notifier).save(pieces);
    _say('Design saved');
  }

  Future<void> _askCamera() async {
    final c = ref.read(cameraAccessProvider.notifier);
    if (ref.read(cameraAccessProvider) == CameraAccess.blocked) {
      await c.openSettings();
    } else {
      await c.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final access = ref.watch(cameraAccessProvider);
    final cameraOff = access == CameraAccess.denied || access == CameraAccess.blocked;
    final live = ref.watch(arAvailableProvider) && access == CameraAccess.granted;
    ref.listen(settingsProvider.select((s) => s.floorGrid), (_, show) => _ar?.setShowPlanes(show));
    final ai = settings.aiSuggestions && _ai;
    final mq = MediaQuery.of(context);
    final bottom = math.max(GenieSpace.bottomControls - 14, mq.padding.bottom + GenieSpace.sm);

    final status =
        _toast ??
        (cameraOff
            ? 'Camera is off · tap to allow'
            : _scan == _Scan.searching
            ? 'Move your phone slowly to find the floor'
            : 'Floor found · tap + to add a piece');

    return AnnotatedRegion(
      value: GenieTheme.systemUi,
      child: Scaffold(
        backgroundColor: GenieColors.ink,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (live) ...[
              // The real camera: ARCore planes, anchored models.
              _LiveCamera(ar: _arSession(), showPlanes: settings.floorGrid),
              Center(
                child: IgnorePointer(
                  child: SizedBox.fromSize(
                    size: GenieArt.reticleSize,
                    child: _BreathingReticle(searching: _scan == _Scan.searching),
                  ),
                ),
              ),
            ] else
              // Placeholder feed + a simulated AR layer, in one scaled stage.
              _ArLayer(
                floorVisible: _scan == _Scan.found && settings.floorGrid && !cameraOff,
                searching: _scan == _Scan.searching,
                hideReticle: cameraOff,
              ),
            const _Scrims(),
            EdgeGlow(visible: ai),

            // Top: settings, AI.
            Positioned(
              left: GenieSpace.lg,
              right: GenieSpace.lg,
              top: mq.padding.top + GenieSpace.xs,
              child: Row(
                children: [
                  IconCircleButton(
                    icon: GenieIcons.settings,
                    semanticLabel: 'Settings',
                    style: IconCircleStyle.glass,
                    size: 46,
                    onPressed: () => context.push(Routes.settings),
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: GenieMotion.base,
                    switchInCurve: GenieMotion.easeOut,
                    child:
                        settings.aiSuggestions
                            ? AiSwitch(value: _ai, onChanged: (v) => setState(() => _ai = v))
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Status chip.
            Positioned(
              left: GenieSpace.lg,
              right: GenieSpace.lg,
              top: mq.padding.top + 70,
              child: Center(
                child: AnimatedSwitcher(
                  duration: GenieMotion.base,
                  switchInCurve: GenieMotion.easeOut,
                  switchOutCurve: GenieMotion.easeOut,
                  transitionBuilder:
                      (child, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                          position: Tween(begin: const Offset(0, -0.25), end: Offset.zero).animate(a),
                          child: child,
                        ),
                      ),
                  child:
                      cameraOff && _toast == null
                          ? Pressable(
                            key: const ValueKey('camera-off'),
                            onTap: _askCamera,
                            semanticLabel:
                                access == CameraAccess.blocked
                                    ? 'Camera is off. Open settings to allow it.'
                                    : 'Camera is off. Tap to allow.',
                            excludeChildSemantics: true,
                            child: StatusChip(label: status, dotColor: GenieColors.danger),
                          )
                          : StatusChip(key: ValueKey(status), label: status),
                ),
              ),
            ),

            // Bottom: last design · + · shutter.
            Positioned(
              left: GenieSpace.lg + 4,
              right: GenieSpace.lg + 4,
              bottom: bottom,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _LastDesignButton(onPressed: () => context.push(Routes.savedDesigns)),
                  AddButton(onPressed: _openCatalog),
                  ShutterButton(onPressed: _capture, semanticLabel: 'Save this design'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The live ARCore camera. Created once; the session lives as long as Home.
class _LiveCamera extends StatefulWidget {
  const _LiveCamera({required this.ar, required this.showPlanes});

  final GenieAr ar;
  final bool showPlanes;

  @override
  State<_LiveCamera> createState() => _LiveCameraState();
}

class _LiveCameraState extends State<_LiveCamera> {
  @override
  Widget build(BuildContext context) {
    return ARView(
      planeDetectionConfig: PlaneDetectionConfig.horizontal,
      onARViewCreated: (session, objects, anchors, _) =>
          widget.ar.attach(session, objects, anchors, showPlanes: widget.showPlanes),
    );
  }
}

/// Placeholder feed, floor grid, reticle and placed pieces, all in the
/// mockup's design space so they line up with the room in the picture.
class _ArLayer extends ConsumerWidget {
  const _ArLayer({required this.floorVisible, required this.searching, required this.hideReticle});

  final bool floorVisible;
  final bool searching;
  final bool hideReticle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pieces = ref.watch(placedPiecesProvider);
    final catalog = ref.watch(catalogProvider).value;
    return DesignCanvas(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: Image.asset(GenieArt.homeRoom, fit: BoxFit.fill, gaplessPlayback: true, excludeFromSemantics: true),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: floorVisible ? 1 : 0,
              duration: GenieMotion.slow,
              curve: GenieMotion.easeOut,
              child: const RepaintBoundary(
                child: CustomPaint(painter: FloorGridPainter(quad: GenieArt.floorQuad, skip: (0.5, 0.6))),
              ),
            ),
          ),
        ),
        CenteredAt(
          center: GenieArt.reticleCenter,
          size: GenieArt.reticleSize,
          child: AnimatedOpacity(
            opacity: hideReticle ? 0 : 1,
            duration: GenieMotion.base,
            child: _BreathingReticle(searching: searching),
          ),
        ),
        if (catalog != null)
          for (final p in pieces) _PlacedPieceView(key: ValueKey(p.uid), piece: p, item: catalog.item(p.itemId)),
      ],
    );
  }
}

/// Breathes gently while searching, settles (on a spring) once the floor is
/// found. Still with reduced motion.
class _BreathingReticle extends StatefulWidget {
  const _BreathingReticle({required this.searching});

  final bool searching;

  @override
  State<_BreathingReticle> createState() => _BreathingReticleState();
}

class _BreathingReticleState extends State<_BreathingReticle> with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final SpringValue _scale = SpringValue(vsync: this, value: 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_BreathingReticle old) {
    super.didUpdateWidget(old);
    if (old.searching != widget.searching) _sync();
  }

  void _sync() {
    if (widget.searching && !context.reduceMotion) {
      _breath.repeat(reverse: true);
      return;
    }
    // Hand the breath's current size to the spring, so it settles from where
    // it is rather than jumping.
    final from = _breath.isAnimating ? 0.9 + 0.1 * GenieMotion.easeInOut.transform(_breath.value) : 1.0;
    _breath.stop();
    _scale.set(from);
    _scale.animateTo(1, GenieMotion.toggle, instant: context.reduceMotion);
  }

  @override
  void dispose() {
    _breath.dispose();
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_breath, _scale.animation]),
        builder: (context, child) {
          final breathing = _breath.isAnimating;
          final t = GenieMotion.easeInOut.transform(_breath.value);
          final scale = breathing ? 0.9 + 0.1 * t : _scale.value;
          final opacity = breathing ? 0.65 + 0.35 * t : 1.0;
          return Opacity(opacity: opacity, child: Transform.scale(scale: scale, child: child));
        },
        child: const Reticle(size: GenieArt.reticleSize),
      ),
    );
  }
}

/// A placed piece standing on the floor, true-ish size, dropped in on a soft
/// spring. Uses the piece's render when there is one.
class _PlacedPieceView extends StatelessWidget {
  const _PlacedPieceView({super.key, required this.piece, required this.item});

  final PlacedPiece piece;
  final FurnitureItem? item;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    if (item == null) return const SizedBox.shrink();
    final image = item.imageFor(item.fabric(piece.fabricId));
    // Footprint width at the reticle's depth; renders include some margin.
    final w = item.dimensions.width * GenieArt.ptPerCm * (image != null && image.contains('chair_lune') ? 1.55 : 1.15);
    final h = w * 1.04;
    // Spread multiple pieces around the reticle.
    const offsets = [Offset(0, 0), Offset(-92, -24), Offset(96, -20), Offset(-70, 36), Offset(80, 40)];
    final o = offsets[piece.slot % offsets.length];
    final foot = GenieArt.reticleCenter + o;
    return Positioned(
      left: foot.dx - w / 2,
      top: foot.dy - h * 0.86,
      width: w,
      height: h,
      child: Semantics(
        label: '${item.name}, placed',
        child: PopIn(
          visible: true,
          from: 0.96,
          slide: const Offset(0, -12),
          spring: GenieMotion.popIn,
          alignment: Alignment.bottomCenter,
          child:
              image != null
                  ? Image.asset(image, fit: BoxFit.contain, excludeFromSemantics: true)
                  : DecoratedBox(
                    decoration: const BoxDecoration(color: GenieColors.glassFill, borderRadius: GenieRadii.tileAll),
                    child: IconTheme(
                      data: const IconThemeData(size: 36, color: GenieColors.ink),
                      child: Center(child: CategoryGlyph(item.categoryId)),
                    ),
                  ),
        ),
      ),
    );
  }
}

/// Light dark scrims so the white controls read on any room.
class _Scrims extends StatelessWidget {
  const _Scrims();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [GenieColors.scrim.withValues(alpha: 0.16), GenieColors.scrim.withValues(alpha: 0)],
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [GenieColors.scrim.withValues(alpha: 0.22), GenieColors.scrim.withValues(alpha: 0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail of the latest design; opens Saved designs.
class _LastDesignButton extends ConsumerWidget {
  const _LastDesignButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(savedDesignsProvider).length;
    final shot = ref.watch(lastShotProvider);
    return Pressable(
      onTap: onPressed,
      semanticLabel: count == 0 ? 'Saved designs, none yet' : 'Saved designs, $count',
      excludeChildSemantics: true,
      pressedScale: GenieMotion.pressScaleLarge,
      child: Container(
        width: GenieSizes.iconButton,
        height: GenieSizes.iconButton,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(13)),
          border: Border.all(color: GenieColors.card, width: 2),
          boxShadow: GenieShadows.glass,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(11)),
          child: shot != null
              ? Image(image: shot, fit: BoxFit.cover, excludeFromSemantics: true)
              : Image.asset(GenieArt.lastDesignThumb, fit: BoxFit.cover, excludeFromSemantics: true),
        ),
      ),
    );
  }
}

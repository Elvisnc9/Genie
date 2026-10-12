import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/settings_controller.dart';
import '../../core/models/fabric.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_layout.dart';

// ------------------------------------------------------------------- page 1

/// "Design the room you're standing in." The Lune armchair is already in the
/// room; its pin and product card pop in, then the sparkles fade up.
class RoomStoryPage extends StatelessWidget {
  const RoomStoryPage({super.key, required this.index, required this.page, required this.active});

  final int index;
  final ValueNotifier<double> page;
  final bool active;

  static const _beat = Duration(milliseconds: 160); // after the page settles

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ArtLayer(
          page: page,
          index: index,
          child: ArtPlate(
            GenieArt.onboardingRoom,
            overlays: [
              for (final (i, (at, size)) in GenieArt.roomSparkles.indexed)
                CenteredAt(
                  center: at,
                  size: Size.square(size),
                  child: PopIn(
                    visible: active,
                    delay: _beat + GenieMotion.stagger * 3 + GenieMotion.stagger * i,
                    from: 0.6,
                    child: SceneSparkle(size: size),
                  ),
                ),
              CenteredAt(
                center: GenieArt.roomPin,
                size: const Size.square(26),
                child: PopIn(visible: active, delay: _beat, child: const PinDot()),
              ),
              Positioned.fromRect(
                rect: GenieArt.roomCard,
                child: PopIn(
                  visible: active,
                  delay: _beat + GenieMotion.stagger,
                  alignment: Alignment.topRight,
                  child: const _PlacedCard(),
                ),
              ),
            ],
          ),
        ),
        const ArtFades(bottomStart: 0.7),
        StoryCopy(
          page: page,
          index: index,
          headline: "Design the room\nyou're standing in.",
          body:
              "Point your camera at any space and drop in true-to-size furniture. Walk around it like it's already yours.",
          bodyGap: 48,
        ),
      ],
    );
  }
}

class _PlacedCard extends ConsumerWidget {
  const _PlacedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final units = ref.watch(unitsProvider);
    return Semantics(
      label: 'Lune armchair placed. Terracotta, ${units.formatPair(80, 74)}',
      excludeSemantics: true,
      child: GlassSurface(
        borderRadius: GenieRadii.cardAll,
        padding: const EdgeInsets.fromLTRB(GenieSpace.sm, GenieSpace.sm - 2, GenieSpace.sm, GenieSpace.sm - 2),
        child: Row(
          children: [
            Container(
              width: 57,
              height: 57,
              decoration: const BoxDecoration(
                color: GenieColors.tileBg,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              padding: const EdgeInsets.all(5),
              child: Image.asset(GenieArt.luneTerracotta, fit: BoxFit.contain),
            ),
            const SizedBox(width: GenieSpace.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lune armchair', style: text.titleMedium, maxLines: 1),
                  const SizedBox(height: 2),
                  Text(
                    'Terracotta · ${units.formatPair(80, 74)}',
                    style: text.bodyMedium!.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: GenieColors.teal, shape: BoxShape.circle),
              child: const Icon(GenieIcons.check, size: 19, color: GenieColors.onAccent),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- page 2

/// "Every piece, from every side." The chair turns slowly on its turntable;
/// drag to spin it with momentum, tap a swatch to swap the fabric.
///
/// The chair is a flat render until the 3D viewer lands, so "spinning" rocks
/// it in perspective while the handle travels the full ring.
class TurntableStoryPage extends ConsumerStatefulWidget {
  const TurntableStoryPage({
    super.key,
    required this.index,
    required this.page,
    required this.active,
    required this.visible,
  });

  final int index;
  final ValueNotifier<double> page;
  final bool active;

  /// Whether this is the current page (auto-spin only runs while it is).
  final bool visible;

  static const fabrics = [
    Fabric(id: 'oat', name: 'Oat bouclé', color: Color(0xFFE6DCCB), image: 'assets/images/chair_lune_oat.png'),
    Fabric(
      id: 'terracotta',
      name: 'Terracotta bouclé',
      color: Color(0xFFC8693F),
      image: 'assets/images/chair_lune_terracotta.png',
    ),
    Fabric(id: 'sage', name: 'Sage bouclé', color: Color(0xFF8E9E80), image: 'assets/images/chair_lune_sage.png'),
    Fabric(id: 'navy', name: 'Navy bouclé', color: Color(0xFF2E3748), image: 'assets/images/chair_lune_navy.png'),
  ];

  @override
  ConsumerState<TurntableStoryPage> createState() => _TurntableStoryPageState();
}

class _TurntableStoryPageState extends ConsumerState<TurntableStoryPage> with SingleTickerProviderStateMixin {
  Fabric _fabric = TurntableStoryPage.fabrics[1];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final f in TurntableStoryPage.fabrics) {
      precacheImage(AssetImage(f.image!), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(unitsProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.15),
              radius: 0.75,
              colors: [GenieColors.card, GenieColors.bg],
            ),
          ),
        ),
        ArtLayer(
          page: widget.page,
          index: widget.index,
          child: SpinStage(fabric: _fabric, spinning: widget.visible, measureLabel: units.format(80)),
        ),
        StoryCopy(
          page: widget.page,
          index: widget.index,
          headline: 'Every piece,\nfrom every side.',
          body: 'Spin it, swap the fabric and check the real dimensions before you commit.',
          bodyGap: 33,
          aboveBodyGap: 26,
          aboveBody: Center(
            child: SwatchPicker(
              fabrics: TurntableStoryPage.fabrics,
              selected: _fabric,
              spacing: 2,
              onChanged: (f) => setState(() => _fabric = f),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- page 3

/// "Let Genie style it with you." Colour reads pop in one by one, the
/// suggestion box fades up, the card slides in. The AI switch in the card
/// really turns the AI layer (glow, suggestion) on and off.
class AiStoryPage extends StatefulWidget {
  const AiStoryPage({super.key, required this.index, required this.page, required this.active});

  final int index;
  final ValueNotifier<double> page;
  final bool active;

  @override
  State<AiStoryPage> createState() => _AiStoryPageState();
}

class _AiStoryPageState extends State<AiStoryPage> {
  bool _ai = true;

  static const _beat = Duration(milliseconds: 120);
  static const _oneByOne = Duration(milliseconds: 140);

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final showAi = active && _ai;
    return Stack(
      fit: StackFit.expand,
      children: [
        ArtLayer(
          page: widget.page,
          index: widget.index,
          child: ArtPlate(
            GenieArt.onboardingAiRoom,
            overlays: [
              Positioned.fromRect(
                rect: GenieArt.suggestionBox,
                child: PopIn(
                  visible: showAi,
                  delay: _beat + _oneByOne * 2,
                  from: 0.94,
                  child: DashedBox(fill: GenieColors.card.withValues(alpha: 0.14)),
                ),
              ),
              CenteredAt(
                center: GenieArt.suggestionSparkle,
                size: const Size.square(20),
                child: PopIn(
                  visible: showAi,
                  delay: _beat + _oneByOne * 3,
                  from: 0.6,
                  child: const SceneSparkle(size: 20, color: GenieColors.teal),
                ),
              ),
              _ColourRead(
                at: GenieArt.wallPin,
                label: 'Soft sage wall',
                color: GenieArt.wallSwatch,
                visible: active,
                delay: _beat,
              ),
              _ColourRead(
                at: GenieArt.sofaPin,
                label: 'Sage sofa',
                color: GenieArt.sofaSwatch,
                visible: active,
                delay: _beat + _oneByOne,
              ),
            ],
          ),
        ),
        const ArtFades(bottomStart: 0.64),
        EdgeGlow(visible: showAi),
        StoryCopy(
          page: widget.page,
          index: widget.index,
          headline: 'Let Genie style\nit with you.',
          body: 'Genie reads your light and colours, then suggests what fits.',
          bodyGap: 0,
          aboveBodyGap: 12,
          aboveBody: PopIn(
            visible: active,
            delay: _beat + _oneByOne,
            from: 0.98,
            slide: const Offset(0, 28),
            spring: GenieMotion.snap,
            child: _SuggestionCard(ai: _ai, onAi: (v) => setState(() => _ai = v)),
          ),
        ),
      ],
    );
  }
}

class _ColourRead extends StatelessWidget {
  const _ColourRead({
    required this.at,
    required this.label,
    required this.color,
    required this.visible,
    required this.delay,
  });

  final Offset at;
  final String label;
  final Color color;
  final bool visible;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: at.dx - 13,
      top: at.dy - 15,
      child: PopIn(
        visible: visible,
        delay: delay,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [const PinDot(), const SizedBox(width: 4), ColorReadPill(label: label, color: color)],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.ai, required this.onAi});

  final bool ai;
  final ValueChanged<bool> onAi;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GlassSurface(
      borderRadius: const BorderRadius.all(Radius.circular(26)),
      padding: const EdgeInsets.fromLTRB(GenieSpace.md, GenieSpace.xxs, GenieSpace.sm, GenieSpace.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Eyebrow('Genie suggests', color: GenieColors.teal, leading: SparkleIcon(size: 14)),
              const Spacer(),
              ExcludeSemantics(
                child: Text(
                  'AI mode',
                  style: text.labelMedium!.copyWith(color: GenieColors.ink2, fontWeight: FontWeight.w600),
                ),
              ),
              GenieToggle(value: ai, onChanged: onAi, size: GenieToggleSize.small, semanticLabel: 'AI mode'),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedOpacity(
            opacity: ai ? 1 : 0.45,
            duration: GenieMotion.base,
            curve: GenieMotion.easeOut,
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: const BoxDecoration(
                    color: GenieColors.tileBg,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/images/piece_arc_lamp.png', fit: BoxFit.cover, excludeFromSemantics: true),
                ),
                const SizedBox(width: GenieSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arc floor lamp, brass', style: text.titleMedium!.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('Warms the cool wall and fills this empty corner.', style: text.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

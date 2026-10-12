import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feedback/haptics.dart';
import '../models/units.dart';
import '../theme/theme.dart';
import 'glass_surface.dart';
import 'pressable.dart';
import 'sparkle_icon.dart';

enum GenieToggleSize { regular, small }

/// Genie's switch. The knob runs on a spring, and the track colour is tied to
/// the knob's position, so the fill crossfades in step with the motion and a
/// fast double-tap reverses smoothly from wherever the knob is.
///
/// With no [onChanged], it is display-only (its parent row handles taps and
/// semantics). Pass [semanticLabel] when it stands alone.
class GenieToggle extends ConsumerStatefulWidget {
  const GenieToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = GenieToggleSize.regular,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final GenieToggleSize size;
  final String? semanticLabel;

  @override
  ConsumerState<GenieToggle> createState() => _GenieToggleState();
}

class _GenieToggleState extends ConsumerState<GenieToggle> with SingleTickerProviderStateMixin {
  late final SpringValue _t = SpringValue(vsync: this, value: widget.value ? 1 : 0);

  @override
  void didUpdateWidget(GenieToggle old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _t.animateTo(widget.value ? 1 : 0, GenieMotion.toggle, instant: context.reduceMotion);
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  void _toggle() {
    ref.haptic(HapticKind.selection);
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final small = widget.size == GenieToggleSize.small;
    final w = small ? GenieSizes.toggleSmallWidth : GenieSizes.toggleWidth;
    final h = small ? GenieSizes.toggleSmallHeight : GenieSizes.toggleHeight;
    const inset = 2.0;
    final knob = h - inset * 2;
    final travel = w - knob - inset * 2;

    final track = SizedBox(
      width: w,
      height: h,
      child: AnimatedBuilder(
        animation: _t.animation,
        builder: (context, _) {
          final t = _t.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(GenieColors.toggleOff, GenieColors.teal, t.clamp(0.0, 1.0)),
              borderRadius: GenieRadii.pillAll,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(inset + travel * t, 0),
                child: Container(
                  width: knob,
                  height: knob,
                  decoration: const BoxDecoration(
                    color: GenieColors.card,
                    shape: BoxShape.circle,
                    boxShadow: GenieShadows.knob,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.onChanged == null) return ExcludeSemantics(child: RepaintBoundary(child: track));

    return Pressable(
      onTap: _toggle,
      semanticLabel: widget.semanticLabel,
      toggled: widget.value,
      excludeChildSemantics: true,
      pressedScale: 1, // the knob's travel is the feedback
      child: RepaintBoundary(child: track),
    );
  }
}

/// Home's AI pill: sparkle, "AI" and a small toggle, on glass. The whole pill
/// is the hit target. When on, the glass picks up a teal-soft tint.
class AiSwitch extends ConsumerWidget {
  const AiSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Pressable(
      onTap: () {
        ref.haptic(HapticKind.selection);
        onChanged(!value);
      },
      semanticLabel: 'AI suggestions',
      toggled: value,
      excludeChildSemantics: true,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: value ? GenieColors.tealSoft.withValues(alpha: 0.86) : GenieColors.glassFill),
        duration: GenieMotion.base,
        curve: GenieMotion.easeOut,
        builder:
            (context, tint, child) => GlassSurface(
              borderRadius: GenieRadii.pillAll,
              tint: tint,
              padding: const EdgeInsets.fromLTRB(GenieSpace.sm, 6, 6, 6),
              child: child!,
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SparkleIcon(size: 14),
            const SizedBox(width: 6),
            Text('AI', style: text.labelMedium!.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(width: GenieSpace.xs),
            GenieToggle(value: value, onChanged: null, size: GenieToggleSize.small),
          ],
        ),
      ),
    );
  }
}

/// A two-or-more option segmented control (cm / in). The white thumb springs
/// between segments; each segment is a 48-wide target.
class SegmentedChoice<T> extends ConsumerStatefulWidget {
  const SegmentedChoice({
    super.key,
    required this.options,
    required this.labels,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.segmentWidth = 50,
  }) : assert(options.length == labels.length);

  final List<T> options;
  final List<String> labels;
  final T value;
  final ValueChanged<T> onChanged;
  final String? semanticLabel;
  final double segmentWidth;

  @override
  ConsumerState<SegmentedChoice<T>> createState() => _SegmentedChoiceState<T>();
}

class _SegmentedChoiceState<T> extends ConsumerState<SegmentedChoice<T>> with SingleTickerProviderStateMixin {
  late final SpringValue _pos = SpringValue(vsync: this, value: _index.toDouble());

  int get _index => widget.options.indexOf(widget.value).clamp(0, widget.options.length - 1);

  @override
  void didUpdateWidget(SegmentedChoice<T> old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _pos.animateTo(_index.toDouble(), GenieMotion.toggle, instant: context.reduceMotion);
    }
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.labelMedium!;
    const pad = 4.0;
    const height = 40.0;
    final sw = widget.segmentWidth;

    final width = sw * widget.options.length + pad * 2;

    // The track is 40 tall, but the segments' hit area is the full 48.
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: SizedBox(
        width: width,
        height: GenieSizes.minTouch,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: height,
              padding: const EdgeInsets.all(pad),
              decoration: BoxDecoration(
                color: GenieColors.track,
                borderRadius: BorderRadius.circular(GenieRadii.segment + pad),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedBuilder(
                animation: _pos.animation,
                builder: (context, child) => Transform.translate(offset: Offset(_pos.value * sw, 0), child: child),
                child: Container(
                  width: sw,
                  decoration: BoxDecoration(
                    color: GenieColors.card,
                    borderRadius: BorderRadius.circular(GenieRadii.segment),
                    boxShadow: GenieShadows.knob,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              left: pad,
              right: pad,
              child: Row(
                children: [
                  for (var i = 0; i < widget.options.length; i++)
                    _Segment(
                      width: sw,
                      label: widget.labels[i],
                      selected: i == _index,
                      style: text,
                      onTap: () {
                        if (i == _index) return;
                        ref.haptic(HapticKind.selection);
                        widget.onChanged(widget.options[i]);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.width,
    required this.label,
    required this.selected,
    required this.style,
    required this.onTap,
  });

  final double width;
  final String label;
  final bool selected;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Center(
            // Only the colour animates: the fonts are static, so tweening
            // the weight would step through instances and jitter the width.
            child: AnimatedDefaultTextStyle(
              duration: GenieMotion.fast,
              curve: GenieMotion.easeOut,
              style: style.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? GenieColors.ink : GenieColors.ink3,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

/// cm / in, as used in Settings.
class SegmentedUnits extends StatelessWidget {
  const SegmentedUnits({super.key, required this.value, required this.onChanged});

  final Units value;
  final ValueChanged<Units> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedChoice<Units>(
      options: Units.values,
      labels: [for (final u in Units.values) u.label],
      value: value,
      onChanged: onChanged,
      semanticLabel: 'Units',
    );
  }
}

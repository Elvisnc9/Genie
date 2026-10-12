import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feedback/haptics.dart';
import '../theme/theme.dart';

/// The base of every tappable thing in Genie.
///
/// Press feedback is a spring scale (about 0.97): it goes down the moment the
/// finger lands and springs back on release, carrying velocity if the user
/// taps again mid-flight. With reduced motion on, the scale is skipped.
///
/// [pressed] lets a parent restyle on press (e.g. a darker fill).
class Pressable extends ConsumerStatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.semanticLabel,
    this.pressedScale = GenieMotion.pressScale,
    this.haptic = HapticKind.none,
    this.enabled = true,
    this.minSize = const Size.square(GenieSizes.minTouch),
    this.onPressedChanged,
    this.excludeChildSemantics = false,
    this.selected,
    this.toggled,
  });

  final VoidCallback? onTap;
  final Widget child;
  final String? semanticLabel;
  final double pressedScale;
  final HapticKind haptic;
  final bool enabled;
  final Size minSize;
  final ValueChanged<bool>? onPressedChanged;
  final bool excludeChildSemantics;
  final bool? selected;
  final bool? toggled;

  @override
  ConsumerState<Pressable> createState() => _PressableState();
}

class _PressableState extends ConsumerState<Pressable> with SingleTickerProviderStateMixin {
  late final SpringValue _scale = SpringValue(vsync: this, value: 1);
  bool _down = false;

  bool get _active => widget.enabled && widget.onTap != null;

  void _setDown(bool down) {
    if (_down == down) return;
    _down = down;
    widget.onPressedChanged?.call(down);
    _scale.animateTo(down ? widget.pressedScale : 1, GenieMotion.press, instant: context.reduceMotion);
  }

  void _handleTap() {
    ref.haptic(widget.haptic);
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _active,
      label: widget.semanticLabel,
      selected: widget.selected,
      toggled: widget.toggled,
      excludeSemantics: widget.excludeChildSemantics,
      onTap: _active ? _handleTap : null,
      // Press-in starts on the raw pointer, not onTapDown: inside a scroll view
      // onTapDown waits ~100ms to rule out a drag, and feedback must be
      // instant. If the gesture turns into a scroll, onTapCancel releases it.
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _active ? (_) => _setDown(true) : null,
        onPointerUp: _active ? (_) => _setDown(false) : null,
        onPointerCancel: _active ? (_) => _setDown(false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapCancel: _active ? () => _setDown(false) : null,
          onTap: _active ? _handleTap : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: widget.minSize.width, minHeight: widget.minSize.height),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: ScaleTransition(scale: _scale.animation, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

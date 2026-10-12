import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Enters with a spring "pop": scale from [from] to 1 plus a fade, after
/// [delay]. Leaves faster than it came (a quick fade). Interruptible: flipping
/// [visible] mid-flight carries on from where it is.
///
/// [slide] adds a short rise (e.g. Offset(0, 24) for cards sliding up).
/// With reduced motion it only fades.
class PopIn extends StatefulWidget {
  const PopIn({
    super.key,
    required this.visible,
    required this.child,
    this.delay = Duration.zero,
    this.from = GenieMotion.popInFrom,
    this.slide = Offset.zero,
    this.alignment = Alignment.center,
    this.spring,
  });

  final bool visible;
  final Widget child;
  final Duration delay;
  final double from;
  final Offset slide;
  final Alignment alignment;
  final SpringDescription? spring;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final SpringValue _t = SpringValue(vsync: this, value: 0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.visible) _schedule(true);
  }

  @override
  void didUpdateWidget(PopIn old) {
    super.didUpdateWidget(old);
    if (old.visible != widget.visible) _schedule(widget.visible);
  }

  void _schedule(bool show) {
    _timer?.cancel();
    if (!show) {
      _t.animateTo(0, GenieMotion.press, instant: context.reduceMotion);
      return;
    }
    if (widget.delay == Duration.zero) {
      _go();
    } else {
      _timer = Timer(widget.delay, _go);
    }
  }

  void _go() {
    if (!mounted) return;
    _t.animateTo(1, widget.spring ?? GenieMotion.popIn, instant: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    return AnimatedBuilder(
      animation: _t.animation,
      builder: (context, child) {
        final t = _t.value;
        final opacity = (t * 1.6).clamp(0.0, 1.0);
        if (opacity == 0) return Opacity(opacity: 0, child: IgnorePointer(child: child));
        if (reduce) return Opacity(opacity: opacity, child: child);
        final scale = widget.from + (1 - widget.from) * t;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: widget.slide * (1 - t),
            child: Transform.scale(scale: scale, alignment: widget.alignment, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

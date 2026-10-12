import 'package:flutter/material.dart';

import '../feedback/haptics.dart';
import '../theme/theme.dart';
import 'glass_surface.dart';
import 'pressable.dart';

/// The teal pill. Height 56, fully rounded.
///
/// [expand] makes it full width (Allow camera, Place in my room); otherwise it
/// hugs its label (Next). While [busy], it keeps its size and shows a small
/// spinner so the layout never jumps.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.expand = false,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool expand;
  final bool busy;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final enabled = widget.onPressed != null && !widget.busy;
    final fill =
        !enabled && !widget.busy
            ? GenieColors.teal.withValues(alpha: 0.38)
            : _pressed
            ? GenieColors.tealDark
            : GenieColors.teal;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: GenieSizes.iconSmall + 2, color: GenieColors.onAccent),
          const SizedBox(width: GenieSpace.xs + 2),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelLarge!.copyWith(color: GenieColors.onAccent),
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: GenieSpace.sm),
          Icon(widget.trailingIcon, size: GenieSizes.icon, color: GenieColors.onAccent),
        ],
      ],
    );

    return Pressable(
      onTap: enabled ? widget.onPressed : null,
      haptic: HapticKind.light,
      semanticLabel: widget.label,
      excludeChildSemantics: true,
      onPressedChanged: (down) => setState(() => _pressed = down),
      minSize: const Size(GenieSizes.minTouch, GenieSizes.buttonHeight),
      child: AnimatedContainer(
        duration: GenieMotion.fast,
        curve: GenieMotion.easeOut,
        constraints: const BoxConstraints(minHeight: GenieSizes.buttonHeight),
        width: widget.expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: GenieSpace.xxl - 4, vertical: GenieSpace.sm),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: GenieRadii.pillAll,
          boxShadow: enabled ? GenieShadows.raised : null,
        ),
        child:
            widget.busy
                ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(opacity: 0, child: content),
                    const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: GenieColors.onAccent),
                    ),
                  ],
                )
                : content,
      ),
    );
  }
}

/// A quiet text action: Skip, Not now. 48 tall so it is easy to hit.
class QuietButton extends StatelessWidget {
  const QuietButton({super.key, required this.label, required this.onPressed, this.color});

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 15, color: color ?? GenieColors.ink2);
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: GenieSpace.sm), child: Text(label, style: style)),
    );
  }
}

enum IconCircleStyle {
  /// White disc with a soft shadow, for light screens (Settings, Detail).
  solid,

  /// Frosted glass, for controls over the camera.
  glass,
}

/// A 48 circle holding one icon. Always needs a [semanticLabel].
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.style = IconCircleStyle.solid,
    this.size = GenieSizes.iconButton,
    this.iconColor = GenieColors.ink,
    this.selected,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final IconCircleStyle style;
  final double size;
  final Color iconColor;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(icon, size: GenieSizes.icon - 2, color: iconColor);
    final face = SizedBox.square(
      dimension: size,
      child: switch (style) {
        IconCircleStyle.glass => GlassSurface(circle: true, child: Center(child: glyph)),
        IconCircleStyle.solid => DecoratedBox(
          decoration: const BoxDecoration(
            color: GenieColors.card,
            shape: BoxShape.circle,
            boxShadow: GenieShadows.card,
          ),
          child: Center(child: glyph),
        ),
      },
    );
    return Pressable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      selected: selected,
      pressedScale: GenieMotion.pressScaleLarge,
      child: face,
    );
  }
}

/// Home's big teal +. Opens the furniture sheet.
class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.onPressed, this.semanticLabel = 'Add a piece'});

  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      haptic: HapticKind.light,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      pressedScale: GenieMotion.pressScaleLarge,
      // A translucent ring around the teal disc keeps it legible on any
      // camera image (from the Home mockup).
      child: Container(
        width: GenieSizes.addButton + 14,
        height: GenieSizes.addButton + 14,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: GenieColors.card.withValues(alpha: 0.32),
          shape: BoxShape.circle,
          border: Border.all(color: GenieColors.glassBorder),
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(color: GenieColors.teal, shape: BoxShape.circle, boxShadow: GenieShadows.raised),
          child: Icon(GenieIcons.add, size: 30, color: GenieColors.onAccent),
        ),
      ),
    );
  }
}

/// The white shutter ring for capturing a shot of the room.
class ShutterButton extends StatelessWidget {
  const ShutterButton({super.key, required this.onPressed, this.semanticLabel = 'Take a photo'});

  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      haptic: HapticKind.medium,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      pressedScale: 0.9,
      child: Container(
        width: GenieSizes.shutter,
        height: GenieSizes.shutter,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: GenieColors.onAccent, width: 3),
          boxShadow: [BoxShadow(color: GenieShadows.tint(0.18), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: const DecoratedBox(decoration: BoxDecoration(color: GenieColors.onAccent, shape: BoxShape.circle)),
      ),
    );
  }
}

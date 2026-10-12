import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'glass_surface.dart';

/// Small uppercase label above a group or a product name ("DESIGNING",
/// "ARMCHAIR"). Pinned by the mockups.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color, this.leading});

  final String text;
  final Color? color;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall!.copyWith(color: color);
    final label = Text(text.toUpperCase(), style: style);
    if (leading == null) return Semantics(header: true, child: label);
    return Semantics(
      header: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: [leading!, const SizedBox(width: GenieSpace.xs), label]),
    );
  }
}

/// Glass status pill over the camera: a teal dot and a short line,
/// e.g. "Floor found · tap + to add a piece".
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.dotColor = GenieColors.teal});

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 12.5);
    return Semantics(
      liveRegion: true,
      label: label,
      excludeSemantics: true,
      child: GlassSurface(
        borderRadius: GenieRadii.pillAll,
        padding: const EdgeInsets.symmetric(horizontal: GenieSpace.sm + 2, vertical: GenieSpace.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: GenieSpace.xs),
            Flexible(child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

/// Small rounded chip for short facts ("True scale", "360°", "80 cm").
class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.label, this.icon, this.accent = false});

  final String label;
  final IconData? icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final fg = accent ? GenieColors.tealDark : GenieColors.ink;
    final style = Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 12.5, color: fg);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GenieSpace.sm, vertical: 6),
      decoration: BoxDecoration(
        color: accent ? GenieColors.tealSoft : GenieColors.card,
        borderRadius: GenieRadii.chipAll,
        boxShadow: accent ? null : GenieShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 6)],
          Text(label, style: style),
        ],
      ),
    );
  }
}

/// "New" badge on product tiles.
class NewBadge extends StatelessWidget {
  const NewBadge({super.key, this.label = 'New'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall!.copyWith(color: GenieColors.badgeFg, letterSpacing: 0, fontSize: 11);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GenieSpace.xs, vertical: 3),
      decoration: const BoxDecoration(
        color: GenieColors.badgeBg,
        borderRadius: BorderRadius.all(Radius.circular(GenieRadii.badge)),
      ),
      child: Text(label, style: style),
    );
  }
}

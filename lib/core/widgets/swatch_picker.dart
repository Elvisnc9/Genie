import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feedback/haptics.dart';
import '../models/fabric.dart';
import '../theme/theme.dart';
import 'pressable.dart';

/// A row of fabric swatches. The selected one gets a 2px teal ring with a
/// small gap; the ring fades and settles in (160ms ease-out). Each swatch is a
/// 48 target even when the disc is smaller.
class SwatchPicker extends ConsumerWidget {
  const SwatchPicker({
    super.key,
    required this.fabrics,
    required this.selected,
    required this.onChanged,
    this.size = GenieSizes.swatch,
    this.spacing = GenieSpace.xs,
  });

  final List<Fabric> fabrics;
  final Fabric? selected;
  final ValueChanged<Fabric> onChanged;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      container: true,
      label: 'Fabric',
      child: Wrap(
        spacing: spacing,
        children: [
          for (final f in fabrics)
            _Swatch(
              fabric: f,
              size: size,
              selected: f == selected,
              onTap: () {
                if (f == selected) return;
                ref.haptic(HapticKind.selection);
                onChanged(f);
              },
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.fabric, required this.size, required this.selected, required this.onTap});

  final Fabric fabric;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const ringGap = 3.0;
    const ringWidth = 2.0;
    final ringSize = size + (ringGap + ringWidth) * 2;
    // Very light fabrics get a hairline so they don't vanish on white.
    final light = fabric.color.computeLuminance() > 0.7;
    final reduce = context.reduceMotion;

    return Pressable(
      onTap: onTap,
      semanticLabel: fabric.name,
      selected: selected,
      excludeChildSemantics: true,
      pressedScale: 0.92,
      child: SizedBox.square(
        dimension: ringSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: GenieMotion.fast,
              curve: GenieMotion.easeOut,
              child: AnimatedScale(
                scale: selected || reduce ? 1 : 0.9,
                duration: GenieMotion.fast,
                curve: GenieMotion.easeOut,
                child: Container(
                  width: ringSize,
                  height: ringSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: GenieColors.teal, width: ringWidth),
                  ),
                ),
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: fabric.color,
                shape: BoxShape.circle,
                border: light ? Border.all(color: GenieColors.line) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

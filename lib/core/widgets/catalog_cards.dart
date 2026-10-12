import 'package:flutter/material.dart';

import '../feedback/haptics.dart';
import '../theme/theme.dart';
import 'labels.dart';
import 'pressable.dart';

/// Category in the furniture sheet: an icon tile with a label under it.
/// Selected = teal tile, white icon, bolder label.
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.icon, required this.label, required this.selected, required this.onTap});

  /// Usually a [CategoryGlyph]; coloured by the tile.
  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 11,
      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      color: selected ? GenieColors.ink : GenieColors.ink3,
    );
    return Pressable(
      onTap: onTap,
      haptic: HapticKind.selection,
      semanticLabel: label,
      selected: selected,
      excludeChildSemantics: true,
      child: SizedBox(
        width: GenieSizes.categoryTile + GenieSpace.md, // labels like "Armchairs" are wider than the tile
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: GenieMotion.fast,
              curve: GenieMotion.easeOut,
              width: GenieSizes.categoryTile,
              height: GenieSizes.categoryTile,
              decoration: BoxDecoration(
                color: selected ? GenieColors.teal : GenieColors.card,
                borderRadius: GenieRadii.tileAll,
                boxShadow: selected ? null : GenieShadows.card,
              ),
              child: IconTheme(
                data: IconThemeData(size: GenieSizes.icon, color: selected ? GenieColors.onAccent : GenieColors.ink),
                child: Center(child: icon),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// Product in the 2-column grid: image tile, optional "New" badge, a 3D
/// shortcut, then name and dimensions. No prices (undecided).
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.dimensions,
    required this.onTap,
    this.image,
    this.isNew = false,
    this.on3dTap,
    this.heroTag,
    this.fallback = const Icon(GenieIcons.armchairs),
  });

  final String name;

  /// Already formatted for the user's units, e.g. "80 × 74 cm".
  final String dimensions;
  final VoidCallback onTap;
  final ImageProvider? image;
  final bool isNew;
  final VoidCallback? on3dTap;

  /// Shared with the detail screen for the Hero flight.
  final Object? heroTag;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget picture =
        image != null
            ? Image(image: image!, fit: BoxFit.contain, excludeFromSemantics: true)
            : IconTheme(data: const IconThemeData(size: 44, color: GenieColors.ink3), child: fallback);
    picture = Padding(padding: const EdgeInsets.all(GenieSpace.sm), child: Center(child: picture));
    if (heroTag != null) picture = Hero(tag: heroTag!, child: picture);

    return Pressable(
      onTap: onTap,
      semanticLabel: '$name, $dimensions',
      excludeChildSemantics: false,
      child: Container(
        padding: const EdgeInsets.all(GenieSpace.xs),
        decoration: const BoxDecoration(
          color: GenieColors.card,
          borderRadius: GenieRadii.cardAll,
          boxShadow: GenieShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slightly wider than tall, as in the mockup. Shrinks before the
            // name and size get cut when text is large.
            Flexible(
              child: AspectRatio(
                aspectRatio: 1.12,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: GenieColors.tileBg, borderRadius: GenieRadii.tileAll),
                      ),
                    ),
                    Positioned.fill(child: ExcludeSemantics(child: picture)),
                    if (isNew) const Positioned(left: GenieSpace.xs, top: GenieSpace.xs, child: NewBadge()),
                    if (on3dTap != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Pressable(
                          onTap: on3dTap,
                          semanticLabel: 'View $name in 3D',
                          excludeChildSemantics: true,
                          pressedScale: GenieMotion.pressScaleLarge,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: GenieColors.card,
                              shape: BoxShape.circle,
                              boxShadow: GenieShadows.card,
                            ),
                            child: const Icon(GenieIcons.view3d, size: 16, color: GenieColors.teal),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(GenieSpace.xxs, GenieSpace.sm - 2, GenieSpace.xxs, GenieSpace.xxs),
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(dimensions, style: text.bodySmall, maxLines: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A collection in the sheet's horizontal row: room image, name and count.
/// A neutral scrim at the bottom keeps the white text readable on any photo.
class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.name,
    required this.pieceCount,
    required this.onTap,
    this.image,
    this.width = 168,
    this.height = 104,
  });

  final String name;
  final int pieceCount;
  final VoidCallback onTap;
  final ImageProvider? image;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final count = '$pieceCount ${pieceCount == 1 ? 'piece' : 'pieces'}';
    return Pressable(
      onTap: onTap,
      semanticLabel: '$name collection, $count',
      excludeChildSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: GenieRadii.tileAll,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null)
                Image(image: image!, fit: BoxFit.cover, excludeFromSemantics: true)
              else
                const ColoredBox(color: GenieColors.tileBg),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.35, 1],
                    colors: [GenieColors.scrim.withValues(alpha: 0), GenieColors.scrim.withValues(alpha: 0.55)],
                  ),
                ),
              ),
              Positioned(
                left: GenieSpace.sm,
                right: GenieSpace.sm,
                bottom: GenieSpace.sm - 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall!.copyWith(color: GenieColors.onAccent, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      count,
                      style: text.bodySmall!.copyWith(
                        color: GenieColors.onAccent.withValues(alpha: 0.85),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dimension cell on the detail screen: "Width / 80 cm".
class StatCell extends StatelessWidget {
  const StatCell({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: GenieSpace.sm, vertical: GenieSpace.sm - 2),
        decoration: const BoxDecoration(color: GenieColors.tileBg, borderRadius: GenieRadii.statAll),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: text.bodySmall!.copyWith(fontSize: 11.5)),
            const SizedBox(height: 2),
            Text(
              value,
              style: text.titleMedium!.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

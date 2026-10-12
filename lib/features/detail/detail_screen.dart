import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/catalog_repository.dart';
import '../../core/data/room_controller.dart';
import '../../core/data/settings_controller.dart';
import '../../core/models/fabric.dart';
import '../../core/models/furniture_item.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// Session favourites (persisted favourites can come with saved designs).
final favouritesProvider = NotifierProvider<Favourites, Set<String>>(Favourites.new);

class Favourites extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) => state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

/// A piece up close: spin it on the turntable, swap the fabric, check the
/// real size, then place it. Pops with the placed piece.
class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.itemId, this.fabricId});

  final String itemId;
  final String? fabricId;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  Fabric? _fabric;
  bool _spinning = false;

  @override
  void initState() {
    super.initState();
    // Start the slow spin after the Hero has landed.
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _spinning = true);
    });
  }

  void _place(FurnitureItem item, Fabric fabric) {
    final piece = ref.read(placedPiecesProvider.notifier).place(item.id, fabric.id);
    context.pop(piece);
  }

  void _share(FurnitureItem item) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Sharing arrives in a later build.')));
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final item = catalog.value?.item(widget.itemId);
    if (item == null) {
      return Scaffold(
        body: Center(
          child:
              catalog.isLoading
                  ? const CircularProgressIndicator(color: GenieColors.teal, strokeWidth: 2.4)
                  : Text("This piece isn't in the catalog.", style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }
    final fabric = _fabric ?? item.fabric(widget.fabricId);
    final favourite = ref.watch(favouritesProvider).contains(item.id);
    final mq = MediaQuery.of(context);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.42),
                  radius: 0.8,
                  colors: [GenieColors.card, GenieColors.bg],
                ),
              ),
            ),
          ),
          // Stage: fills the screen; the panel sits over its lower part.
          Positioned.fill(
            child: Stack(
              children: [
                SpinStage(
                  fabric: fabric,
                  image: item.imageFor(fabric),
                  layout: StageLayout.detail,
                  spinning: _spinning,
                  showSpinChip: false,
                  heroTag: item.heroTag,
                  fallback: CategoryGlyph(item.categoryId),
                ),
                DesignCanvas(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: GenieArt.detailSpinLabelY - 10,
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(GenieIcons.spin, size: 14, color: GenieColors.ink3),
                            const SizedBox(width: 6),
                            Text('Drag to spin', style: text.bodySmall!.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: GenieSpace.lg,
            right: GenieSpace.lg,
            top: mq.padding.top + GenieSpace.xs,
            child: Row(
              children: [
                IconCircleButton(
                  icon: GenieIcons.back,
                  semanticLabel: 'Back',
                  size: 46,
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                IconCircleButton(
                  icon: GenieIcons.share,
                  semanticLabel: 'Share',
                  size: 46,
                  onPressed: () => _share(item),
                ),
                const SizedBox(width: GenieSpace.sm),
                IconCircleButton(
                  icon: GenieIcons.favourite,
                  semanticLabel: favourite ? 'Remove from favourites' : 'Add to favourites',
                  selected: favourite,
                  size: 46,
                  iconColor: favourite ? GenieColors.teal : GenieColors.ink,
                  onPressed: () => ref.read(favouritesProvider.notifier).toggle(item.id),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _InfoPanel(
              item: item,
              fabric: fabric,
              onFabric: (f) => setState(() => _fabric = f),
              onPlace: () => _place(item, fabric),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends ConsumerWidget {
  const _InfoPanel({required this.item, required this.fabric, required this.onFabric, required this.onPlace});

  final FurnitureItem item;
  final Fabric fabric;
  final ValueChanged<Fabric> onFabric;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final units = ref.watch(unitsProvider);
    final category = ref.watch(catalogProvider).value?.categoryName(item.categoryId) ?? '';
    final singular = category.endsWith('s') ? category.substring(0, category.length - 1) : category;
    final d = item.dimensions;

    return Container(
      decoration: const BoxDecoration(
        color: GenieColors.card,
        borderRadius: GenieRadii.sheetTop,
        boxShadow: GenieShadows.card,
      ),
      padding: EdgeInsets.fromLTRB(
        GenieSpace.lg + 2,
        GenieSpace.lg + 2,
        GenieSpace.lg + 2,
        math.max(GenieSpace.md, MediaQuery.paddingOf(context).bottom - 4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(singular),
                    const SizedBox(height: GenieSpace.xxs + 2),
                    Semantics(header: true, child: Text(item.name, style: text.headlineMedium)),
                  ],
                ),
              ),
              const InfoChip(label: 'True scale', icon: GenieIcons.trueScale, accent: true),
            ],
          ),
          const SizedBox(height: GenieSpace.xs + 2),
          Text(item.description, style: text.bodyLarge),
          const SizedBox(height: GenieSpace.md),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Fabric', style: text.titleSmall),
                      TextSpan(text: ' · ${fabric.name}', style: text.bodyMedium),
                    ],
                  ),
                  // Wraps rather than hide the fabric name (the swatches
                  // keep their 48pt targets).
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SwatchPicker(fabrics: item.fabrics, selected: fabric, size: 26, spacing: 0, onChanged: onFabric),
            ],
          ),
          const SizedBox(height: GenieSpace.sm),
          Row(
            children: [
              Expanded(child: StatCell(label: 'Width', value: units.format(d.width))),
              const SizedBox(width: GenieSpace.xs),
              Expanded(child: StatCell(label: 'Depth', value: units.format(d.depth))),
              const SizedBox(width: GenieSpace.xs),
              Expanded(child: StatCell(label: 'Height', value: units.format(d.height))),
            ],
          ),
          const SizedBox(height: GenieSpace.md),
          PrimaryButton(label: 'Place in my room', leadingIcon: GenieIcons.place, expand: true, onPressed: onPlace),
        ],
      ),
    );
  }
}

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data/catalog_repository.dart';
import '../../core/data/settings_controller.dart';
import '../../core/models/furniture_item.dart';
import '../../core/models/placed_piece.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// Opens the furniture sheet over the camera. Resolves with the piece placed
/// from the detail screen, if any.
Future<PlacedPiece?> showCatalogSheet(BuildContext context) {
  return Navigator.of(context).push<PlacedPiece>(_SheetRoute());
}

class _SheetRoute extends PopupRoute<PlacedPiece> {
  @override
  Color? get barrierColor => null; // the sheet draws its own dim + blur

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'Close furniture';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 420);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 280);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      CatalogSheet(route: animation);
}

/// Snap point: the sheet opens to about 86% of the screen.
const double _open = 0.86;

/// "Add to your room": draggable, snaps open or away on a fling, and the
/// camera behind it dims and blurs in step with how far it is open.
class CatalogSheet extends ConsumerStatefulWidget {
  const CatalogSheet({super.key, required this.route});

  final Animation<double> route;

  @override
  ConsumerState<CatalogSheet> createState() => _CatalogSheetState();
}

class _CatalogSheetState extends ConsumerState<CatalogSheet> {
  final _sheet = DraggableScrollableController();
  final _extent = ValueNotifier<double>(_open);
  final _search = TextEditingController();
  String _query = '';
  String? _category;
  String? _collection;
  bool _closing = false;

  @override
  void dispose() {
    _sheet.dispose();
    _extent.dispose();
    _search.dispose();
    super.dispose();
  }

  void _close([PlacedPiece? result]) {
    if (_closing) return;
    _closing = true;
    Navigator.of(context).pop(result);
  }

  Future<void> _openPiece(FurnitureItem item) async {
    FocusScope.of(context).unfocus();
    final placed = await context.push<PlacedPiece>(Routes.piece(item.id));
    if (placed != null && mounted) _close(placed);
  }

  bool _onExtent(DraggableScrollableNotification n) {
    _extent.value = n.extent;
    // Dragged or flung all the way down: dismiss.
    if (n.extent <= 0.02) WidgetsBinding.instance.addPostFrameCallback((_) => _close());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: widget.route, curve: GenieMotion.drawer, reverseCurve: GenieMotion.easeOut);
    return Stack(
      children: [
        // Camera behind: dim + blur tied to the route and the drag.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: AnimatedBuilder(
              animation: Listenable.merge([curve, _extent]),
              builder: (context, _) {
                final p = (curve.value * (_extent.value / _open)).clamp(0.0, 1.0);
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14 * p, sigmaY: 14 * p),
                  child: ColoredBox(color: GenieColors.scrim.withValues(alpha: 0.28 * p)),
                );
              },
            ),
          ),
        ),
        SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(curve),
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: _onExtent,
            child: DraggableScrollableSheet(
              controller: _sheet,
              initialChildSize: _open,
              minChildSize: 0,
              maxChildSize: _open,
              snap: true,
              snapAnimationDuration: const Duration(milliseconds: 320),
              builder:
                  (context, scroll) => _SheetBody(
                    scroll: scroll,
                    search: _search,
                    query: _query,
                    category: _category,
                    collection: _collection,
                    onQuery: (q) => setState(() => _query = q.trim()),
                    onCategory:
                        (c) => setState(() {
                          _category = _category == c ? null : c;
                          _collection = null;
                        }),
                    onCollection:
                        (c) => setState(() {
                          _collection = _collection == c ? null : c;
                          _category = null;
                        }),
                    onClearFilters:
                        () => setState(() {
                          _category = null;
                          _collection = null;
                          _query = '';
                          _search.clear();
                        }),
                    onOpen: _openPiece,
                    onClose: _close,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetBody extends ConsumerWidget {
  const _SheetBody({
    required this.scroll,
    required this.search,
    required this.query,
    required this.category,
    required this.collection,
    required this.onQuery,
    required this.onCategory,
    required this.onCollection,
    required this.onClearFilters,
    required this.onOpen,
    required this.onClose,
  });

  final ScrollController scroll;
  final TextEditingController search;
  final String query;
  final String? category;
  final String? collection;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onCategory;
  final ValueChanged<String> onCollection;
  final VoidCallback onClearFilters;
  final ValueChanged<FurnitureItem> onOpen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final catalog = ref.watch(catalogProvider);
    final units = ref.watch(unitsProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: GenieColors.bg,
      shape: const RoundedRectangleBorder(borderRadius: GenieRadii.sheetTop),
      clipBehavior: Clip.antiAlias,
      child: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator(color: GenieColors.teal, strokeWidth: 2.4)),
        error: (e, _) => Center(child: Text("Couldn't load the catalog.", style: text.bodyLarge)),
        data: (cat) {
          final q = query.toLowerCase();
          final inCollection = collection == null ? null : cat.collections.firstWhere((c) => c.id == collection);
          final items = [
            for (final i in cat.items)
              if ((q.isEmpty ||
                      i.name.toLowerCase().contains(q) ||
                      cat.categoryName(i.categoryId).toLowerCase().contains(q)) &&
                  (category == null || i.categoryId == category) &&
                  (inCollection == null || inCollection.itemIds.contains(i.id)))
                i,
          ];
          final filterLabel = inCollection?.name ?? (category != null ? cat.categoryName(category!) : null);

          return CustomScrollView(
            controller: scroll,
            slivers: [
              // Handle (part of the drag area).
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: GenieSpace.xs + 2, bottom: GenieSpace.xs),
                    width: 40,
                    height: 4.5,
                    decoration: const BoxDecoration(color: GenieColors.dotInactive, borderRadius: GenieRadii.pillAll),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(GenieSpace.lg, GenieSpace.xs, GenieSpace.lg, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(header: true, child: Text('Add to your room', style: text.headlineSmall)),
                      ),
                      IconCircleButton(icon: GenieIcons.close, semanticLabel: 'Close', size: 46, onPressed: onClose),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(GenieSpace.lg, GenieSpace.sm, GenieSpace.lg, 0),
                sliver: SliverToBoxAdapter(child: _SearchField(controller: search, onChanged: onQuery)),
              ),
              if (q.isEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(GenieSpace.lg, GenieSpace.sm, GenieSpace.sm, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(child: Semantics(header: true, child: Text('Collections', style: text.titleLarge))),
                        QuietButton(label: 'See all', color: GenieColors.teal, onPressed: onClearFilters),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: GenieSpace.lg),
                      itemCount: cat.collections.length,
                      separatorBuilder: (_, _) => const SizedBox(width: GenieSpace.sm),
                      itemBuilder: (context, i) {
                        final c = cat.collections[i];
                        return CollectionCard(
                          name: c.name,
                          pieceCount: c.itemIds.length,
                          image: AssetImage(c.image),
                          width: 250,
                          height: 130,
                          onTap: () => onCollection(c.id),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 92,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(GenieSpace.sm + 2, GenieSpace.sm, GenieSpace.sm + 2, 0),
                      children: [
                        for (final c in cat.categories)
                          CategoryTile(
                            icon: CategoryGlyph(c.id),
                            label: c.name,
                            selected: category == c.id,
                            onTap: () => onCategory(c.id),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              if (filterLabel != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(GenieSpace.lg, GenieSpace.xs, GenieSpace.sm, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(filterLabel, style: text.titleMedium),
                        const SizedBox(width: GenieSpace.xs),
                        Text('· ${items.length}', style: text.bodyMedium),
                        const Spacer(),
                        QuietButton(label: 'Show all', color: GenieColors.teal, onPressed: onClearFilters),
                      ],
                    ),
                  ),
                ),
              if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(GenieSpace.gutter, GenieSpace.xxl, GenieSpace.gutter, 0),
                    child: Column(
                      children: [
                        Text('Nothing matches “$query”.', style: text.titleMedium, textAlign: TextAlign.center),
                        const SizedBox(height: GenieSpace.xxs),
                        Text(
                          'Try a shorter word, like “chair” or “lamp”.',
                          style: text.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: GenieSpace.sm),
                        QuietButton(label: 'Clear search', color: GenieColors.teal, onPressed: onClearFilters),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(GenieSpace.lg, GenieSpace.xs, GenieSpace.lg, bottom + GenieSpace.xxl),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: GenieSpace.sm,
                      crossAxisSpacing: GenieSpace.sm,
                      childAspectRatio: 169 / 212,
                    ),
                    delegate: SliverChildBuilderDelegate(childCount: items.length, (context, i) {
                      final item = items[i];
                      final img = item.imageFor(item.defaultFabric);
                      return ProductCard(
                        name: item.name,
                        dimensions: units.formatPair(item.dimensions.width, item.dimensions.depth),
                        image: img == null ? null : AssetImage(img),
                        isNew: item.isNew,
                        heroTag: item.heroTag,
                        fallback: CategoryGlyph(item.categoryId),
                        on3dTap: () => onOpen(item),
                        onTap: () => onOpen(item),
                      );
                    }),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(borderRadius: GenieRadii.chipAll, boxShadow: GenieShadows.card),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: text.bodyLarge!.copyWith(color: GenieColors.ink),
        decoration: InputDecoration(
          fillColor: GenieColors.card,
          hintText: 'Search chairs, sofas, lamps…',
          prefixIcon: const Icon(GenieIcons.search, size: 20, color: GenieColors.ink3),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder:
                (context, v, _) =>
                    v.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(GenieIcons.close, size: 18, color: GenieColors.ink3),
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          },
                        ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/catalog_repository.dart';
import '../../core/data/room_controller.dart';
import '../../core/models/placed_piece.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// Designs saved with the shutter on Home.
class SavedDesignsScreen extends ConsumerWidget {
  const SavedDesignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designs = ref.watch(savedDesignsProvider);
    final catalog = ref.watch(catalogProvider).value;
    final text = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          GenieSpace.groupInset,
          mq.padding.top + GenieSpace.xs,
          GenieSpace.groupInset,
          mq.padding.bottom + GenieSpace.xl,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconCircleButton(
              icon: GenieIcons.back,
              semanticLabel: 'Back',
              size: 46,
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(height: GenieSpace.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GenieSpace.xxs),
            child: Semantics(header: true, child: Text('Saved designs', style: text.displayMedium)),
          ),
          const SizedBox(height: GenieSpace.xl),
          if (designs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GenieSpace.xxs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nothing saved yet', style: text.titleLarge),
                  const SizedBox(height: GenieSpace.xs),
                  Text(
                    'Place a piece in your room, then tap the white shutter on the camera to keep the design.',
                    style: text.bodyLarge,
                  ),
                ],
              ),
            )
          else
            SettingsGroup(
              children: [
                for (final d in designs)
                  SettingsRow(
                    title: _title(d, catalog?.item(d.pieces.first.itemId)?.name),
                    subtitle: _date(d.createdAt),
                    icon: GenieIcons.savedDesigns,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static String _title(SavedDesign d, String? first) {
    final n = d.pieces.length;
    if (first == null) return n == 1 ? '1 piece' : '$n pieces';
    return n == 1 ? first : '$first + ${n - 1} more';
  }

  static String _date(DateTime t) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.day} ${months[t.month - 1]} · $hh:$mm';
  }
}

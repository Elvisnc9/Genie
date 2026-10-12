import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/settings_controller.dart';
import '../../core/feedback/haptics.dart';
import '../../core/models/fabric.dart';
import '../../core/models/units.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// Phase 1 preview of every core component, with live state, so the system
/// can be reviewed on a device before screens are built from it.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  // Sample data from the mockups (Lune armchair).
  static const _fabrics = [
    Fabric(id: 'oat', name: 'Oat bouclé', color: Color(0xFFE6DCCB)),
    Fabric(id: 'terracotta', name: 'Terracotta bouclé', color: Color(0xFFC8693F)),
    Fabric(id: 'sage', name: 'Sage linen', color: Color(0xFF8E9E80)),
    Fabric(id: 'navy', name: 'Navy velvet', color: Color(0xFF2E3748)),
  ];
  static const _room = AssetImage(GenieArt.homeRoom);
  static const _room2 = AssetImage('assets/images/collection_reading_corner.jpg');

  Fabric _fabric = _fabrics[1];
  bool _ai = false;
  bool _aiSuggestions = true;
  bool _floorGrid = true;
  Units _units = Units.cm;
  double _page = 0;
  int _category = 0;
  bool _busy = false;

  static const _categories = [
    ('armchairs', 'Armchairs'),
    ('sofas', 'Sofas'),
    ('chairs', 'Chairs'),
    ('tables', 'Tables'),
    ('lighting', 'Lighting'),
    ('plants', 'Plants'),
  ];

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 1200)));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final haptics = ref.watch(hapticsEnabledProvider);
    final pad = MediaQuery.paddingOf(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          GenieSpace.groupInset,
          pad.top + GenieSpace.lg,
          GenieSpace.groupInset,
          pad.bottom + GenieSpace.xxxl,
        ),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: GenieSpace.xxs),
            child: Row(children: [Wordmark(), Spacer(), InfoChip(label: 'Phase 1', accent: true)]),
          ),
          const SizedBox(height: GenieSpace.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GenieSpace.xxs),
            child: Text('Components', style: text.displayMedium),
          ),
          const SizedBox(height: GenieSpace.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GenieSpace.xxs),
            child: Text('Every core piece of Genie, live. Tap things.', style: text.bodyLarge),
          ),

          _Section(
            'Type',
            children: [
              Text('Design the room\nyou\'re standing in.', style: text.displayLarge),
              const SizedBox(height: GenieSpace.sm),
              Text('Settings', style: text.displayMedium),
              const SizedBox(height: GenieSpace.sm),
              Text('Lune armchair', style: text.headlineMedium),
              Text('Add to your room', style: text.headlineSmall),
              const SizedBox(height: GenieSpace.sm),
              Text('Floor grid', style: text.titleMedium),
              Text(
                'Point your camera at any space and drop in true-to-size furniture. Walk around it like it\'s already yours.',
                style: text.bodyLarge,
              ),
              const SizedBox(height: GenieSpace.xs),
              Text('Terracotta · 80 × 74 cm', style: text.bodySmall),
              const SizedBox(height: GenieSpace.sm),
              const Eyebrow('Designing'),
            ],
          ),

          const _Section(
            'Colour',
            children: [
              Wrap(
                spacing: GenieSpace.xs,
                runSpacing: GenieSpace.xs,
                children: [
                  _Chip('bg', GenieColors.bg),
                  _Chip('card', GenieColors.card),
                  _Chip('tile', GenieColors.tileBg),
                  _Chip('line', GenieColors.line),
                  _Chip('ink', GenieColors.ink),
                  _Chip('ink2', GenieColors.ink2),
                  _Chip('ink3', GenieColors.ink3),
                  _Chip('teal', GenieColors.teal),
                  _Chip('tealDark', GenieColors.tealDark),
                  _Chip('tealSoft', GenieColors.tealSoft),
                  _Chip('danger', GenieColors.danger),
                  _Chip('dangerSoft', GenieColors.dangerSoft),
                ],
              ),
            ],
          ),

          _Section(
            'Buttons',
            children: [
              Row(
                children: [
                  PrimaryButton(label: 'Next', trailingIcon: GenieIcons.next, onPressed: () => _toast('Next')),
                  const Spacer(),
                  QuietButton(label: 'Skip', onPressed: () => _toast('Skip')),
                ],
              ),
              const SizedBox(height: GenieSpace.md),
              PrimaryButton(
                label: 'Allow camera',
                expand: true,
                busy: _busy,
                onPressed: () async {
                  setState(() => _busy = true);
                  await Future<void>.delayed(const Duration(milliseconds: 1200));
                  if (mounted) setState(() => _busy = false);
                },
              ),
              const SizedBox(height: GenieSpace.sm),
              PrimaryButton(
                label: 'Place in my room',
                leadingIcon: GenieIcons.place,
                expand: true,
                onPressed: () => _toast('Placed'),
              ),
              const SizedBox(height: GenieSpace.sm),
              const PrimaryButton(label: 'Disabled', expand: true, onPressed: null),
              const SizedBox(height: GenieSpace.xs),
              Center(child: QuietButton(label: 'Not now', onPressed: () => _toast('Not now'))),
              const SizedBox(height: GenieSpace.md),
              Row(
                children: [
                  IconCircleButton(icon: GenieIcons.back, semanticLabel: 'Back', onPressed: () => _toast('Back')),
                  const Spacer(),
                  IconCircleButton(icon: GenieIcons.share, semanticLabel: 'Share', onPressed: () => _toast('Share')),
                  const SizedBox(width: GenieSpace.sm),
                  IconCircleButton(
                    icon: GenieIcons.favourite,
                    semanticLabel: 'Save to favourites',
                    onPressed: () => _toast('Saved'),
                  ),
                ],
              ),
            ],
          ),

          _Section(
            'Over the camera',
            children: [
              ClipRRect(
                borderRadius: GenieRadii.cardAll,
                child: SizedBox(
                  height: 420,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const Image(image: _room, fit: BoxFit.cover),
                      Positioned(
                        left: GenieSpace.md,
                        right: GenieSpace.md,
                        top: GenieSpace.md,
                        child: Row(
                          children: [
                            IconCircleButton(
                              icon: GenieIcons.settings,
                              semanticLabel: 'Settings',
                              style: IconCircleStyle.glass,
                              onPressed: () => _toast('Settings'),
                            ),
                            const Spacer(),
                            AiSwitch(value: _ai, onChanged: (v) => setState(() => _ai = v)),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: 84,
                        left: 0,
                        right: 0,
                        child: Center(child: StatusChip(label: 'Floor found · tap + to add a piece')),
                      ),
                      Positioned(
                        left: GenieSpace.lg,
                        right: GenieSpace.lg,
                        bottom: GenieSpace.lg,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: GenieSizes.shutter,
                              child: Wordmark(width: 52, tone: WordmarkTone.white),
                            ),
                            AddButton(onPressed: () => _toast('Open furniture sheet')),
                            ShutterButton(onPressed: () => _toast('Snap')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          _Section(
            'Toggles',
            children: [
              Row(
                children: [
                  GenieToggle(
                    value: _aiSuggestions,
                    semanticLabel: 'AI suggestions',
                    onChanged: (v) => setState(() => _aiSuggestions = v),
                  ),
                  const SizedBox(width: GenieSpace.md),
                  GenieToggle(
                    value: !_aiSuggestions,
                    semanticLabel: 'Inverse',
                    onChanged: (v) => setState(() => _aiSuggestions = !v),
                  ),
                  const Spacer(),
                  SegmentedUnits(value: _units, onChanged: (u) => setState(() => _units = u)),
                ],
              ),
            ],
          ),

          _Section(
            'Page dots',
            children: [
              PageDots(count: 4, page: _page),
              Slider(
                value: _page,
                max: 3,
                activeColor: GenieColors.teal,
                inactiveColor: GenieColors.line,
                onChanged: (v) => setState(() => _page = v),
              ),
              Text('Drag to scrub: the pill follows the pager offset, not a timer.', style: text.bodySmall),
            ],
          ),

          _Section(
            'Swatches',
            children: [
              SwatchPicker(fabrics: _fabrics, selected: _fabric, onChanged: (f) => setState(() => _fabric = f)),
              const SizedBox(height: GenieSpace.xs),
              Text('Fabric · ${_fabric.name}', style: text.bodyMedium),
            ],
          ),

          _Section(
            'Catalog',
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    for (var i = 0; i < _categories.length; i++)
                      CategoryTile(
                        icon: CategoryGlyph(_categories[i].$1),
                        label: _categories[i].$2,
                        selected: i == _category,
                        onTap: () => setState(() => _category = i),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: GenieSpace.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    CollectionCard(
                      name: 'Living room',
                      pieceCount: 24,
                      image: _room,
                      onTap: () => _toast('Living room'),
                    ),
                    const SizedBox(width: GenieSpace.sm),
                    CollectionCard(
                      name: 'Reading corner',
                      pieceCount: 9,
                      image: _room2,
                      onTap: () => _toast('Reading corner'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GenieSpace.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ProductCard(
                      name: 'Lune armchair',
                      dimensions: '${_units.format(80)} × ${_units.format(74)}'
                          .replaceAll(' cm ×', ' ×')
                          .replaceAll(' in ×', ' ×'),
                      isNew: true,
                      on3dTap: () => _toast('3D'),
                      onTap: () => _toast('Lune armchair'),
                    ),
                  ),
                  const SizedBox(width: GenieSpace.sm),
                  Expanded(
                    child: ProductCard(
                      name: 'Nord dining chair',
                      dimensions: '${_units.format(48)} × ${_units.format(46)}'
                          .replaceAll(' cm ×', ' ×')
                          .replaceAll(' in ×', ' ×'),
                      fallback: const CategoryGlyph('chairs'),
                      on3dTap: () => _toast('3D'),
                      onTap: () => _toast('Nord dining chair'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GenieSpace.md),
              Row(
                children: [
                  Expanded(child: StatCell(label: 'Width', value: _units.format(80))),
                  const SizedBox(width: GenieSpace.xs),
                  Expanded(child: StatCell(label: 'Depth', value: _units.format(74))),
                  const SizedBox(width: GenieSpace.xs),
                  Expanded(child: StatCell(label: 'Height', value: _units.format(82))),
                ],
              ),
              const SizedBox(height: GenieSpace.md),
              const Wrap(
                spacing: GenieSpace.xs,
                runSpacing: GenieSpace.xs,
                children: [
                  InfoChip(label: 'True scale', icon: GenieIcons.trueScale, accent: true),
                  InfoChip(label: '360°', icon: GenieIcons.spin),
                  InfoChip(label: '80 cm'),
                  NewBadge(),
                ],
              ),
            ],
          ),

          _Section(
            'Settings',
            children: [
              SettingsGroup(
                title: 'Designing',
                children: [
                  SettingsRow(
                    title: 'AI suggestions',
                    subtitle: 'Show the AI switch on camera',
                    leading: const SparkleWellGlyph(),
                    tone: SettingsTone.accent,
                    toggled: _aiSuggestions,
                    trailing: GenieToggle(value: _aiSuggestions, onChanged: null),
                    onTap: () => setState(() => _aiSuggestions = !_aiSuggestions),
                  ),
                  SettingsRow(
                    title: 'Floor grid',
                    subtitle: 'Dots where Genie sees the floor',
                    icon: GenieIcons.floorGrid,
                    toggled: _floorGrid,
                    trailing: GenieToggle(value: _floorGrid, onChanged: null),
                    onTap: () => setState(() => _floorGrid = !_floorGrid),
                  ),
                  SettingsRow(
                    title: 'Units',
                    icon: GenieIcons.units,
                    trailing: SegmentedUnits(value: _units, onChanged: (u) => setState(() => _units = u)),
                  ),
                  SettingsRow(
                    title: 'Haptics',
                    subtitle: 'A soft tap when a piece lands',
                    icon: GenieIcons.haptics,
                    toggled: haptics,
                    trailing: GenieToggle(value: haptics, onChanged: null),
                    onTap: () => ref.read(settingsProvider.notifier).setHaptics(!haptics),
                  ),
                ],
              ),
              const SizedBox(height: GenieSpace.xl),
              SettingsGroup(
                title: 'Your designs',
                children: [
                  SettingsRow(
                    title: 'Saved designs',
                    icon: GenieIcons.savedDesigns,
                    chevron: true,
                    onTap: () => _toast('Saved designs'),
                  ),
                  SettingsRow(
                    title: 'Clear saved designs',
                    icon: GenieIcons.clear,
                    tone: SettingsTone.danger,
                    onTap: () => _toast('Confirmation comes in Phase 5'),
                  ),
                ],
              ),
              const SizedBox(height: GenieSpace.xxxl),
              const Center(child: Wordmark(width: GenieSizes.wordmarkFooter)),
              const SizedBox(height: GenieSpace.xxs),
              Center(child: Text('Version 1.0', style: text.bodySmall)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, {required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: GenieSpace.xxl + GenieSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: GenieSpace.xxs, bottom: GenieSpace.md),
            child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: GenieRadii.iconWellAll,
            border: Border.all(color: GenieColors.line),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11)),
      ],
    );
  }
}

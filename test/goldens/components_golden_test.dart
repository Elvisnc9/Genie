import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genie/core/models/fabric.dart';
import 'package:genie/core/models/units.dart';
import 'package:genie/core/theme/theme.dart';
import 'package:genie/core/widgets/widgets.dart';

import '../helpers/harness.dart';

/// Goldens for the core widgets, rendered with the real fonts.
/// Regenerate with: flutter test --update-goldens test/goldens
/// Generated on Windows; font rasterisation differs slightly per OS.
void main() {
  setUpAll(loadGenieFonts);

  Future<void> shoot(WidgetTester tester, String name, Widget child, {Size size = const Size(390, 260)}) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      harness(
        RepaintBoundary(
          key: const ValueKey('golden'),
          child: Container(
            color: GenieColors.bg,
            width: size.width,
            padding: const EdgeInsets.all(GenieSpace.lg),
            child: child,
          ),
        ),
      ),
    );
    // flutter_test draws shadows as hard bands by default; render them for
    // real, then restore the flag before the test's invariant check.
    debugDisableShadows = false;
    try {
      await tester.pumpAndSettle();
      await expectLater(find.byKey(const ValueKey('golden')), matchesGoldenFile('goldens/$name.png'));
    } finally {
      debugDisableShadows = true;
    }
  }

  testWidgets('buttons and toggles', (tester) async {
    await shoot(
      tester,
      'buttons',
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              PrimaryButton(label: 'Next', trailingIcon: GenieIcons.next, onPressed: () {}),
              const Spacer(),
              QuietButton(label: 'Skip', onPressed: () {}),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Place in my room', leadingIcon: GenieIcons.place, expand: true, onPressed: () {}),
          const SizedBox(height: 12),
          Row(
            children: [
              IconCircleButton(icon: GenieIcons.back, semanticLabel: 'Back', onPressed: () {}),
              const Spacer(),
              GenieToggle(value: true, semanticLabel: 'On', onChanged: (_) {}),
              const SizedBox(width: 12),
              GenieToggle(value: false, semanticLabel: 'Off', onChanged: (_) {}),
            ],
          ),
        ],
      ),
    );
  });

  testWidgets('settings group', (tester) async {
    await shoot(
      tester,
      'settings_group',
      SettingsGroup(
        title: 'Designing',
        children: [
          SettingsRow(
            title: 'AI suggestions',
            subtitle: 'Show the AI switch on camera',
            leading: const SparkleWellGlyph(),
            tone: SettingsTone.accent,
            trailing: const GenieToggle(value: true, onChanged: null),
            onTap: () {},
          ),
          SettingsRow(
            title: 'Units',
            icon: GenieIcons.units,
            trailing: SegmentedUnits(value: Units.cm, onChanged: (_) {}),
          ),
          SettingsRow(title: 'Clear saved designs', icon: GenieIcons.clear, tone: SettingsTone.danger, onTap: () {}),
        ],
      ),
      size: const Size(390, 300),
    );
  });

  testWidgets('catalog pieces', (tester) async {
    const fabrics = [
      Fabric(id: 'oat', name: 'Oat', color: Color(0xFFE6DCCB)),
      Fabric(id: 'terracotta', name: 'Terracotta', color: Color(0xFFC8693F)),
      Fabric(id: 'sage', name: 'Sage', color: Color(0xFF8E9E80)),
    ];
    await shoot(
      tester,
      'catalog',
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryTile(icon: const CategoryGlyph('armchairs'), label: 'Armchairs', selected: true, onTap: () {}),
              CategoryTile(icon: const CategoryGlyph('sofas'), label: 'Sofas', selected: false, onTap: () {}),
              const Spacer(),
              SwatchPicker(fabrics: fabrics, selected: fabrics[1], onChanged: (_) {}),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProductCard(
                  name: 'Lune armchair',
                  dimensions: '80 × 74 cm',
                  isNew: true,
                  on3dTap: () {},
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  children: [
                    StatCell(label: 'Width', value: '80 cm'),
                    SizedBox(height: 16),
                    PageDots(count: 4, page: 1),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      size: const Size(390, 380),
    );
  });
}

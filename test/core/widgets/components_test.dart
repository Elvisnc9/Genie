import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genie/core/models/fabric.dart';
import 'package:genie/core/models/units.dart';
import 'package:genie/core/theme/theme.dart';
import 'package:genie/core/widgets/widgets.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('PrimaryButton fires and is at least 56 tall', (tester) async {
    var taps = 0;
    await tester.pumpWidget(harness(PrimaryButton(label: 'Next', onPressed: () => taps++)));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.getSize(find.byType(PrimaryButton)).height, greaterThanOrEqualTo(GenieSizes.buttonHeight));
  });

  testWidgets('disabled and busy PrimaryButtons do not fire', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PrimaryButton(label: 'Off', onPressed: null),
            PrimaryButton(label: 'Busy', busy: true, onPressed: () => taps++),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(PrimaryButton).first, warnIfMissed: false);
    await tester.tap(find.byType(PrimaryButton).last, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    expect(taps, 0);
  });

  testWidgets('GenieToggle flips and reports toggled semantics', (tester) async {
    final handle = tester.ensureSemantics();
    var value = false;
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder:
              (context, setState) =>
                  GenieToggle(value: value, semanticLabel: 'Haptics', onChanged: (v) => setState(() => value = v)),
        ),
      ),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Haptics'));
    expect(node.flagsCollection.isToggled, Tristate.isFalse);
    await tester.tap(find.byType(GenieToggle));
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(tester.getSemantics(find.bySemanticsLabel('Haptics')).flagsCollection.isToggled, Tristate.isTrue);
    handle.dispose();
  });

  testWidgets('GenieToggle hit area is at least 48 square', (tester) async {
    await tester.pumpWidget(harness(GenieToggle(value: false, semanticLabel: 'x', onChanged: (_) {})));
    final size = tester.getSize(find.byType(Pressable));
    expect(size.height, greaterThanOrEqualTo(GenieSizes.minTouch));
    expect(size.width, greaterThanOrEqualTo(GenieSizes.minTouch));
  });

  testWidgets('SegmentedUnits switches to inches and keeps a 48 target', (tester) async {
    var units = Units.cm;
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder: (context, setState) => SegmentedUnits(value: units, onChanged: (u) => setState(() => units = u)),
        ),
      ),
    );
    await tester.tap(find.text('in'));
    await tester.pumpAndSettle();
    expect(units, Units.inches);
    expect(tester.getSize(find.byType(SegmentedUnits)).height, GenieSizes.minTouch);
  });

  testWidgets('SwatchPicker selects a fabric', (tester) async {
    const fabrics = [
      Fabric(id: 'a', name: 'Oat', color: Color(0xFFE6DCCB)),
      Fabric(id: 'b', name: 'Sage', color: Color(0xFF8E9E80)),
    ];
    var selected = fabrics.first;
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder:
              (context, setState) =>
                  SwatchPicker(fabrics: fabrics, selected: selected, onChanged: (f) => setState(() => selected = f)),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Sage'));
    await tester.pumpAndSettle();
    expect(selected.id, 'b');
  });

  testWidgets('PageDots announces the current page', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harness(const PageDots(count: 4, page: 1.4)));
    expect(find.bySemanticsLabel('Page 2 of 4'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a toggle settings row toggles from anywhere on the row', (tester) async {
    var on = false;
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder:
              (context, setState) => SettingsGroup(
                children: [
                  SettingsRow(
                    title: 'Floor grid',
                    subtitle: 'Dots where Genie sees the floor',
                    icon: GenieIcons.floorGrid,
                    toggled: on,
                    trailing: GenieToggle(value: on, onChanged: null),
                    onTap: () => setState(() => on = !on),
                  ),
                ],
              ),
        ),
      ),
    );
    await tester.tap(find.text('Dots where Genie sees the floor'));
    await tester.pumpAndSettle();
    expect(on, isTrue);
  });

  testWidgets('with reduce motion, press feedback jumps instead of springing', (tester) async {
    await tester.pumpWidget(harness(PrimaryButton(label: 'Go', onPressed: () {}), reduceMotion: true));
    final gesture = await tester.startGesture(tester.getCenter(find.text('Go')));
    await tester.pump(const Duration(milliseconds: 16));
    final scale = tester.widget<ScaleTransition>(
      find.descendant(of: find.byType(PrimaryButton), matching: find.byType(ScaleTransition)),
    );
    expect(scale.scale.value, GenieMotion.pressScale);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('icon-only buttons carry a label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harness(IconCircleButton(icon: GenieIcons.back, semanticLabel: 'Back', onPressed: () {})));
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    handle.dispose();
  });
}

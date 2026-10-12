import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genie/core/data/catalog_repository.dart';
import 'package:genie/core/data/preferences.dart';
import 'package:genie/core/data/room_controller.dart';
import 'package:genie/core/data/settings_controller.dart';
import 'package:genie/core/models/units.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> containerWith(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(p)]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('catalog', () {
    final catalog = CatalogRepository.parse(File('assets/data/catalog.json').readAsStringSync());

    test('parses every piece from the seed file', () {
      expect(catalog.items.map((i) => i.id), containsAll(['lune-armchair', 'nord-dining-chair', 'arc-floor-lamp']));
      expect(catalog.categories, hasLength(6));
    });

    test('Lune matches the mockup: 80 × 74 × 82, terracotta by default, four fabrics', () {
      final lune = catalog.item('lune-armchair')!;
      expect([lune.dimensions.width, lune.dimensions.depth, lune.dimensions.height], [80, 74, 82]);
      expect(lune.defaultFabric.id, 'terracotta');
      expect(lune.fabrics, hasLength(4));
      expect(lune.isNew, isTrue);
    });

    test('every collection points at real pieces and every image asset exists', () {
      for (final c in catalog.collections) {
        for (final id in c.itemIds) {
          expect(catalog.item(id), isNotNull, reason: '${c.id} → $id');
        }
        expect(File(c.image).existsSync(), isTrue, reason: c.image);
      }
      for (final i in catalog.items) {
        for (final f in i.fabrics) {
          if (f.image != null) expect(File(f.image!).existsSync(), isTrue, reason: f.image);
        }
      }
    });

    test('every 3D model exists and carries a true-scale factor', () {
      final withModels = catalog.items.where((i) => i.model != null).toList();
      expect(withModels.map((i) => i.id), containsAll(['lune-armchair', 'haven-sofa']));
      for (final i in withModels) {
        expect(File(i.model!).existsSync(), isTrue, reason: i.model);
        expect(i.modelScale, inInclusiveRange(0.5, 2.0), reason: '${i.id} scale');
      }
    });

    test('a fabric without its own render falls back to the default render', () {
      final nord = catalog.item('nord-dining-chair')!;
      expect(nord.imageFor(nord.fabric('charcoal')), nord.defaultFabric.image);
    });
  });

  group('settings', () {
    test('defaults match the settings mockup', () async {
      final c = await containerWith({});
      final s = c.read(settingsProvider);
      expect(s.aiSuggestions, isTrue);
      expect(s.floorGrid, isTrue);
      expect(s.units, Units.cm);
      expect(s.haptics, isFalse);
    });

    test('changes persist and are read back', () async {
      final c = await containerWith({});
      c.read(settingsProvider.notifier)
        ..setUnits(Units.inches)
        ..setFloorGrid(false);
      final prefs = c.read(sharedPreferencesProvider);
      expect(prefs.getString(PrefKeys.units), 'inches');

      final fresh = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
      addTearDown(fresh.dispose);
      expect(fresh.read(settingsProvider).units, Units.inches);
      expect(fresh.read(settingsProvider).floorGrid, isFalse);
    });
  });

  group('onboarding flag', () {
    test('starts false and persists', () async {
      final c = await containerWith({});
      expect(c.read(onboardingDoneProvider), isFalse);
      await c.read(onboardingDoneProvider.notifier).set(true);
      expect(c.read(sharedPreferencesProvider).getBool(PrefKeys.onboardingDone), isTrue);
    });
  });

  group('room', () {
    test('placing pieces gives each its own slot; saving and clearing designs persists', () async {
      final c = await containerWith({});
      final room = c.read(placedPiecesProvider.notifier);
      room.place('lune-armchair', 'sage');
      room.place('arc-floor-lamp', 'brass');
      expect(c.read(placedPiecesProvider).map((p) => p.slot), [0, 1]);

      c.read(savedDesignsProvider.notifier).save(c.read(placedPiecesProvider));
      final prefs = c.read(sharedPreferencesProvider);
      final fresh = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
      addTearDown(fresh.dispose);
      expect(fresh.read(savedDesignsProvider).single.pieces.first.fabricId, 'sage');

      fresh.read(savedDesignsProvider.notifier).clear();
      expect(fresh.read(savedDesignsProvider), isEmpty);
    });
  });
}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/furniture_item.dart';

/// Loads the local catalog shipped in assets/data/catalog.json.
class CatalogRepository {
  CatalogRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  static const path = 'assets/data/catalog.json';

  Future<Catalog> load() async => parse(await _bundle.loadString(path));

  static Catalog parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return Catalog(
      categories: [for (final c in json['categories'] as List) FurnitureCategory.fromJson(c as Map<String, dynamic>)],
      collections: [for (final c in json['collections'] as List) Collection.fromJson(c as Map<String, dynamic>)],
      items: [for (final i in json['items'] as List) FurnitureItem.fromJson(i as Map<String, dynamic>)],
    );
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => CatalogRepository());

final catalogProvider = FutureProvider<Catalog>((ref) => ref.watch(catalogRepositoryProvider).load());

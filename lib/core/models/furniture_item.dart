import 'fabric.dart';

/// Real-world size in centimetres.
class Dimensions {
  const Dimensions({required this.width, required this.depth, required this.height});

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
    width: (json['width'] as num).toDouble(),
    depth: (json['depth'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
  );

  final double width;
  final double depth;
  final double height;
}

class FurnitureCategory {
  const FurnitureCategory({required this.id, required this.name});

  factory FurnitureCategory.fromJson(Map<String, dynamic> json) =>
      FurnitureCategory(id: json['id'] as String, name: json['name'] as String);

  final String id;
  final String name;
}

class FurnitureItem {
  const FurnitureItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.dimensions,
    required this.fabrics,
    required this.defaultFabricId,
    this.isNew = false,
    this.model,
    this.modelScale = 1,
  });

  factory FurnitureItem.fromJson(Map<String, dynamic> json) => FurnitureItem(
    id: json['id'] as String,
    name: json['name'] as String,
    categoryId: json['category'] as String,
    description: json['description'] as String,
    dimensions: Dimensions.fromJson(json['dimensions'] as Map<String, dynamic>),
    fabrics: [for (final f in json['fabrics'] as List) Fabric.fromJson(f as Map<String, dynamic>)],
    defaultFabricId: json['defaultFabric'] as String,
    isNew: json['isNew'] as bool? ?? false,
    model: json['model'] as String?,
    modelScale: (json['modelScale'] as num?)?.toDouble() ?? 1,
  );

  final String id;
  final String name;
  final String categoryId;
  final String description;
  final Dimensions dimensions;
  final List<Fabric> fabrics;
  final String defaultFabricId;
  final bool isNew;

  /// Path to the .glb model, or null when the piece has none yet.
  final String? model;

  /// Uniform scale that brings [model] to the piece's real size.
  final double modelScale;

  Fabric get defaultFabric => fabrics.firstWhere((f) => f.id == defaultFabricId, orElse: () => fabrics.first);

  Fabric fabric(String? id) => fabrics.firstWhere((f) => f.id == id, orElse: () => defaultFabric);

  /// The best image for [fabric]: its own render, else the default fabric's.
  String? imageFor(Fabric fabric) => fabric.image ?? defaultFabric.image;

  /// Hero tag shared by the catalog tile and the detail stage.
  String get heroTag => 'piece-$id';
}

class Collection {
  const Collection({required this.id, required this.name, required this.image, required this.itemIds});

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
    id: json['id'] as String,
    name: json['name'] as String,
    image: json['image'] as String,
    itemIds: [for (final i in json['items'] as List) i as String],
  );

  final String id;
  final String name;
  final String image;
  final List<String> itemIds;
}

class Catalog {
  const Catalog({required this.categories, required this.collections, required this.items});

  final List<FurnitureCategory> categories;
  final List<Collection> collections;
  final List<FurnitureItem> items;

  FurnitureItem? item(String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  String categoryName(String id) =>
      categories.firstWhere((c) => c.id == id, orElse: () => FurnitureCategory(id: id, name: id)).name;
}

/// A piece placed in the room during this session.
class PlacedPiece {
  const PlacedPiece({required this.uid, required this.itemId, required this.fabricId, this.slot = 0});

  factory PlacedPiece.fromJson(Map<String, dynamic> json) => PlacedPiece(
    uid: json['uid'] as String,
    itemId: json['item'] as String,
    fabricId: json['fabric'] as String,
    slot: json['slot'] as int? ?? 0,
  );

  final String uid;
  final String itemId;
  final String fabricId;

  /// Where it sits around the reticle until real AR placement exists.
  final int slot;

  Map<String, dynamic> toJson() => {'uid': uid, 'item': itemId, 'fabric': fabricId, 'slot': slot};
}

/// A saved arrangement of placed pieces.
class SavedDesign {
  const SavedDesign({required this.id, required this.createdAt, required this.pieces});

  factory SavedDesign.fromJson(Map<String, dynamic> json) => SavedDesign(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    pieces: [for (final p in json['pieces'] as List) PlacedPiece.fromJson(p as Map<String, dynamic>)],
  );

  final String id;
  final DateTime createdAt;
  final List<PlacedPiece> pieces;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'pieces': [for (final p in pieces) p.toJson()],
  };
}

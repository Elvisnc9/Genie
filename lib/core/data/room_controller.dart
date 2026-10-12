import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart' show ImageProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/placed_piece.dart';
import 'preferences.dart';

/// Pieces placed in the room this session (in memory; AR anchors arrive in
/// Phase 6).
final placedPiecesProvider = NotifierProvider<PlacedPieces, List<PlacedPiece>>(PlacedPieces.new);

class PlacedPieces extends Notifier<List<PlacedPiece>> {
  int _counter = 0;

  @override
  List<PlacedPiece> build() => const [];

  PlacedPiece place(String itemId, String fabricId) {
    final piece = PlacedPiece(
      uid: 'p${DateTime.now().microsecondsSinceEpoch}-${_counter++}',
      itemId: itemId,
      fabricId: fabricId,
      slot: state.length,
    );
    state = [...state, piece];
    return piece;
  }

  void remove(String uid) =>
      state = [
        for (final p in state)
          if (p.uid != uid) p,
      ];

  void clear() => state = const [];
}

/// The latest AR snapshot from the shutter, shown on Home's thumbnail
/// (this session only).
final lastShotProvider = NotifierProvider<LastShot, ImageProvider?>(LastShot.new);

class LastShot extends Notifier<ImageProvider?> {
  @override
  ImageProvider? build() => null;

  void set(ImageProvider? image) => state = image;
}

/// Saved designs, persisted locally.
final savedDesignsProvider = NotifierProvider<SavedDesigns, List<SavedDesign>>(SavedDesigns.new);

class SavedDesigns extends Notifier<List<SavedDesign>> {
  @override
  List<SavedDesign> build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(PrefKeys.savedDesigns);
    if (raw == null) return const [];
    try {
      return [for (final d in jsonDecode(raw) as List) SavedDesign.fromJson(d as Map<String, dynamic>)];
    } on FormatException {
      return const [];
    }
  }

  SavedDesign save(List<PlacedPiece> pieces) {
    final design = SavedDesign(
      id: 'd${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      pieces: pieces,
    );
    _write([design, ...state]);
    return design;
  }

  void delete(String id) => _write([
    for (final d in state)
      if (d.id != id) d,
  ]);

  void clear() => _write(const []);

  void _write(List<SavedDesign> designs) {
    state = designs;
    unawaited(
      ref
          .read(sharedPreferencesProvider)
          .setString(PrefKeys.savedDesigns, jsonEncode([for (final d in designs) d.toJson()])),
    );
  }
}

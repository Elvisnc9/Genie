import 'dart:async';
import 'dart:io' show Platform;

import 'package:ar_flutter_plugin_plus/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_plus/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_plus/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_plus/models/ar_node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';

import '../models/furniture_item.dart';

/// Whether the live AR camera can run here: Android with ARCore, not in
/// widget tests (which can't host the platform view), not on the web.
final arAvailableProvider = Provider<bool>((ref) {
  if (kIsWeb) return false;
  if (!Platform.isAndroid) return false; // iOS bridge has no centre hit test yet
  return !Platform.environment.containsKey('FLUTTER_TEST');
});

enum PlaceOutcome { placed, noFloor, noModel, failed }

/// Drives one AR session: finds the floor under the screen centre (for the
/// reticle) and anchors pieces there at true scale.
class GenieAr extends ChangeNotifier {
  ARSessionManager? _session;
  ARObjectManager? _objects;
  ARAnchorManager? _anchors;
  Timer? _poll;
  bool _busy = false;
  bool _disposed = false;

  ARHitTestResult? _hit;

  /// The floor point under the reticle, if any.
  ARHitTestResult? get hit => _hit;

  bool get floorFound => _hit != null;
  bool get ready => _session != null;

  final _nodes = <String, (ARNode, ARPlaneAnchor)>{};

  /// How often the reticle asks "is there floor under the centre?".
  static const _pollEvery = Duration(milliseconds: 120);

  Future<void> attach(
    ARSessionManager session,
    ARObjectManager objects,
    ARAnchorManager anchors, {
    required bool showPlanes,
  }) async {
    _session = session;
    _objects = objects;
    _anchors = anchors;
    session.onPlaneOrPointTap = (_) {}; // placement comes from the reticle, not taps
    await session.onInitialize(
      showAnimatedGuide: false, // Genie's status chip guides instead
      showFeaturePoints: false,
      showPlanes: showPlanes,
      showWorldOrigin: false,
      handleTaps: false,
      handlePans: true, // drag a placed piece along the floor
      handleRotation: true, // twist to turn it
    );
    objects.onInitialize();
    _poll = Timer.periodic(_pollEvery, (_) => _probe());
    if (!_disposed) notifyListeners();
  }

  Future<void> _probe() async {
    final session = _session;
    if (session == null || _busy) return;
    _busy = true;
    try {
      final hits = await session.hitTestScreen(0.5, 0.5);
      final next = hits.isEmpty ? null : hits.first;
      final changed = (next == null) != (_hit == null);
      _hit = next;
      if (changed && !_disposed) notifyListeners();
    } finally {
      _busy = false;
    }
  }

  Future<void> setShowPlanes(bool show) async => _session?.setShowPlanes(show);

  /// Anchors [item] on the floor under the reticle, at its real size.
  Future<PlaceOutcome> place(FurnitureItem item, {required String uid}) async {
    final model = item.model;
    if (model == null) return PlaceOutcome.noModel;
    final hit = _hit;
    final objects = _objects;
    final anchors = _anchors;
    if (hit == null || objects == null || anchors == null) return PlaceOutcome.noFloor;

    final anchor = ARPlaneAnchor(transformation: hit.worldTransform, name: 'anchor-$uid');
    if (await anchors.addAnchor(anchor) != true) return PlaceOutcome.failed;
    final node = ARNode(
      type: NodeType.localGLB,
      uri: model,
      name: uid,
      scale: Vector3.all(item.modelScale),
      position: Vector3.zero(),
    );
    if (await objects.addNode(node, planeAnchor: anchor) != true) {
      anchors.removeAnchor(anchor);
      return PlaceOutcome.failed;
    }
    _nodes[uid] = (node, anchor);
    return PlaceOutcome.placed;
  }

  void remove(String uid) {
    final entry = _nodes.remove(uid);
    if (entry == null) return;
    _objects?.removeNode(entry.$1);
    _anchors?.removeAnchor(entry.$2);
  }

  Future<ImageProvider?> snapshot() async {
    try {
      return await _session?.snapshot();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    _session?.dispose();
    super.dispose();
  }
}

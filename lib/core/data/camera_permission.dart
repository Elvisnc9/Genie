import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraAccess {
  /// Not asked yet (or the OS will still show its dialog).
  unknown,
  granted,

  /// Refused, but the OS will ask again.
  denied,

  /// Refused for good ("Don't ask again", or blocked by policy). Only the
  /// system settings can turn it back on.
  blocked,
}

/// Wraps permission_handler so screens and tests don't touch the plugin.
class CameraPermissionService {
  const CameraPermissionService();

  Future<CameraAccess> status() async => _map(await Permission.camera.status, asked: false);

  Future<CameraAccess> request() async => _map(await Permission.camera.request(), asked: true);

  Future<bool> openSettings() => openAppSettings();

  static CameraAccess _map(PermissionStatus s, {required bool asked}) {
    if (s.isGranted || s.isLimited) return CameraAccess.granted;
    if (s.isPermanentlyDenied || s.isRestricted) return CameraAccess.blocked;
    return asked ? CameraAccess.denied : CameraAccess.unknown;
  }
}

final cameraPermissionServiceProvider = Provider<CameraPermissionService>((ref) => const CameraPermissionService());

/// Current camera access. Call [refresh] after returning from system settings.
final cameraAccessProvider = NotifierProvider<CameraAccessController, CameraAccess>(CameraAccessController.new);

class CameraAccessController extends Notifier<CameraAccess> {
  @override
  CameraAccess build() {
    refresh();
    return CameraAccess.unknown;
  }

  CameraPermissionService get _service => ref.read(cameraPermissionServiceProvider);

  Future<CameraAccess> refresh() async {
    final s = await _service.status();
    // Keep a known refusal: status() can't tell "denied" from "never asked".
    if (!(s == CameraAccess.unknown && state == CameraAccess.denied)) state = s;
    return state;
  }

  Future<CameraAccess> request() async {
    state = await _service.request();
    return state;
  }

  Future<void> openSettings() => _service.openSettings();
}

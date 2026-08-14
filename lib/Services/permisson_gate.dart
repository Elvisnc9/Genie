import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionGate extends StatefulWidget {
  final Widget child; // shown once permission is granted
  final VoidCallback? onDenied;

  const PermissionGate({super.key, required this.child, this.onDenied});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  PermissionStatus? _status;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    // Still asking — brief loading state.
    if (_status == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_status!.isGranted) {
      return widget.child;
    }

    // Denied or permanently denied — block with an explanation, not a crash.
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              const Text(
                'GENIE needs camera access to place furniture in your room.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_status!.isPermanentlyDenied) {
                    await openAppSettings();
                  } else {
                    _requestPermission();
                  }
                },
                child: Text(
                  _status!.isPermanentlyDenied ? 'Open Settings' : 'Grant Permission',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
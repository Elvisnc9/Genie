import 'package:flutter/material.dart';
import 'package:genie/Services/permisson_gate.dart';
import 'package:genie/presentation/screen/home.dart';
import 'package:genie/presentation/screen/model_detail.dart';
import 'package:genie/presentation/screen/onboarding.dart';
import 'package:genie/presentation/screen/setting.dart';

class Appshell extends StatefulWidget {
  const Appshell({super.key});

  @override
  State<Appshell> createState() => _AppshellState();
}

class _AppshellState extends State<Appshell> {
  bool _showOnboarding = true;
  AppOverlay _overlay = AppOverlay.none;

  void _completeOnboarding() {
    setState(() => _showOnboarding = false);
  }

  void _setOverlay(AppOverlay next) {
    setState(() => _overlay = next);
  }


  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(onDone: _completeOnboarding);
    }

    // Permission is requested here — right before the camera-owning
    // shell mounts, not before, not buried inside CameraView itself.
    return PermissionGate(
      child: Stack(
        children: [
          CameraView(
            onOpenCatalog: () => _setOverlay(AppOverlay.catalog),
            onOpenSettings: () => _setOverlay(AppOverlay.settings),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildOverlay(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    switch (_overlay) {
      case AppOverlay.none:
        return const SizedBox.shrink(key: ValueKey('none'));
      case AppOverlay.catalog:
        return CatalogPanel(
          key: const ValueKey('catalog'),
          onDismiss: () => _setOverlay(AppOverlay.none),
          onSelectFurniture: () => _setOverlay(AppOverlay.info),
        );
      case AppOverlay.info:
        return FurnitureInfoScreen(
          key: const ValueKey('info'),
          onBack: () => _setOverlay(AppOverlay.catalog),
          onViewInRoom: () => _setOverlay(AppOverlay.none),
        );
      case AppOverlay.settings:
        return SettingsPanel(
          key: const ValueKey('settings'),
          onDismiss: () => _setOverlay(AppOverlay.none),
        );
    }
  }
}

enum AppOverlay {
  none,
  catalog,
  info,
  settings,
}
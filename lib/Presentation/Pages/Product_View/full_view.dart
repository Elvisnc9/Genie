import 'package:flutter/material.dart';
import 'package:genie/Presentation/Pages/Product_View/furniture_Model.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ImmersiveModelPage extends StatelessWidget {
  final FurnitureModel item;

  const ImmersiveModelPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'model-${item.name}',
                child: ModelViewer(
                  src: item.modelUrl,
                  ar: true,
                  arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                  cameraControls: true,
                  autoRotate: false,
                  disableZoom: false,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

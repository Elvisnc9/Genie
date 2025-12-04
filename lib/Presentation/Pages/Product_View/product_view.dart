import 'package:flutter/material.dart';
import 'package:genie/Constant/color.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  // List of your 3D assets
  final List<String> furnitureModels = [
    'assets/model/office_table.glb',
    'assets/model/office_table.glb',
    'assets/model/office_table.glb',
    'assets/model/office_table.glb',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintty,
      body: PageView.builder(
        itemCount: furnitureModels.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
      
          final model = furnitureModels[index];

          return Container(
            color: Colors.transparent, // full background color
            child: SafeArea(
              child: ModelViewer(
                src: model,
                autoPlay: true,
                autoRotate: true,
                ar: true,
                cameraControls: true,
                disableZoom: false,
                interactionPrompt: InteractionPrompt.none,
                backgroundColor: Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }
}

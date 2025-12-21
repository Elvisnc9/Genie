import 'package:flutter/material.dart';
import 'package:genie/Presentation/Pages/Product_View/furniture_Model.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() =>
      _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  int selectedIndex = 0;
  late WebViewController _webController;

  @override
  Widget build(BuildContext context) {
    final selectedItem = furnitureList[selectedIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Discover Stylish &\nAffordable Furniture",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
              ),
            ),

            

            // 🪑 3D MODEL VIEWER
            Expanded(
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  ModelViewer(
                    key: ValueKey(selectedItem.modelUrl),
                    src: selectedItem.modelUrl,
                    alt: selectedItem.name,
                    disableZoom: true,
                    autoRotate: true,
                    cameraControls: true,
                    cameraOrbit: '45deg 75deg 2.9m',                        
                    fieldOfView: '30deg',

                   
                

                  shadowIntensity: 0.8,
                    backgroundColor: Colors.transparent,

                  // onWebViewCreated: (controller) => _webController = controller,


              //       onModelLoaded: (url) {
              //   _webController.runJavaScript(
              //     "const mv = document.querySelector('model-viewer');" 
              //     "mv.cameraOrbit = '45deg 75deg 1.6m';"
              //     "mv.fieldOfView = '30deg';"
              //   );
              // },
                  ),

                  // 💳 Floating Info Card
                  Positioned(
                    top: 60,
                    left: 30,
                    child: Container(
                    
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [

                          Container(
                            width: 70,
                            height: 70,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(selectedItem.thumbnail),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),

                     
                          ),

                          SizedBox(width: 10),

                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            
                                Text(
                                  selectedItem.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  selectedItem.price,
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                    Positioned(
              child: CurvedCarousel(
                items: furnitureList,
                onChanged: (index) { setState(() => selectedIndex = index); },
              ),
            ),
                ],
              ),
            ),

            // 🔁 Circular Carousel
          
          ],
        ),
      ),
    );
  }
}







class CurvedCarousel extends StatefulWidget {
  final List<FurnitureModel> items;
  final ValueChanged<int> onChanged;

  const CurvedCarousel({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  State<CurvedCarousel> createState() => _CurvedCarouselState();
}

class _CurvedCarouselState extends State<CurvedCarousel> {
  late PageController _controller;
  double page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.40)
      ..addListener(() {
        setState(() {
          page = _controller.page ?? 0;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    const radius = 0.3;
    const angleStep = 0.75;

    return SizedBox(
      height: 210,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: widget.onChanged,
        itemBuilder: (context, index) {
          final diff = index - page;
          final angle = diff * angleStep;

          final x = radius * sin(angle);
          final y = radius * (1 - cos(angle));

          final scale = 1 - (diff.abs() * 0.25).clamp(0.4, 1.0).toDouble();


          final isCenter = diff.abs() < 0.6;
          final yOffset = y + (isCenter ? -55.0 : 0.0);

          return Transform.translate(
            offset: Offset(x, yOffset),
            child: Transform.scale(
              scale: scale,
              child: _item(widget.items[index].thumbnail, isCenter),
            ),
          );
        },
      ),
    );
  }

  Widget _item(String image, bool isActive) {
    return CircleAvatar(
      radius: isActive ? 100 : 80,
      backgroundImage: AssetImage(image),
      
    );
  }}







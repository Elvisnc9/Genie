import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genie/Constant/color.dart';
import 'package:genie/Presentation/Pages/Product_View/full_view.dart';
import 'package:genie/Presentation/Pages/Product_View/furniture_Model.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  int selectedIndex = 0;
  late WebViewController _webController;
  bool exiting = false;
  bool _isFullView = false;

  // helper to apply camera + rotation settings
  void _applyModelViewerSettings({
    String cameraOrbit =
        '200deg 65deg 1.8m', // changed azimuth to show model from left
    String fieldOfView = '30deg',
    String rotationPerSec = '20deg', // faster rotation (degrees per second)
  }) {
    try {
      _webController.runJavaScript(
        "const mv = document.querySelector('model-viewer');"
        "if (mv) {"
        " mv.cameraOrbit = '$cameraOrbit';"
        " mv.fieldOfView = '$fieldOfView';"
        " mv.setAttribute('rotation-per-second', '$rotationPerSec');"
        " mv.autoRotate = true;"
        " mv.play();"
        "}",
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = furnitureList[selectedIndex];
    return Scaffold(
      backgroundColor: AppColors.berry,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Header
            Header()
                .animate(target: exiting ? 1 : 0)
                .fadeOut(duration: 600.ms)
                .slideY(begin: 0, end: -0.2),

                 if(exiting) Align(
                  alignment: Alignment.topLeft,
                   child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: ()async{
                        setState(() => exiting = false);
                        await Future.delayed(
                          const Duration(milliseconds: 500),
                        );
                    
                      },),
                 ),
               

            // 🪑 3D MODEL VIEWER
            Expanded(
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [

                  
                  Hero(
                    tag: 'model-${selectedItem.name}',
                    flightShuttleBuilder: (_, animation, __, ___, ____) {
                      return ScaleTransition(
                        scale: animation.drive(
                          Tween(
                            begin: 1.0,
                            end: 1.15,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: ModelViewer(
                          src: selectedItem.modelUrl,
                          autoRotate: true,
                          cameraControls: true,
                          ar:  true ,
                          backgroundColor: Colors.transparent,
                        ),
                      );
                    },
                    child: ModelViewer(
                      key: ValueKey(selectedItem.modelUrl),
                      src: selectedItem.modelUrl,
                      disableZoom: true,
                      autoRotate: true,
                      cameraControls: true,
                      ar: _isFullView? true : false ,
                      backgroundColor: Colors.transparent,
                    ),
                  ),


                

                   Positioned(
                  top: 160,
                  left: 25,
                  child: Floating_info_card(
                          selectedItem: selectedItem,
                          press: () async {
                            debugPrint("Pressed");
                            setState(() => exiting = true);
                  
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                  
                  
                            
                          },
                        )
                        .animate(target: exiting ? 1 : 0)
                        .fadeOut(duration: 300.ms)
                        .scaleXY(begin: 1, end: 0.9),
                ),

                  // ModelViewer(
                  //   key: ValueKey(selectedItem.modelUrl),
                  //   src: selectedItem.modelUrl,
                  //   alt: selectedItem.name,
                  //   disableZoom: true,
                  //   autoRotate: true,
                  //   cameraControls: true,
                  //   cameraOrbit: '40deg 75deg 1.8m',
                  //   fieldOfView: '30deg',

                  // shadowIntensity: 0.8,
                  //   backgroundColor: Colors.transparent,

                  // onWebViewCreated: (controller) {
                  //     _webController = controller;
                  //     // apply settings immediately when webview is ready
                  //     _applyModelViewerSettings();
                  //   },
                  // ),

                  // 💳 Floating Info Card
                  
                   


                  Positioned(
                        child: CurvedCarousel(
                          items: furnitureList,
                          onChanged: (index) {
                            setState(() => selectedIndex = index);
                            try {
                              final url = furnitureList[index].modelUrl;
                              _webController.runJavaScript(
                                "const mv = document.querySelector('model-viewer');"
                                "if (mv) { mv.src = '$url'; mv.load(); }",
                              );
                              _applyModelViewerSettings();
                            } catch (_) {}
                          },
                        ),
                      )
                      .animate(target: exiting ? 1 : 0)
                      .fadeOut(duration: 300.ms)
                      .slideY(begin: 0, end: 0.3),
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

class Floating_info_card extends StatelessWidget {
  const Floating_info_card({
    super.key,
    required this.selectedItem,
    required this.press,
  });

  final FurnitureModel selectedItem;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 75,
            height: 75,
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
            padding: const EdgeInsets.only(left: 8.0, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedItem.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextButton(
                  onPressed: press, 
                  child:  Text("View Now ", 
                  style: TextStyle(color: Colors.orangeAccent,
                   fontWeight: FontWeight.bold, fontSize: 16.sp)))
    
                // GestureDetector(
                //   onTap: press,`
                //   child: Text(
                //     "View Now ",
                //     style: TextStyle(
                //       color: Colors.orangeAccent,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 16.sp,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        "Discover Stylish &\nAffordable Furniture",
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1.4,
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
    _controller = PageController(viewportFraction: 0.40)..addListener(() {
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
  }
}

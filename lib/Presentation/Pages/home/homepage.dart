import 'dart:ui';

import 'package:ar_flutter_plugin_plus/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:genie/Constant/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genie/Presentation/Pages/Authentication/google_auth.dart';

/// HomePage UI stacked on top of ARView (ARView is used as a visual background only).
/// No AR object placement logic is added beyond the required onARViewCreated hook.
/// Uses Image.asset for all non-AR images (make sure assets are added to pubspec.yaml).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late ARSessionManager arSessionManager;
  late ARAnchorManager arAnchorManager;
  late ARObjectManager arObjectManager;

  String userName = '';
  final authService = AuthService();

  // UI
  bool _isPanelOpen = false;
  late final AnimationController _buttonPulseController;

  @override
  void initState() {
    super.initState();
    loadUserData();

    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    try {
      arSessionManager.dispose();
    } catch (_) {}
    _buttonPulseController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
    });
  }

  void _togglePanel() async {
    setState(() => _isPanelOpen = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PanelContent(
        onClose: () => Navigator.of(context).pop(),
      ),
    );
    if (!mounted) return;
    setState(() => _isPanelOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final texttheme = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ARView as the background — keep it full screen
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),

          // optional overlay for detection helpers / reticle etc.
          const FurnitureDetectionOverlay(),

          // Top UI & title stacked on top of ARView (safe area)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: media.size.height * 0.05),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // left: circle "more" - matches shape/size in your example
                      InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.85),
                          child: const Icon(Icons.more_horiz, color: Colors.black, size: 35),
                        ),
                      ),

                      // center title
                      Text('Decor your Space', style: texttheme.displaySmall),

                      // right: profile avatar
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final isLoggedIn = prefs.getBool('loggedIn') ?? false;
                            if (isLoggedIn) {
                              Navigator.pushNamed(context, '/UserPage');
                            } else {
                              Navigator.pushNamed(context, '/AuthScreen');
                            }
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.85),
                            child: const Icon(Icons.person_2_outlined, color: Colors.black, size: 30),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // spacer so top row stays at top
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Bottom center add (+) button — pulsing while panel closed
          Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _togglePanel,
                child: AnimatedBuilder(
                  animation: _buttonPulseController,
                  builder: (context, child) {
                    final scale = 1.0 + 0.04 * _buttonPulseController.value;
                    final shadowSpread = 6.0 * _buttonPulseController.value;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.96),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10 + shadowSpread,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(_isPanelOpen ? Icons.close_rounded : Icons.add, color: Colors.black, size: 34),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    // keep references so disposal is safe — no extra AR logic is added
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    // minimal initialization to keep ARView happy (no object management added)
    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: false,
    );
    arObjectManager.onInitialize();
  }
}

/// Simple visual overlay that sits above the ARView: center reticle + subtle hint.
/// This is a pure UI widget — tweak visuals to match your design exactly.
class FurnitureDetectionOverlay extends StatelessWidget {
  const FurnitureDetectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return IgnorePointer(
      ignoring: true, // overlay doesn't intercept gestures
      child: Stack(
        children: [
          // Top gradient to slightly darken the AR background for contrast
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: media.size.height * 0.28,
            child: Container(
              decoration: BoxDecoration(
                color : AppColors.dark
              ),
            ),
          ),

          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: media.size.height * 0.22,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.12)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Center reticle with subtle pulsing ring
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // outer translucent ring
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03),
                      border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.2),
                    ),
                  ),
                  // inner dashed-like circle (simple representation)
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.02),
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // small instruction near bottom center
          Positioned(
            bottom: media.size.height * 0.18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Move your phone to detect the floor',
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The modal panel content shown when the + button is tapped.
/// Uses local assets (Image.asset). Replace asset paths to match your project.
class _PanelContent extends StatefulWidget {
  final VoidCallback onClose;

  const _PanelContent({required this.onClose});

  @override
  State<_PanelContent> createState() => _PanelContentState();
}

class _PanelContentState extends State<_PanelContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  final List<Map<String, String>> _collections = [
    {'title': 'OUTDOOR', 'asset': 'assets/model/3dd.png'},
    {'title': 'LIVING', 'asset': 'assets/model/3dd.png'},
    {'title': 'DINING', 'asset': 'assets/model/3dd.png'},
  ];

  final List<Map<String, String>> _products = [
    {'title': 'Backrest Chair', 'price': '\$99.30', 'asset': 'assets/model/3dd.png'},
    {'title': 'Blue Chair', 'price': '\$99.50', 'asset': 'assets/model/3dd.png'},
    {'title': 'Green Sofa', 'price': '\$129.99', 'asset': 'assets/model/3dd.png'},
    {'title': 'Small Table', 'price': '\$199.00', 'asset': 'assets/model/3dd.png'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 340));
    _slide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _categoryIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _productCard(String asset, String title, String price, bool showNew) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image + badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Image.asset(asset, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.crop_free_outlined, size: 16, color: Colors.black54),
                ),
              ),
              if (showNew)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                    child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('Size: 3ft / 2ft', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add, size: 20, color: Colors.black),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heightFactor = 0.82;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // absorb taps outside the actual panel
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // top row: X, title, search (matches your reference)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _controller.reverse().then((_) => widget.onClose());
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.close, color: Colors.black54),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Best Collection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.search, color: Colors.black54),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // horizontal collections
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _collections.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = _collections[index];
                            return Container(
                              width: 260,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                image: DecorationImage(
                                  image: AssetImage(item['asset']!),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.12), BlendMode.darken),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(item['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // product for you + categories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Product for you', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          Row(
                            children: [
                              _categoryIcon(Icons.desktop_windows, 'Desk'),
                              const SizedBox(width: 8),
                              _categoryIcon(Icons.chair, 'Chair'),
                              const SizedBox(width: 8),
                              _categoryIcon(Icons.tv, 'TV Stand'),
                              const SizedBox(width: 8),
                              _categoryIcon(Icons.weekend, 'Sofa'),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // products grid
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _products.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          itemBuilder: (context, index) {
                            final p = _products[index];
                            return _productCard(p['asset']!, p['title']!, p['price']!, index.isEven);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryIIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}
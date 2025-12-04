import 'dart:ui';

import 'package:ar_flutter_plugin_plus/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:genie/Constant/color.dart';
import 'package:genie/Presentation/Pages/home/downPanel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genie/Presentation/Pages/Authentication/google_auth.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

/// HomePage UI stacked on top of ARView (ARView is used as a visual background only).
/// No AR object placement logic is added beyond the required onARViewCreated hook.
/// Uses Image.asset for all non-AR images (make sure assets are added to pubspec.yaml).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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
      builder: (_) => Downpanel(onClose: () => Navigator.of(context).pop()),
    );
    if (!mounted) return;
    setState(() => _isPanelOpen = false);
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ARView as the background — keep it full screen
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),

          // Top UI & title stacked on top of ARView (safe area)
          Positioned(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 4.h),
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
                          radius: 20,
                          backgroundColor: AppColors.light.withOpacity(0.95),
                          child: const Icon(
                            Icons.more_horiz,
                            color: AppColors.dark,
                            size: 25,
                          ),
                        ),
                      ),

                      // center title

                      // right: profile avatar
                      SizedBox(width: 2.w),
                      
                      InkWell(
                        onTap: () async {
                          final prefs =
                              await SharedPreferences.getInstance();
                          final isLoggedIn =
                              prefs.getBool('loggedIn') ?? false;
                          if (isLoggedIn) {
                            Navigator.pushNamed(context, '/UserPage');
                          } else {
                            Navigator.pushNamed(context, '/AuthScreen');
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.light.withOpacity(
                            0.95,
                          ),
                          child: const Icon(
                            Icons.person_2_outlined,
                            color: AppColors.dark,
                            size: 20,
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
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _togglePanel,
                child:  Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.light.withOpacity(0.96),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10 ,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPanelOpen ? Icons.close_rounded : Icons.add,
                          color: Colors.black,
                          size: 34,
                        ),
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
      showAnimatedGuide: false
    );
    arObjectManager.onInitialize();
  }
}

/// Simple visual overlay that sits above the ARView: center reticle + subtle hint.
/// The modal panel content shown when the + button is tapped.
/// Uses local assets (Image.asset). Replace asset paths to match your project.
/// 

import 'dart:math';
import 'dart:ui';
import 'package:ar_flutter_plugin_plus/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genie/Constant/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';
enum AppState{ai, self}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ARSessionManager arSessionManager;
  late ARAnchorManager arAnchorManager;
  late ARObjectManager arObjectManager;

  String userName = '';
   AppState _mode = AppState.self;

 
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    try {
      arSessionManager.dispose();
    } catch (_) {}
    super.dispose();
  }

  // Async but don't await - load in background
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final name = prefs.getString('userName') ?? 'User';
    if (userName != name) {
      setState(() => userName = name);
    }
  }


  void _navigateToProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('loggedIn') ?? false;
    
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      isLoggedIn ? '/UserPage' : '/AuthScreen',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          // ARView as background
           Positioned.fill(
            child: ARView(
              onARViewCreated: _onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
          ),

          // Top UI layer with glassmorphism
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.h,
                  vertical: 2.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Spacer(),
                    //I need a Tabbar here 
                    _modeSwitch(),
                   const Spacer(),
                    // Profile button with micro-interaction
                    Button(
                      onTap: _navigateToProfile,
                      child: const Icon(
                        Icons.person_2_outlined,
                        color: AppColors.light,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom FAB with instant feedback
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Button(child: Icon(Icons.add_rounded, size: 40, color: AppColors.light),
             onTap: (){})
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
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: false,
      showAnimatedGuide: false,
    );
    arObjectManager.onInitialize();
  }


  Widget _modeSwitch() {
  return Container(
    height: 44,
    width: 180,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.3),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white24),
    ),
    child: Row(
      children: [
        _modeButton("Self", AppState.self),
        _modeButton("AI", AppState.ai),
      ],
    ),
  );
}



Widget _modeButton(String text, AppState mode) {
  final selected = _mode == mode;
  return Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() => _mode = mode);
        HapticFeedback.mediumImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.9) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}


Widget _animatedModeContent() {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 600),
    switchInCurve: Curves.easeOutBack,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) {
      final rotate = Tween(begin: pi, end: 0.0).animate(animation);
      return AnimatedBuilder(
        animation: rotate,
        child: child,
        builder: (context, child) {
          final isUnder = (ValueKey(_mode) != child!.key);
          final tilt = isUnder ? min(rotate.value, pi / 2) : rotate.value;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(tilt),
            alignment: Alignment.center,
            child: child,
          );
        },
      );
    },
    child: _mode == AppState.self
        ? SelfModeOverlay(key: const ValueKey("self"))
        : AiModeOverlay(key: const ValueKey("ai")),
  );
}


}

// Reusable glass button with instant feedback
class Button extends StatelessWidget {
  const Button({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return  InkWell(
         onTap: onTap,
        child: child,
     
    );
  }
}

// Animated FAB with instant visual feedback



class SelfModeOverlay extends StatelessWidget {
  const SelfModeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          "SELF MODE",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class AiModeOverlay extends StatelessWidget {
  const AiModeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          "AI MODE",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

import 'package:ar_flutter_plugin_plus/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:genie/Constant/color.dart';
import 'package:genie/Presentation/Pages/Authentication/google_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ARSessionManager arSessionManager;
  late ARAnchorManager arAnchorManager;
  late ARObjectManager arObjectManager;

  @override
  void dispose() {
    arSessionManager.dispose();
    super.dispose();
  }

  String userName = '';
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    final texttheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),

          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 5.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.8),
                          child: Icon(
                            Icons.more_horiz,
                            color: Colors.black,
                            size: 35,
                          ),
                        ),
                      ),

                      Text('Decor your Space', style: texttheme.displaySmall),

                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final isLoggedIn =
                                prefs.getBool('loggedIn') ?? false;

                            if (isLoggedIn) {
                              Navigator.pushNamed(context, '/UserPage');
                            } else {
                              Navigator.pushNamed(context, '/AuthScreen');
                            }
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.8),

                            child: Icon(
                              Icons.person_2_outlined,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Spacer(),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {},
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.add,
                          color: AppColors.dark,

                          weight: 20,
                          size: 35,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    ); //
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
      handleTaps: true,
    );
    arObjectManager.onInitialize();
  }
}

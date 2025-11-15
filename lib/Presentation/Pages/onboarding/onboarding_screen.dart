import 'package:flutter/material.dart';
import 'package:genie/Constant/color.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';
import 'package:video_player/video_player.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late VideoPlayerController _controller;
  bool _isReady = false;



  @override
  void initState(){
    super.initState();
    _controller = VideoPlayerController.asset('assets/animes/SPLASHSCREEN.mp4')
    ..initialize().then((_){
      _controller.setLooping(true);
      _controller.play();
      _controller.setVolume(10);

      setState(() => _isReady = true);
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionsAndNavigate(BuildContext context) async {
    // Request camera permission
    var status = await Permission.camera.request();

    if (status.isGranted) {
      // Permission granted, navigate to the AR home page
      if (context.mounted) {
        Navigator.pushNamed(context, '/Home');
      }
    } else if (status.isDenied) {
      // Handle denied permission (e.g., show a dialog)
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          backgroundColor: AppColors.berry,
          content: Text('Camera permission is required for AR.')),
      );
    } else if (status.isPermanentlyDenied) {
      // If permanently denied, guide the user to app settings
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final texttheme = Theme.of(context).textTheme;
    if(!_isReady) return const SizedBox.shrink();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [


           FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),

           Container(color: Colors.black.withOpacity(0.45)),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 1.h),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset('assets/icons/Genie2.png', height: 20.h),
                ),
          
                SizedBox(height: 9.h),
          
                Text(
                  'Visualize and experience furniture\n using Augmented Reality.',
                  textAlign: TextAlign.center,
                  style: texttheme.displayLarge?.copyWith(color: Colors.white)
                ),
          
                SizedBox(height: 2.h),
          
                Text(
                  'Explore Small, Premium, Top Class Furnitures as Per\n Your Exact Requirements and Choice.',
                  textAlign: TextAlign.center,
                  style: texttheme.displayMedium?.copyWith(color: AppColors.golden),
                ),
          
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 3.h),
                  child: Column(
                    children: [
                      ButtonWidget(
                        push: () { 
                          Navigator.pushNamed(context, '/AuthScreen');
                         },
                        child: Center(
                          child: Text(
                            'Sign in',
                            style: texttheme.displayLarge?.copyWith(
                              color: AppColors.light,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
          
                      SizedBox(height: 2.5.h),
          
                      InkWell(
                        onTap: () => _requestPermissionsAndNavigate(context),
                        child: Text(
                          'Visualize Now',
                          style: texttheme.displayLarge?.copyWith(fontSize: 20.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({super.key, required this.child, required this.push});

  final Widget child;
  final VoidCallback push;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: push,
      child: Container(
        height: 7.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.dark,
        ),
        child: child,
      ),
    );
  }
}

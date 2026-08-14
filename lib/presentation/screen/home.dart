import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class CameraView extends StatefulWidget {
  final VoidCallback onOpenCatalog;
  final VoidCallback onOpenSettings;

  const CameraView({
    super.key,
    required this.onOpenCatalog,
    required this.onOpenSettings,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    // Release the camera when backgrounded, reacquire on resume —
    // this mirrors how ARCore session pause/resume will need to work later.
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Positioned.fill(child: _buildPreview()),
        Positioned(
          top: 20,
          right: 16,
          child: SafeArea(
            child: IconButton(
              icon:  Icon(Icons.settings, size: 30.sp, color: Colors.white),
              onPressed: widget.onOpenSettings,
            ),
          ),
        ),

         Positioned(
          bottom: 30.h,
          left: 20,
          right: 0,
          child: AR_state_Feedback()
        ),
        Positioned(
          bottom: 8.h,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 70,
            width: 70,
            child: FloatingActionButton(
                      shape: CircleBorder(),
              onPressed: widget.onOpenCatalog,
              backgroundColor: Colors.white,
              child:  Icon(Icons.add, size: 35.sp, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (_controller == null || _initFuture == null) {
      return const ColoredBox(color: Colors.black);
    }

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 0,
                height: _controller!.value.previewSize?.width ?? 0,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AR_state_Feedback extends StatelessWidget {
  const AR_state_Feedback({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10.h,
      width: 25.w,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.cancel, color: Colors.red,),
      
              SizedBox(width: 2.w,),
              Text('Area Captured', style: TextStyle(fontSize: 8.sp),),
              
      ]
          ),

           Row(
            children: [
              Icon(Icons.verified_user, color: Colors.green,),
      
              SizedBox(width: 2.w,),
              Text('Floor Detected',style: TextStyle(fontSize: 8.sp),),
              
      ]
          ),
            Row(
            children: [
              Icon(Icons.verified_user, color: Colors.green,),
      
              SizedBox(width: 2.w,),
              Text('Room Scene Understood',style: TextStyle(fontSize: 8.sp, color: Colors.white),),
              
      ]
          )
        ],
      ),
    );
  }
}
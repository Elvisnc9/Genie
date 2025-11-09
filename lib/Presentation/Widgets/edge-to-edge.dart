import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SystemUiOverlayStyle customOverlayStyle({bool transparentStatusBar = false}) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final statusBarColor = transparentStatusBar ? Colors.transparent : null;
  return SystemUiOverlayStyle(
    statusBarColor: statusBarColor,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  );
}

class EdgeToEdgeWrapperWidget extends StatelessWidget {
  final Widget child;
  final bool transparentStatusBar;

  const EdgeToEdgeWrapperWidget({
    super.key,
    this.transparentStatusBar = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: customOverlayStyle(transparentStatusBar: transparentStatusBar),
      child: child,
    );
  }
}
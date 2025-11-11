import 'package:flutter/material.dart';
import 'package:genie/Constant/theme.dart';
import 'package:genie/Presentation/Pages/Authentication/authScreen.dart';
import 'package:genie/Presentation/Pages/home/homepage.dart';
import 'package:genie/Presentation/Pages/onboarding/onboarding_screen.dart';
import 'package:genie/Presentation/Widgets/edge-to-edge.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

void main() {
  
  runApp(TheResponsiveBuilder(
      builder: (context, Orientation, ScreenType) {
        return const MyApp();
      }
    ));}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return EdgeToEdgeWrapperWidget(
      child: MaterialApp(
        theme: Apptheme,
        title: 'Genie AR',
        routes: {
          '/': (context)=> OnboardingScreen(),
          '/Home' : (context) => HomePage(),
          '/AuthScreen' : (context) => AuthScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}


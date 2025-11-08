import 'package:flutter/material.dart';
import 'package:genie/Presentation/Pages/Authentication/authScreen.dart';
import 'package:genie/Presentation/Pages/home/homepage.dart';
import 'package:genie/Presentation/Pages/onboarding/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genie AR',
      routes: {
        '/onboarding': (context)=> OnboardingScreen(),
        '/Home' : (context) => HomePage(),
        '/AuthScreen' : (context) => AuthScreen(),
      },
      initialRoute: '/Onboarding',
    );
  }
}


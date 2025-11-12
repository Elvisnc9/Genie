import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genie/Constant/theme.dart';
import 'package:genie/Presentation/Pages/Authentication/authScreen.dart';
import 'package:genie/Presentation/Pages/User/userPage.dart';
import 'package:genie/Presentation/Pages/home/homepage.dart';
import 'package:genie/Presentation/Pages/onboarding/onboarding_screen.dart';
import 'package:genie/Presentation/Widgets/edge-to-edge.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('loggedIn') ?? false;



  runApp(TheResponsiveBuilder(
      builder: (context, Orientation, ScreenType)  {
        return MyApp(isLoggedIn: isLoggedIn);
      }
    ));}
    

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, this.isLoggedIn = false});
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
          '/UserPage': (context) => UserPage(),
        },
        initialRoute: isLoggedIn? '/Home' : '/'
      ),
    );
  }
}


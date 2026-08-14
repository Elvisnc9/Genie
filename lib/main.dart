import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genie/Constant/theme.dart';
import 'package:genie/core/appshell.dart';

import 'package:the_responsive_builder/the_responsive_builder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
 


  runApp(
    TheResponsiveBuilder(
      builder: (context, Orientation, ScreenType) {
        return ProviderScope(child: MyApp());
      },
    ),
  );
}

class MyApp extends StatelessWidget {
 
  const MyApp({super.key,});
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Apptheme,
        title: 'Genie AR',
    
    home: Appshell()
    );
  }
}





//f8d52d65c500473a8cfdb62024c29348
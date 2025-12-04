import 'package:flutter/material.dart';

import 'package:genie/Constant/color.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

final ThemeData Apptheme = ThemeData(
  scaffoldBackgroundColor:  AppColors.dark,
  primaryColor: AppColors.berry,
  iconTheme: IconThemeData(
    color: Colors.white
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStatePropertyAll<Color>(Colors.white)
    )
  ),
  fontFamily: 'Urbanist',
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 25.sp,
      fontWeight: FontWeight.bold,
     
    ),
     displayMedium: TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
     color: AppColors.light
    ),
    displaySmall: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 17.sp,
      fontWeight: FontWeight.bold,
     color: Colors.white
    ),

    labelMedium: TextStyle(
       fontFamily: 'Urbanist',
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
     color: AppColors.light
    
    ),
      labelLarge: TextStyle(
       fontFamily: 'Urbanist',
      fontSize: 17.sp,
      fontWeight: FontWeight.bold,
     color: AppColors.light.withOpacity(0.65)
    
    ),

  )
);
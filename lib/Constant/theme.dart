import 'package:flutter/material.dart';

import 'package:genie/Constant/color.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

final ThemeData Apptheme = ThemeData(
  scaffoldBackgroundColor:  AppColors.light,
  primaryColor: AppColors.berry,
  fontFamily: 'Urbanist',
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 25.sp,
      fontWeight: FontWeight.bold,
     
    ),
     displayMedium: TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 15.sp,
      fontWeight: FontWeight.bold,
     color: AppColors.berry
    ),
    displaySmall: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 17.sp,
      fontWeight: FontWeight.bold,
     color: Colors.white
    )
  )
);
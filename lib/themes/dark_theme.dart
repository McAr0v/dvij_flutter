// dark_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class CustomTheme {
  static ThemeData get darkTheme { //1
    return ThemeData( //2
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.greyOnBackground,
        titleTextStyle: TextStyle(color: AppColors.white, fontSize: 22, fontFamily: 'SfProDisplay', fontWeight: FontWeight.bold)
      ),
        primaryColor: AppColors.brandColor,
        scaffoldBackgroundColor: AppColors.greyBackground,
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.white, fontSize: 25, fontFamily: 'SfProDisplay', fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: AppColors.white),
          displaySmall: TextStyle(color: AppColors.white)),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.brandColor,
          secondary: AppColors.attentionRed,
          background: AppColors.greyBackground,
          onBackground: AppColors.greyBackground,
      ),
        // fontFamily: 'Montserrat', //3
        buttonTheme: ButtonThemeData( // 4
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: AppColors.brandColor,
        ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.greyOnBackground,
        selectedItemColor: AppColors.brandColor,
        unselectedItemColor: AppColors.greyText,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontFamily: 'SfProDisplay',
          fontWeight: FontWeight.normal
        ),
        selectedIconTheme: IconThemeData(
          size: 25
        )



      ),

    );
  }

  static ThemeData get lightTheme { //1
    return ThemeData( //2
      appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.brandColor,
          titleTextStyle: TextStyle(color: AppColors.white)
      ),
      primaryColor: AppColors.brandColor,
      scaffoldBackgroundColor: AppColors.greyBackground,
      textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.greyOnBackground, fontSize: 13),
          displayMedium: TextStyle(color: AppColors.greyOnBackground),
          displaySmall: TextStyle(color: AppColors.greyOnBackground)),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandColor,
        secondary: AppColors.attentionRed,
        background: AppColors.white,
        onBackground: AppColors.greyBackground,
      ),
      // fontFamily: 'Montserrat', //3
      buttonTheme: ButtonThemeData( // 4
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        buttonColor: AppColors.brandColor,
      ),
    );
  }

}


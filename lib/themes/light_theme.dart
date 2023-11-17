
import 'package:flutter/material.dart';
import 'app_colors.dart';

class LightTheme {
  static ThemeData themeData = ThemeData.light().copyWith(
    primaryColor: AppColors.brandColor,
    colorScheme: const ColorScheme.light(
      primary: AppColors.brandColor,
      secondary: AppColors.attentionRed,
      background: AppColors.white,
      onBackground: AppColors.greyText,
    ),
    scaffoldBackgroundColor: AppColors.white,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.greyText),
      displayMedium: TextStyle(color: AppColors.greyText),
      displaySmall: TextStyle(color: AppColors.greyText)
      // Используйте другие стили текста, например, caption, headline, subtitle, по мере необходимости
    ),
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
      backgroundColor: AppColors.greyBackground
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.brandColor,
      unselectedItemColor: AppColors.greyText,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontSize: 14),
      unselectedLabelStyle: TextStyle(fontSize: 14),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.greyText,
        backgroundColor: AppColors.brandColor,
        textStyle: const TextStyle(fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    ),
  );
}
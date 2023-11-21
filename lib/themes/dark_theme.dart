// dark_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class CustomTheme {

  // ---- ТЕМНАЯ ТЕМА ------
  static ThemeData get darkTheme {
    return ThemeData(

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(color: AppColors.white, fontSize: 16, fontFamily: 'SfProDisplay', fontWeight: FontWeight.normal),
          padding: EdgeInsets.all(10.0),
          minimumSize: Size(double.infinity, 50),
          backgroundColor: AppColors.brandColor,
          foregroundColor: AppColors.greyOnBackground,
          side: BorderSide(color: AppColors.brandColor, width: 2.0), // Добавлено границу кнопки
        ),

      ),

      // Верхняя панель

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.greyOnBackground,
        titleTextStyle: TextStyle(color: AppColors.white, fontSize: 22, fontFamily: 'SfProDisplay', fontWeight: FontWeight.bold),

      ),

      tabBarTheme: TabBarTheme(
        labelStyle: TextStyle(color: AppColors.brandColor, fontSize: 16, fontFamily: 'SfProDisplay', fontWeight: FontWeight.normal),
        unselectedLabelStyle: TextStyle(color: AppColors.white, fontSize: 14, fontFamily: 'SfProDisplay', fontWeight: FontWeight.normal),
        indicatorColor: AppColors.brandColor,
        indicatorSize: TabBarIndicatorSize.tab,

      ),

      primaryColor: AppColors.brandColor,

        // Цвет фона по умолчанию
      scaffoldBackgroundColor: AppColors.greyBackground,

      // Шрифты
      textTheme: const TextTheme(

          displayLarge: TextStyle(
            color: AppColors.white,
            fontSize: 35,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: AppColors.white,
            fontSize: 40,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.w900,
            height: 1.1


          ),
          titleMedium: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.bold,

          ),
          titleSmall: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.normal,

          ),
          bodyLarge: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.bold,

          ),
          bodyMedium: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.normal,
            height: 1.3

          ),
          bodySmall: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.normal,

          ),
        labelLarge: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontFamily: 'SfProDisplay',
          fontWeight: FontWeight.normal,
        ),
        labelMedium: TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontFamily: 'SfProDisplay',
          fontWeight: FontWeight.normal,

        ),
        labelSmall: TextStyle(
          color: AppColors.white,
          fontSize: 10,
          fontFamily: 'SfProDisplay',
          fontWeight: FontWeight.normal,


        )

      ),

      // Цветовая схема
      colorScheme: const ColorScheme.dark(
          primary: AppColors.brandColor,
          secondary: AppColors.attentionRed,
          background: AppColors.greyBackground,
          onBackground: AppColors.greyBackground,
      ),

      // Стиль кнопки
      buttonTheme: ButtonThemeData( // 4
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: AppColors.brandColor,
          textTheme: ButtonTextTheme.normal,

        ),

      // Стиль нижнего меню
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.greyOnBackground,
        selectedItemColor: AppColors.brandColor,
        unselectedItemColor: AppColors.greyText,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontFamily: 'SfProDisplay',
          fontWeight: FontWeight.normal,
        ),
        selectedIconTheme: IconThemeData(
          size: 25
        ),
        unselectedIconTheme: IconThemeData(
          color: AppColors.greyText
        ),
      ),

      // Всплываюшая шторка
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.greyOnBackground
      ),

      // Для драйвера
      // Заголовок и иконка
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.white,
        iconColor: AppColors.white,
        titleTextStyle: TextStyle(color: AppColors.white, fontSize: 16, fontFamily: 'SfProDisplay', fontWeight: FontWeight.normal),
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


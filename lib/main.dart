
import 'package:flutter/material.dart';
import 'themes/dark_theme.dart';  // Импортируйте вашу темную тему
import 'navigation/custom_nav_containter.dart';

void main() {
  runApp(
    MaterialApp(
      home: const CustomNavContainer(),
      theme: CustomTheme.darkTheme,
    ),
  );
}


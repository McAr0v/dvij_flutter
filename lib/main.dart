import 'package:flutter/material.dart';
import 'app_state/appstate.dart';
import 'themes/dark_theme.dart';
import 'navigation/custom_nav_containter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Инициализация Firebase

  // Создаем экземпляр AppState
  AppState appState = AppState();

  runApp(
    MaterialApp(
      home: CustomNavContainer(appState: appState),
      theme: CustomTheme.darkTheme,
    ),
  );
}
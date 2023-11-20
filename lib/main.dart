import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state/appstate.dart';
import 'themes/dark_theme.dart';
import 'navigation/custom_nav_containter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomNavContainer(),
      theme: CustomTheme.darkTheme,
    );
  }
}
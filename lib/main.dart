import 'package:dvij_flutter/screens/otherPages/privacy_policy_page.dart';
import 'package:dvij_flutter/screens/profile/reset_password_page.dart';
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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CustomNavContainer(),
      theme: CustomTheme.darkTheme,
      routes: {
        '/Profile': (context) => const CustomNavContainer(initialTabIndex: 0),
        '/Events': (context) => const CustomNavContainer(initialTabIndex: 1),
        '/Places': (context) => const CustomNavContainer(initialTabIndex: 2),
        '/Promotions': (context) => const CustomNavContainer(initialTabIndex: 3),
        '/privacy_policy': (context) => const PrivacyPolicyPage(),
        '/reset_password_page': (context) => const ResetPasswordPage(),
        // Другие маршруты вашего приложения
      },
    );
  }
}
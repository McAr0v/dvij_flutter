import 'package:dvij_flutter/screens/profile/login_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/screens/profile/registration_screen.dart';

import '../../app_state/appstate.dart';
import '../../authentication/auth_with_email.dart'; // Импортируем ваш экран регистрации

class EventsFeedPage extends StatelessWidget {
  final AppState appState;
  EventsFeedPage({Key? key, required this.appState}) : super(key: key);

  String? uid; // UID пользователя

  final AuthWithEmail authWithEmail = AuthWithEmail();


  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greyBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Мероприятия лента'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
              child: Text('Test Registration'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Test Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen(appState)),
                );
              },
              child: Text('user profile'),
            ),
          ],
        ),
      ),
    );
  }
}
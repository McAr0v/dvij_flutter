import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/appstate.dart';
import '../../authentication/auth_with_email.dart';
import '../../navigation/custom_nav_containter.dart';

class UserLoggedInScreen extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthWithEmail authWithEmail = AuthWithEmail();


  @override
  Widget build(BuildContext context) {
    // Получение uid из AppState

    String? uid = _auth.currentUser?.uid;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User UID: ${uid ?? "N/A"}'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await authWithEmail.signOut();

                Provider.of<AppState>(context, listen: false).setUid(null);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CustomNavContainer()),
                );
                // Выход из авторизации
                // Вам нужно добавить соответствующий код для выхода пользователя из авторизации
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
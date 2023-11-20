import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import 'package:provider/provider.dart';

import '../../app_state/appstate.dart';
import '../../navigation/custom_nav_containter.dart';

class RegistrationScreen extends StatefulWidget {


  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final AppState appState;
  final AuthWithEmail authWithEmail = AuthWithEmail();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;
                // Регистрация пользователя
                String? uid = await authWithEmail.createUserWithEmailAndPassword(email, password);

                if (uid != null) {
                  // Регистрация успешна, переходим на экран профиля пользователя
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfileScreen()),
                  );
                } else {
                  // Обработка случая, когда создание пользователя не удалось
                  // Можно показать сообщение об ошибке или принять соответствующие меры
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthWithEmail authWithEmail = AuthWithEmail();


  @override
  Widget build(BuildContext context) {
    // Получение uid из AppState

    String? uid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
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
import 'package:dvij_flutter/navigation/custom_nav_containter.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import '../../app_state/appstate.dart';

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
                    MaterialPageRoute(builder: (context) => CustomNavContainer()),
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


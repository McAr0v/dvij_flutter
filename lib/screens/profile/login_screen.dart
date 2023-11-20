import 'package:flutter/material.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import 'package:provider/provider.dart';
import '../../app_state/appstate.dart';
import '../../navigation/custom_nav_containter.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthWithEmail authWithEmail = AuthWithEmail();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Screen'),
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

                // Вход пользователя
                String? uid = await authWithEmail.signInWithEmailAndPassword(email, password);
                if (uid != null) {
                  Provider.of<AppState>(context, listen: false).setUid(uid);
                  Navigator.pushReplacement(
                    context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen()),
                );

                } else {
                  // Обработка случая, когда создание пользователя не удалось
                  // Можно показать сообщение об ошибке или принять соответствующие меры
                }




              },
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
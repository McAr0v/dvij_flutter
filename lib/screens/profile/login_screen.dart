import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:dvij_flutter/screens/profile/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import 'package:dvij_flutter/elements/custom_snack_bar.dart';

import '../../themes/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});


  @override
  _LoginScreenState createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  final AuthWithEmail authWithEmail = AuthWithEmail();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void navigateToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Profile', // Название маршрута, которое вы задаете в MaterialApp
          (route) => false,
    );
  }

  void showSnackBar(String message, Color color) {
    final snackBar = customSnackBar(message: message, backgroundColor: color);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool showForgotPasswordButton = false;

  void updateForgotPasswordButton(bool newValue) {
    setState(() {
      showForgotPasswordButton = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),

            CustomButton(
                buttonText: 'Войти',
                onTapMethod: () async {

                  String email = emailController.text;
                  String password = passwordController.text;

                  // Вход пользователя
                  String? uid = await authWithEmail.signInWithEmailAndPassword(email, password, context);

                  if (uid != null) {

                    if (uid == 'wrong-password') {
                      updateForgotPasswordButton(true);
                      showSnackBar('Вы ввели не правильный пароль', AppColors.attentionRed);
                    } else if (uid == 'user-not-found') {
                      showSnackBar('Пользователь с таким Email не найден', AppColors.attentionRed);
                    } else if (uid == 'too-many-requests') {
                      showSnackBar('Слишком много попыток входа. Мы заблокировали вход с вашего устройства. Попробуйте войти позже.', AppColors.attentionRed);
                    } else if (uid == 'channel-error') {
                      showSnackBar('Неизвестная нам ошибка( Попробуйте войти позже.', AppColors.attentionRed);
                    } else if (uid == 'invalid-email') {
                      showSnackBar('Не правильный формат Email', AppColors.attentionRed);
                    } else {
                      showSnackBar('Вход успешно выполнен', Colors.green);
                      navigateToProfile();
                    }

                  } else {

                    showSnackBar('Что-то пошло не так. Попробуйте позже', AppColors.attentionRed);

                  }
                }
            ),

            if (showForgotPasswordButton) const SizedBox(height: 50.0),

            if (showForgotPasswordButton) Text(
                'Забыли пароль?',
                style: Theme.of(context).textTheme.bodyMedium
            ),

            if (showForgotPasswordButton) const SizedBox(height: 20.0),

            if (showForgotPasswordButton) CustomButton(
              state: 'secondary',
              buttonText: 'Восстановить пароль',
              onTapMethod: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
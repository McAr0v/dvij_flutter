import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import 'package:dvij_flutter/elements/custom_snack_bar.dart';

import '../../themes/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});


  @override
  _ResetPasswordPage createState() => _ResetPasswordPage();

}

class _ResetPasswordPage extends State<ResetPasswordPage> {

  final AuthWithEmail authWithEmail = AuthWithEmail();
  final TextEditingController emailController = TextEditingController();

  void navigateToEvents() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Events', // Название маршрута, которое вы задаете в MaterialApp
          (route) => false,
    );
  }

  void showSnackBar(String message, Color color) {
    final snackBar = customSnackBar(message: message, backgroundColor: color);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Восстановление пароля'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text('Восстановление пароля', style: Theme.of(context).textTheme.titleLarge,),
            const SizedBox(height: 15.0),
            Text('Если вы забыли пароль, введите свою почту. Мы отправим вам письмо с инструкцией по восстановлению', style: Theme.of(context).textTheme.bodyMedium,),
            const SizedBox(height: 25.0),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),

            CustomButton(
                buttonText: 'Восстановить пароль',
                onTapMethod: () async {

                  String email = emailController.text;

                  // Вход пользователя
                  String? textMessage = await authWithEmail.resetPassword(email);

                  if (textMessage != null) {

                    if (textMessage == 'invalid-email') {
                      showSnackBar('Неправильный формат почты. Проверьте правильность входа', AppColors.attentionRed);
                    } else if (textMessage == 'user-not-found') {
                      showSnackBar('Пользователь с таким Email не найден', AppColors.attentionRed);
                    } else if (textMessage == 'too-many-requests') {
                      showSnackBar('Слишком много попыток входа. Мы заблокировали вход с вашего устройства. Попробуйте войти позже.', AppColors.attentionRed);
                    } else if (textMessage == 'missing-email') {
                      showSnackBar('Вы не ввели почту', AppColors.attentionRed);
                    } else if (textMessage == 'success') {
                      showSnackBar('Инструкция по восстановлению пароля была отправлена на вашу электронную почту. Следуйте инструкции и восстановите пароль', Colors.green);
                      navigateToEvents();
                    } else {
                      showSnackBar('Неизвестная нам ошибка( Попробуйте войти позже.', AppColors.attentionRed);
                    }

                  } else {

                    showSnackBar('Что-то пошло не так. Попробуйте позже', AppColors.attentionRed);

                  }
                }
            ),
          ],
        ),
      ),
    );
  }
}
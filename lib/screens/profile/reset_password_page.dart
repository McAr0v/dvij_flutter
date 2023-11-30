import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:dvij_flutter/screens/profile/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import 'package:dvij_flutter/elements/custom_snack_bar.dart';
import '../../themes/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});


  @override
  _ResetPasswordPage createState() => _ResetPasswordPage();

}

// ---- Экран сброса пароля ---

class _ResetPasswordPage extends State<ResetPasswordPage> {

  // --- Инициализируем классы -----
  final AuthWithEmail authWithEmail = AuthWithEmail();

  // --- Контроллеры для полей ввода ----
  final TextEditingController emailController = TextEditingController();

  // --- Функция перехода в мероприятия ------
  void navigateToEvents() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Events', // Название маршрута, которое вы задаете в MaterialApp
          (route) => false,
    );
  }

  // ---- Функция показа всплывающего сообщения ----

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ----- Отображение кнопки Регистрация -----

  bool showRegButton = false;

  void updateShowRegButton(bool newValue) {
    setState(() {
      showRegButton = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Восстановление пароля'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // TODO Сделать экран загрузки, пока идет функция сброса пароля

            // ---- Заголовок и описание ------

            Text('Восстановление пароля', style: Theme.of(context).textTheme.titleLarge,),
            const SizedBox(height: 15.0),
            Text('Забытый пароль – не повод для печали! Укажи свою почту, и мы отправим тебе инструкцию по восстановлению пароля', style: Theme.of(context).textTheme.bodyMedium,),
            const SizedBox(height: 25.0),

            // ---- Поле ввода email -----

            TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16.0),

            // ----- Кнопка восстановления пароля ----

            CustomButton(
                buttonText: 'Восстановить пароль',
                onTapMethod: () async {

                  String email = emailController.text;

                  // Сброс пароля

                  String? textMessage = await authWithEmail.resetPassword(email);

                  // --- Если есть результат функции сброса ----

                  if (textMessage != null) {

                    // TODO - добавить эти ошибки в функцию вывода ошибки

                    if (textMessage == 'invalid-email') {
                      updateShowRegButton(false);
                      showSnackBar('Ой, что-то с форматом Email пошло не так. Удостоверься, что вводишь его правильно, и давай еще раз! 📭🔄', AppColors.attentionRed, 5);
                    } else if (textMessage == 'user-not-found') {
                      updateShowRegButton(true);
                      showSnackBar('Упс! Похоже, такой Email не зарегистрирован. Может, опечатка? Попробуй еще раз или зарегистрируйcя! 📧🤔', AppColors.attentionRed, 5);
                    } else if (textMessage == 'too-many-requests') {
                      updateShowRegButton(false);
                      showSnackBar('Ой! Слишком много попыток. В целях безопасности мы заблокировали вход с твоего устройства. Попробуй позже! 🔒⏳', AppColors.attentionRed, 5);
                    } else if (textMessage == 'missing-email') {
                      updateShowRegButton(false);
                      showSnackBar('Без твоей почты мы в тупике. Поделись ею, и мы вмиг отправим инструкции по восстановлению пароля.', AppColors.attentionRed, 5);
                    } else if (textMessage == 'success') {

                      showSnackBar('Проверь свою почту – мы отправили инструкции по восстановлению пароля. Следуй шагам и верни доступ к аккаунту', Colors.green,5);
                      navigateToEvents();
                    } else {
                      showSnackBar('Ой! Что-то у нас пошло не так, и мы в печали. Попробуй войти позже', AppColors.attentionRed, 5);
                    }

                  } else {

                    showSnackBar('Что-то пошло не так, и мы с ним не знакомы. Попробуй войти позже, и, возможно, все недоразумение разрешится', AppColors.attentionRed, 5);

                  }
                }
            ),

            // ---- Контент кнопки регистрации -----

            if (showRegButton) const SizedBox(height: 50.0),

            if (showRegButton) Text(
                'Ой-ой! Нет пользователя с таким Email. Может нужно создать новый аккаунт? 📩🔍',
                style: Theme.of(context).textTheme.bodyMedium
            ),

            if (showRegButton) const SizedBox(height: 20.0),

            if (showRegButton) CustomButton(
              state: 'secondary',
              buttonText: 'Зарегистрироваться',
              onTapMethod: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:dvij_flutter/elements/text_with_link.dart';
import 'package:dvij_flutter/navigation/custom_nav_containter.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import '../../app_state/appstate.dart';
import '../../elements/custom_snack_bar.dart';
import '../../themes/app_colors.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final AppState appState;
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

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool showLogInButton = false;
  bool privacyPolicyChecked = false;

  void updateShowLogInButton(bool newValue) {
    setState(() {
      showLogInButton = newValue;
    });
  }

  void togglePrivacyPolicyChecked() {
    setState(() {
      privacyPolicyChecked = !privacyPolicyChecked;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),

            Row(
              children: [

                Checkbox(
                  value: privacyPolicyChecked,
                  onChanged: (value) {
                    togglePrivacyPolicyChecked();
                  },
                ),
                const TextWithLink(
                    linkedText: 'политики конфиденциальности',
                    uri: '/privacy_policy',
                    text: 'Я согласен с правилами',
                )
              ],
            ),

            const SizedBox(height: 20.0),

            CustomButton(
                buttonText: 'Зарегистрироваться',
                onTapMethod: () async {

                  if (!privacyPolicyChecked){

                    showSnackBar('Вы не дали согласие на правила политики конфиденциальности!', AppColors.attentionRed, 2);

                  } else {

                    String email = emailController.text;
                    String password = passwordController.text;
                    // Регистрация пользователя
                    String? uid = await authWithEmail.createUserWithEmailAndPassword(email, password);

                    if (uid != null) {

                      if (uid == 'weak-password'){

                        showSnackBar(
                            "Ты используешь слабый пароль. Придумай надежнее",
                            AppColors.attentionRed,
                            2
                        );

                      } else if (uid == 'email-already-in-use'){

                        updateShowLogInButton(true);

                        showSnackBar(
                            "Пользователь уже существует",
                            AppColors.attentionRed,
                            2
                        );

                      } else if (uid == 'channel-error'){

                        showSnackBar(
                            "Обязательно заполните все поля!",
                            AppColors.attentionRed,
                            2
                        );

                      } else if (uid == 'invalid-email'){

                        showSnackBar(
                            "Некорректно введен Email",
                            AppColors.attentionRed,
                            2
                        );

                      } else {

                        showSnackBar(
                            "Регистрация успешно завершена! "
                                "Мы отправили на почту письмо с подтверждением Email-адреса. "
                                "Следуйте инструкции, чтобы завершить регистрацию",
                            Colors.green,
                            5
                        );

                        navigateToProfile();

                      }

                    } else {
                      // Обработка случая, когда создание пользователя не удалось
                      // Можно показать сообщение об ошибке или принять соответствующие меры
                    }
                  }

                  }


            ),

            if (showLogInButton) const SizedBox(height: 50.0),

            if (showLogInButton) Text(
              'Пользователь уже существует. Может ты хочешь войти?',
              style: Theme.of(context).textTheme.bodyMedium
            ),

            if (showLogInButton) const SizedBox(height: 20.0),

            if (showLogInButton) CustomButton(
              state: 'secondary',
              buttonText: 'Войти?',
              onTapMethod: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },

            ),
          ],
        ),
      ),
    );
  }
}


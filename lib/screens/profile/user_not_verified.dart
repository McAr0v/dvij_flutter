import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/screens/profile/registration_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class UserNotVerifiedScreen extends StatelessWidget {
  const UserNotVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Подтверди почту', style: Theme.of(context).textTheme.titleLarge,),
          const SizedBox(height: 15.0),
          Text(
            'Письмо с ссылкой для подтверждения уже в пути на твою почту. '
                'Пожалуйста, подтверди свой Email, чтобы активировать аккаунт!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 25.0),

          CustomButton(
              buttonText: 'Войти',
              onTapMethod: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
          ),

          const SizedBox(height: 50.0),

          Text(
            'Или ты не можешь получить доступ к указанной при регистрации почте и хочешь зарегистрироваться на другую?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 25.0),

          CustomButton(
              buttonText: 'Зарегистрироваться',
              state: CustomButtonState.secondary,
              onTapMethod: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                );
              }
          ),

        ],
      ),
    );
  }
}
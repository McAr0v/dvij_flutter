import 'package:dvij_flutter/screens/profile/registration_screen.dart';
import 'package:flutter/material.dart';
import '../../elements/custom_button.dart';
import 'login_screen.dart';


class UserNotSignInScreen extends StatelessWidget {
  const UserNotSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      //alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
      //color: AppColors.greyBackground,
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Войди или создай аккаунт', style: Theme.of(context).textTheme.titleLarge,),
        const SizedBox(height: 15.0),
        Text(
          'Добро пожаловать в наше приложение, где каждый может найти мероприятие по вкусу или создать свое собственное!',
          style: Theme.of(context).textTheme.bodyMedium,),

        const SizedBox(height: 15.0),
        Text(
          'Войди в аккаунт или зарегистрируйся, чтобы получить возможность пользоваться всеми функциями приложения.',
          style: Theme.of(context).textTheme.bodyMedium,),

        const SizedBox(height: 15.0),
        Text(
          'Погрузись в захватывающий мир событий прямо сейчас!',
          style: Theme.of(context).textTheme.bodyMedium,),

        const SizedBox(height: 25.0),

        CustomButton(
            buttonText: 'Войти',
            onTapMethod: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },

        ),

        const SizedBox(height: 15.0), // Добавлено дополнительное пространство между кнопками

        CustomButton(
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
    );
  }
}
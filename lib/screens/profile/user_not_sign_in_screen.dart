import 'package:dvij_flutter/screens/profile/registration_screen.dart';
import 'package:flutter/material.dart';

import '../../elements/custom_button.dart';
import '../../themes/app_colors.dart';
import 'login_screen.dart';


class UserNotSignInScreen extends StatelessWidget {
  const UserNotSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(20.0),
      color: AppColors.greyBackground,
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Войди или создай аккаунт', style: Theme.of(context).textTheme.titleLarge,),
        SizedBox(height: 15.0),
        Text('Страница аккаунта станет доступна после того, как ты сделаешь вход в свой аккаунт или зарегистрируешься', style: Theme.of(context).textTheme.bodyMedium,),
        SizedBox(height: 25.0),

        CustomButton(
            buttonText: 'Войти',
            onTapMethod: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },

        ),

        SizedBox(height: 15.0), // Добавлено дополнительное пространство между кнопками

        CustomButton(
          state: 'secondary',
          buttonText: 'Зарегистрироваться',
          onTapMethod: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistrationScreen()),
            );
          },

        ),
      ],
    ),
    );
  }
}
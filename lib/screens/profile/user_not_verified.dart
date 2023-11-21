import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';
import 'login_screen.dart';

class UserNotVerifiedScreen extends StatelessWidget {
  const UserNotVerifiedScreen({super.key});

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
          Text('Подтверди почту', style: Theme.of(context).textTheme.titleLarge,),
          SizedBox(height: 15.0),
          Text('Мы отправили на твой Email письмо с подтверждением. Подтверди Email и попробуй войти снова', style: Theme.of(context).textTheme.bodyMedium,),
          SizedBox(height: 25.0),

          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Войти', textAlign: TextAlign.center)
          ),
        ],
      ),
    );
  }
}
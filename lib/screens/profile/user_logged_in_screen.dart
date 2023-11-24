import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/appstate.dart';
import '../../authentication/auth_with_email.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/pop_up_dialog.dart';
import '../../navigation/custom_nav_containter.dart';

class UserLoggedInScreen extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthWithEmail authWithEmail = AuthWithEmail();

  UserLoggedInScreen({super.key});




  @override
  Widget build(BuildContext context) {
    // Получение uid из AppState

    String? uid = _auth.currentUser?.uid;

    void navigateToProfile() {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/Events', // Название маршрута, которое вы задаете в MaterialApp
            (route) => false,
      );
    }

    void showSnackBar(String message, Color color, int showTime) {
      final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User UID: ${uid ?? "N/A"}'),
            const SizedBox(height: 16.0),
            CustomButton(
              state: 'error',
              buttonText: 'Выйти из профиля',
              onTapMethod: () async {
                bool? confirmed = await PopUpDialog.showConfirmationDialog(
                  context,
                  title: "Вы действительно хотите выйти?",
                  backgroundColor: AppColors.greyBackground,
                  confirmButtonText: "Да",
                  cancelButtonText: "Нет",
                );
                if (confirmed != null && confirmed) {
                  String result = await authWithEmail.signOut();

                  if (result == 'success') {
                    showSnackBar(
                      'Как жаль, что ты уходишь! В любом случае, мы всегда будем рады видеть тебя снова. До скорой встречи!',
                      Colors.green,
                      5,
                    );
                    navigateToProfile();
                  } else {
                    showSnackBar(
                      'Что-то пошло не так при попытке выхода. Возможно, это заговор темных сил! Пожалуйста, попробуй еще раз, и если проблема сохранится, обратись в нашу техподдержку.',
                      AppColors.attentionRed,
                      5,
                    );
                  }
                }
              }

            ),
          ],
        ),
      ),
    );
  }
}
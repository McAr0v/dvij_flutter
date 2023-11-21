import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../elements/custom_snack_bar.dart';

class AuthWithEmail {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;



  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> createUserWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      // Пользователь успешно создан
      User? user = credential.user;

      // Отправляем письмо с подтверждением
      await user?.sendEmailVerification();

      // Возвращаем UID
      return user?.uid;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Предоставленный пароль слишком слаб.');
      } else if (e.code == 'email-already-in-use') {
        print('Учетная запись уже существует для этого адреса электронной почты.');
      }
      // В случае исключения возвращаем null
      return null;
    } catch (e) {
      print(e);
      // В случае исключения возвращаем null
      return null;
    }
  }

  Future<String?> signInWithEmailAndPassword(
      String emailAddress,
      String password,
      BuildContext context
      ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {

      print('Ошибка - Firebase Auth Error: ${e.code} - ${e.message}');

      if (e.code == 'wrong-password') {

        final snackBar = customSnackBar(message: "Вы ввели не правильный пароль", backgroundColor: AppColors.attentionRed);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      } else if (e.code == 'user-not-found') {

        final snackBar = customSnackBar(message: "Пользователь с таким Email не найден", backgroundColor: AppColors.attentionRed);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      } else if (e.code == 'too-many-requests') {

        final snackBar = customSnackBar(message: "Слишком много попыток входа. Мы заблокировали вход с вашего устройства. Попробуйте войти позже.", backgroundColor: AppColors.attentionRed, showTime: 10);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      }  else {

        final snackBar = customSnackBar(message: "Неизвестная нам ошибка( Попробуйте войти позже.", backgroundColor: Colors.yellow, showTime: 10);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      } return null;

    } catch (e) {
      print(e);
      return null;
    }
  }
}
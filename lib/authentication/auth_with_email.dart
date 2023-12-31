/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWithEmail {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;


  // **** ---- Функция выхода из аккаунта ---
  Future<String> signOut() async {
    try {
      await _auth.signOut();
      return 'success'; // Возвращаем 'success' в случае успешного выхода
    } catch (e) {
      //print("Error during sign out: $e");
      return e.toString(); // Возвращаем код ошибки в случае ошибки
    }
  }

  // *** ---- Функция создания пользователя через Email и пароль ----

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
      // --- Если ошибки, возвращаем коды ошибок ---
      if (e.code == 'weak-password') {
        return e.code;
      } else if (e.code == 'email-already-in-use') {
          return e.code;
      } else if (e.code == 'channel-error') {
        return e.code;
      } else if (e.code == 'invalid-email') {
        return e.code;
      } else {
        print(e.code);
        return null;
      }

    } catch (e) {
      print(e);
      // В случае исключения возвращаем null
      return null;
    }
  }

  // *** --- Вход в аккаунт ----

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
      // Если пользователь успешно вошел, возвращаем uid
      return credential.user?.uid;

    } on FirebaseAuthException catch (e) {

      // Если ошибки, возвращаем коды ошибок

      //print('Ошибка - Firebase Auth Error: ${e.code} - ${e.message}');

      if (e.code == 'wrong-password') {

        return e.code;

      } else if (e.code == 'user-not-found') {

        return e.code;

      } else if (e.code == 'too-many-requests') {

        return e.code;

      } else if (e.code == 'channel-error') {

        return e.code;

      } else if (e.code == 'invalid-email') {

        return e.code;

      } else {

        print(e.code);

        return null;

      }

    } catch (e) {
      print(e);
      return null;
    }
  }

  // **** ---- СБРОС ПАРОЛЯ -----

  Future<String?> resetPassword(String emailAddress) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: emailAddress,
      );

      // Если успешно отправлено письмо, возвращаем success
      return 'success';

    } on FirebaseAuthException catch (e) {

      // Если ошибки, возвращаем коды ошибок

      if (e.code == 'invalid-email') {
        return e.code;
      } else if (e.code == 'user-not-found') {
        return e.code;
      } else {
        print(e.code);

        return e.code;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}*/
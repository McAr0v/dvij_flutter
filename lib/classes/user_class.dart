import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class UserCustom {
  String uid;
  String email;
  String role;
  String name;
  String lastname;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  String city;
  String birthDate; // Формат даты (например, "yyyy-MM-dd")
  String gender;
  String avatar;

  // Статическая переменная для хранения текущего пользователя
  static UserCustom? currentUser;

  // --- ИНИЦИАЛИЗИРУЕМ БАЗУ ДАННЫХ -----
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  /*final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;*/

  UserCustom({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.lastname,
    required this.phone,
    required this.whatsapp,
    required this.telegram,
    required this.instagram,
    required this.city,
    required this.birthDate,
    required this.gender,
    required this.avatar,
  });

  factory UserCustom.empty(String uid, String email) {
    return UserCustom(
      uid: uid,
      email: email,
      role: '1113',
      name: '',
      lastname: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      city: '',
      birthDate: '',
      gender: '',
      avatar: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7'
    );
  }

  // Метод для обновления данных текущего пользователя
  static void updateCurrentUser(UserCustom updatedUser) {
    currentUser = updatedUser;
  }

  // ---- Функция выхода из аккаунта ---
  static Future<String> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      currentUser = null; // Обнуляем текущего пользователя при выходе
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // ---- Функция создания пользователя через Email и пароль ----

  static Future<String?> createUserWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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

  // --- Вход в аккаунт ----

  static Future<String?> signInWithEmailAndPassword(
      String emailAddress,
      String password,
      BuildContext context
      ) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      // Если пользователь успешно вошел, обновляем текущего пользователя
      currentUser = await readUserData(credential.user!.uid);

      // и возвращаем uid
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

  // ---- СБРОС ПАРОЛЯ -----

  static Future<String?> resetPassword(String emailAddress) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
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

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ ПОЛЬЗОВАТЕЛЯ -----
  static Future<String?> writeUserData(UserCustom user) async {

    try {
      // Создаем путь для пользователя в базе данных
      String userPath = 'users/${user.uid}/user_info';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(userPath).set({
        'uid': user.uid,
        'email': user.email,
        'role': user.role,
        'name': user.name,
        'lastname': user.lastname,
        'phone': user.phone,
        'whatsapp': user.whatsapp,
        'telegram': user.telegram,
        'instagram': user.instagram,
        'city': user.city,
        'birth_date': user.birthDate,
        'gender': user.gender,
        'avatar': user.avatar,
      });

      currentUser = user; // Обновляем текущего пользователя

      // Если успешно
      return 'success';

    } catch (e) {
      // Если ошибки
      // TODO Сделать обработку ошибок. Наверняка есть какие то, которые можно различать и писать что случилось
      print('Error writing user data: $e');
      return 'Failed to write user data. Error: $e';
    }
  }

  // ---- ФУНКЦИЯ ЧТЕНИЯ ИНФОРМАЦИИ О ПОЛЬЗОВАТЕЛЕ -----

  static Future<UserCustom?> readUserData(String uid) async {
    try {
      // Путь к данным пользователя
      String userPath = 'users/$uid/user_info';

      // Считываем данные
      DatabaseEvent snapshot = await FirebaseDatabase.instance.ref().child(userPath).once();

      // Получаем значение и заполняем как User
      Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        UserCustom user = UserCustom(
          uid: data['uid'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? '',
          name: data['name'] ?? '',
          lastname: data['lastname'] ?? '',
          phone: data['phone'] ?? '',
          whatsapp: data['whatsapp'] ?? '',
          telegram: data['telegram'] ?? '',
          instagram: data['instagram'] ?? '',
          city: data['city'] ?? '',
          birthDate: data['birth_date'] ?? '',
          gender: data['gender'] ?? '',
          avatar: data['avatar'] ?? '',
        );

        currentUser = user; // Обновляем текущего пользователя

        return user;
      } else {

        currentUser = null; // Обнуляем текущего пользователя
        return null; // Возвращаем null, если данных нет
      }
    } catch (e) {
      print('Error reading user data: $e');
      return null; // Возвращаем null в случае ошибки
    }
  }

}
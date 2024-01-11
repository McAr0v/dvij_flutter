import 'package:dvij_flutter/classes/place_role_class.dart';
import 'package:dvij_flutter/classes/role_in_app.dart';
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
  String? roleInPlace;

  // Статическая переменная для хранения текущего пользователя
  static UserCustom? currentUser;
  // Статическая переменная для хранения списка ролей
  static List<RoleInApp> currentUsersList = [];

  static int accessLevel = 10;

  // --- ИНИЦИАЛИЗИРУЕМ БАЗУ ДАННЫХ -----
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

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
    this.roleInPlace
  });

  factory UserCustom.empty(String uid, String email) {
    return UserCustom(
      uid: uid,
      email: email,
      role: '-Nm5r9zW9P9cMDCYRjP3',
      name: '',
      lastname: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      city: '',
      birthDate: '',
      gender: '',
      avatar: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7',
      roleInPlace: ''
    );
  }

  factory UserCustom.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot uidSnapshot = snapshot.child('uid');
    DataSnapshot emailSnapshot = snapshot.child('email');
    DataSnapshot roleSnapshot = snapshot.child('role');
    DataSnapshot nameSnapshot = snapshot.child('name');
    DataSnapshot lastnameSnapshot = snapshot.child('lastname');
    DataSnapshot phoneSnapshot = snapshot.child('phone');
    DataSnapshot whatsappSnapshot = snapshot.child('whatsapp');
    DataSnapshot telegramSnapshot = snapshot.child('telegram');
    DataSnapshot instagramSnapshot = snapshot.child('instagram');
    DataSnapshot citySnapshot = snapshot.child('city');
    DataSnapshot birthDateSnapshot = snapshot.child('birthDate');
    DataSnapshot genderSnapshot = snapshot.child('gender');
    DataSnapshot avatarSnapshot = snapshot.child('avatar');

    // Берем из них данные и заполняем в класс Gender И возвращаем его
    return UserCustom(
      uid: uidSnapshot.value.toString() ?? '',
      email: emailSnapshot.value.toString() ?? '',
      role: roleSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
      lastname: lastnameSnapshot.value.toString() ?? '',
      phone: phoneSnapshot.value.toString() ?? '',
      whatsapp: whatsappSnapshot.value.toString() ?? '',
      telegram: telegramSnapshot.value.toString() ?? '',
      instagram: instagramSnapshot.value.toString() ?? '',
      city: citySnapshot.value.toString() ?? '',
      birthDate: birthDateSnapshot.value.toString() ?? '',
      gender: genderSnapshot.value.toString() ?? '',
      avatar: avatarSnapshot.value.toString() ?? ''
    );
  }

  // Метод для обновления данных текущего пользователя
  static void updateCurrentUser(UserCustom updatedUser) {
    currentUser = updatedUser;
    updateAccessLevel(updatedUser.role);
  }

  // Метод для обновления данных списка пользователей
  static void updateUsersList() async {

    currentUsersList = await getAllUsers() as List<RoleInApp>;
  }

  static void updateAccessLevel(String userRoleInApp) {
    switch (userRoleInApp)
    {
      case '-Nm5qtfg-e8VVBXkYC0y': accessLevel = 100; // God
      case '-Nm5r2Uly1Z7vCapTSpR': accessLevel = 90; // Admin
      case '-Nm5r-UN3QKNrMqBT--C': accessLevel = 80; // Manager
      case '-Nm5r9zW9P9cMDCYRjP3': accessLevel = 20; // RegisteredUser
      default: accessLevel = 10;

    }

  }

  // ---- Функция выхода из аккаунта ---
  static Future<String> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      currentUser = null; // Обнуляем текущего пользователя при выходе
      updateAccessLevel('');
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
      currentUser = await readUserDataAndWriteCurrentUser(credential.user!.uid);
      updateAccessLevel(currentUser!.role);

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
  static Future<String?> writeUserData(UserCustom user, {bool notAdminChanges = true}) async {

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

      if (notAdminChanges)
        {
          currentUser = user; // Обновляем текущего пользователя
          updateAccessLevel(user.role);
        }


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

  static Future<UserCustom?> readUserDataAndWriteCurrentUser(String uid) async {
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
        updateAccessLevel(user.role);

        return user;
      } else {

        currentUser = null; // Обнуляем текущего пользователя
        updateAccessLevel('');
        return null; // Возвращаем null, если данных нет
      }
    } catch (e) {
      print('Error reading user data: $e');
      return null; // Возвращаем null в случае ошибки
    }
  }

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

        return user;
      } else {
        return null; // Возвращаем null, если данных нет
      }
    } catch (e) {
      print('Error reading user data: $e');
      return null; // Возвращаем null в случае ошибки
    }
  }

  // Метод для получения списка ролей из Firebase

  static Future<List<UserCustom>> getAllUsers({bool order = true}) async {

    List<UserCustom> users = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа роли
    // и нам нужен каждая роль, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем роль (RoleInApp.fromSnapshot) из снимка данных
      // и добавляем в список ролей
      users.add(UserCustom.fromSnapshot(childSnapshot.child('user_info')));
    }

    sortUsersByEmail(users, order);

    // Возвращаем список
    return users;
  }

  static void sortUsersByEmail(List<UserCustom> users, bool order) {

    if (order) {
      users.sort((a, b) => a.email.compareTo(b.email));
    } else {
      users.sort((a, b) => b.email.compareTo(a.email));
    }
  }

  static void sortUsersByName(List<UserCustom> users, bool order) {

    if (order) {
      users.sort((a, b) => a.name.compareTo(b.name));
    } else {
      users.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  static Future<UserCustom?> getUserByEmail(String email) async {

    UserCustom user = UserCustom.empty('', '');

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      UserCustom randomUser = UserCustom.fromSnapshot(childSnapshot.child('user_info'));

      if (randomUser.email == email) {
        return randomUser;
      }
    }

    // Возвращаем список
    return null;
  }

  static Future<String?> writeUserPlaceRole(String userId, String placeId, String roleId) async {

    try {
      // Создаем путь для пользователя в базе данных
      String userPath = 'users/$userId/placeManager/$placeId';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(userPath).set({
        'placeId': placeId,
        'roleId': roleId,
      });

      // Если успешно
      return 'success';

    } catch (e) {
      // Если ошибки
      // TODO Сделать обработку ошибок. Наверняка есть какие то, которые можно различать и писать что случилось
      print('Error writing user data: $e');
      return 'Failed to write user data. Error: $e';
    }
  }

  static Future<String?> deleteUserPlaceRole(String userId, String placeId) async {

    try {
      // Создаем путь для пользователя в базе данных
      String userPath = 'users/$userId/placeManager/$placeId';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(userPath).remove();

      // Если успешно
      return 'success';

    } catch (e) {
      // Если ошибки
      // TODO Сделать обработку ошибок. Наверняка есть какие то, которые можно различать и писать что случилось
      print('Error writing user data: $e');
      return 'Failed to write user data. Error: $e';
    }
  }

  static Future<List<UserCustom>> getPlaceAdminsUsers(String placeId, {bool order = true}) async {

    List<UserCustom> users = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/managers');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа роли
    // и нам нужен каждая роль, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем роль (RoleInApp.fromSnapshot) из снимка данных
      // и добавляем в список ролей

      DataSnapshot userIdSnapshot = childSnapshot.child('userId');
      DataSnapshot roleIdSnapshot = childSnapshot.child('roleId');

      if (userIdSnapshot.exists) {
        UserCustom? user = await readUserData(userIdSnapshot.value.toString());
        if (user != null) {
          if(roleIdSnapshot.exists){
            user.roleInPlace = roleIdSnapshot.value.toString();
          } else {
            user.roleInPlace = 'Роль не найдена';
          }

          users.add(user);

        }
      }

    }

    if (users.length > 1) {
      sortUsersByEmail(users, order);
    }


    // Возвращаем список
    return users;
  }

  static Future<PlaceRole> getPlaceRoleInUserById(String placeId, String userId) async {

    PlaceRole result = PlaceRole(name: '', id: '', desc: '', controlLevel: '');

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/managers');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа роли
    // и нам нужен каждая роль, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем роль (RoleInApp.fromSnapshot) из снимка данных
      // и добавляем в список ролей

      DataSnapshot userIdSnapshot = childSnapshot.child('userId');
      DataSnapshot roleIdSnapshot = childSnapshot.child('roleId');

      if (userIdSnapshot.exists) {
        if (userIdSnapshot.value.toString() == userId) {
          return PlaceRole.getPlaceRoleFromListById(roleIdSnapshot.value.toString());
        }
      }

    }

    // Возвращаем список
    return result;
  }

}
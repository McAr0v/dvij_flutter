import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/current_user/app_role.dart';
import 'package:dvij_flutter/current_user/genders_class.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/classes/role_in_app.dart';
import 'package:firebase_database/firebase_database.dart';
import '../authentication/user_auth.dart';
import '../database/database_mixin.dart';

class UserCustom with MixinDatabase, UserAuthMixin {
  String uid;
  String email;
  AppRole role;
  String name;
  String lastname;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  City city;
  DateTime birthDate; // Формат даты (например, "yyyy-MM-dd")
  Genders gender;
  String avatar;
  String? roleInPlace;
  DateTime registrationDate;
  List<String> myEvents;
  List<String> myPlaces;
  List<String> myPromos;
  List<String> favPlaces;
  List<String> favEvents;
  List<String> favPromos;

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
    required this.registrationDate,
    required this.myEvents,
    required this.myPlaces,
    required this.myPromos,
    required this.favEvents,
    required this.favPlaces,
    required this.favPromos,
    this.roleInPlace
  });

  factory UserCustom.empty() {
    return UserCustom(
      uid: '',
      email: '',
      role: AppRole(),
      name: '',
      lastname: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      city: City.emptyCity,
      birthDate: DateTime(2100),
      gender: Genders(),
      avatar: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7',
      roleInPlace: '',
      registrationDate: DateTime.now(),
      myEvents: [],
      myPlaces: [],
      myPromos: [],
      favEvents: [],
      favPlaces: [],
      favPromos: []
    );
  }

  factory UserCustom.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям

    DataSnapshot infoSnapshot = snapshot.child('user_info');

    City city = City.emptyCity;
    city = city.getEntityByIdFromList(infoSnapshot.child('city').value.toString());

    Genders gender = Genders();
    gender.switchEnumFromString(infoSnapshot.child('gender').value.toString());

    AppRole appRole = AppRole();
    appRole.setRoleFromDb(infoSnapshot.child('role').value.toString());

    // Берем из них данные и заполняем в класс Gender И возвращаем его
    return UserCustom(
      uid: infoSnapshot.child('uid').value.toString(),
      email: infoSnapshot.child('email').value.toString(),
      role: appRole,
      name: infoSnapshot.child('name').value.toString(),
      lastname: infoSnapshot.child('lastname').value.toString(),
      phone: infoSnapshot.child('phone').value.toString(),
      whatsapp: infoSnapshot.child('whatsapp').value.toString(),
      telegram: infoSnapshot.child('telegram').value.toString(),
      instagram: infoSnapshot.child('instagram').value.toString(),
      city: city,
      birthDate: DateMixin.getDateFromString(infoSnapshot.child('birthDate').value.toString()),
      gender: gender,
      avatar: infoSnapshot.child('avatar').value.toString(),
      registrationDate: DateMixin.getDateFromString(infoSnapshot.child('registrationDate').value.toString()),
      myEvents: [],
      myPromos: [],
      myPlaces: [],
      favPromos: [],
      favPlaces: [],
      favEvents: []
    );
  }

  Future<String> signOut() async {
    return await signOutInMixin();
  }

  Future<String?> createUser(String email, String password) async {
    return await createUserWithEmailAndPassword(email, password);
  }

  Future<String?> signIn(String email, String password) async{
    return await signInWithEmailAndPassword(email, password);
  }

  Future<String?> resetPassword(String email) async {
    return await resetPasswordInMixin(email);
  }

  // Метод для обновления данных текущего пользователя
  static void updateCurrentUser(UserCustom updatedUser) {
    currentUser = updatedUser;
    //updateAccessLevel(updatedUser.role);
  }

  // Метод для обновления данных списка пользователей
  static void updateUsersList() async {

    currentUsersList = await getAllUsers() as List<RoleInApp>;
  }

  /*static void updateAccessLevel(String userRoleInApp) {
    switch (userRoleInApp)
    {
      case '-Nm5qtfg-e8VVBXkYC0y': accessLevel = 100; // God
      case '-Nm5r2Uly1Z7vCapTSpR': accessLevel = 90; // Admin
      case '-Nm5r-UN3QKNrMqBT--C': accessLevel = 80; // Manager
      case '-Nm5r9zW9P9cMDCYRjP3': accessLevel = 20; // RegisteredUser
      default: accessLevel = 10;

    }

  }*/

  Map<String, dynamic> generateEntityDataCode(){
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'role': role.getRoleNameInString(roleEnum: role.role),
      'name': name,
      'lastname': lastname,
      'phone': phone,
      'whatsapp': whatsapp,
      'telegram': telegram,
      'instagram': instagram,
      'city': city.id,
      'birthDate': DateMixin.generateDateString(birthDate),
      'gender': gender.getGenderString(),
      'avatar': avatar,
      'registrationDate' : DateMixin.generateDateString(registrationDate)
    };
  }

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ ПОЛЬЗОВАТЕЛЯ -----
  Future<String> publishUserToDb({bool notAdminChanges = true}) async {

    String userPath = 'users/$uid/user_info';
    Map<String, dynamic> data = generateEntityDataCode();

    String result = await MixinDatabase.publishToDB(userPath, data);

    if (notAdminChanges)
    {
      currentUser = this; // Обновляем текущего пользователя
      //updateAccessLevel(user.role);
    }

    return result;
  }

  // ---- ФУНКЦИЯ ЧТЕНИЯ ИНФОРМАЦИИ О ПОЛЬЗОВАТЕЛЕ -----

  static Future<UserCustom?> readUserDataAndWriteCurrentUser({required String uid, bool onlyRead = false}) async {

    UserCustom user = UserCustom.empty();

    String userPath = 'users/$uid';

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(userPath);

    if (snapshot != null) {
      user = UserCustom.fromSnapshot(snapshot);
      if (!onlyRead){
        //updateAccessLevel(user.role);
        currentUser = user; // Обновляем текущего пользователя
      }
      return user;
    }

    return user;
  }

  /*static Future<UserCustom?> readUserData(String uid) async {
    try {
      // Путь к данным пользователя
      String userPath = 'users/$uid/user_info';

      // Считываем данные
      DatabaseEvent snapshot = await FirebaseDatabase.instance.ref().child(userPath).once();

      // Получаем значение и заполняем как User
      Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {

        Genders gender = Genders();
        gender.switchEnumFromString(data['gender']);

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
          gender: gender,
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
  }*/

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

    UserCustom user = UserCustom.empty();

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

  static Future<UserCustom> getUserById(String id) async {

    UserCustom user = UserCustom.empty();

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

      if (randomUser.uid == id) {
        return randomUser;
      }
    }

    // Возвращаем список
    return user;
  }

  /*static Future<String?> writeUserPlaceRole(String userId, String placeId, String roleId) async {

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
  }*/

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
        //UserCustom? user = await readUserData(userIdSnapshot.value.toString());
        UserCustom? user = await readUserDataAndWriteCurrentUser(uid: userIdSnapshot.value.toString(), onlyRead: true);
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



  /*static Future<PlaceRole> getPlaceRoleInUserById(String placeId, String userId) async {

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
  }*/

}
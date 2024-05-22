import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/constants/constants.dart';
import 'package:dvij_flutter/current_user/app_role.dart';
import 'package:dvij_flutter/current_user/genders_class.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/users_mixin/users_lists_mixin.dart';
import 'package:firebase_database/firebase_database.dart';
import '../authentication/user_auth.dart';
import '../database/database_mixin.dart';

class UserCustom with MixinDatabase, UserAuthMixin, UsersListsMixin {
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
  DateTime birthDate;
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


  static UserCustom? currentUser;


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
      avatar: AppConstants.defaultAvatar,
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

  Future<UserCustom?> readUserDataFromDb({required String uid, bool onlyRead = false}) async {

    UserCustom user = UserCustom.empty();

    String userPath = 'users/$uid';

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(userPath);

    if (snapshot != null) {
      user = UserCustom.fromSnapshot(snapshot);
      if (!onlyRead){
        //updateAccessLevel(user.role);
        currentUser = user; // Обновляем текущего пользователя
      }
    }
    return user;
  }

  Future<UserCustom> getUserByEmailOrId({String email = '', String uid = ''}) async {

    List<UserCustom> usersList = [];

    // Если мы уже ранее подгружали пользователей
    if (UsersListsMixin.downloadedUsers.isNotEmpty) {
      usersList = UsersListsMixin.downloadedUsers;
    } else {
      // Если не подгружали, подгружаем
      usersList = await getAllUsersFromDb(order: true);
    }

    // Проходимся по всему списку пользователей и ищем нашего
    for (UserCustom randomUser in usersList){
      if (email.isNotEmpty) {
        if (randomUser.email == email) return randomUser;
      } else {
        if (randomUser.uid == uid) return randomUser;
      }

    }

    // Возвращаем список
    return UserCustom.empty();
  }

}
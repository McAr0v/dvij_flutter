import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/constants/constants.dart';
import 'package:dvij_flutter/current_user/app_role.dart';
import 'package:dvij_flutter/current_user/fav_list_mixin.dart';
import 'package:dvij_flutter/current_user/genders_class.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/places/users_my_place/my_places_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:dvij_flutter/users_mixin/users_lists_mixin.dart';
import 'package:firebase_database/firebase_database.dart';
import '../authentication/user_auth.dart';
import '../database/database_mixin.dart';

class UserCustom with MixinDatabase, UserAuthMixin, UsersListsMixin, FavListsMixin {
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
  DateTime registrationDate;
  List<MyPlaces> myPlaces;

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
    required this.myPlaces,
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
      city: City.empty(),
      birthDate: DateTime(2100),
      gender: Genders(),
      avatar: AppConstants.defaultAvatar,
      registrationDate: DateTime.now(),
      myPlaces: [],
    );
  }

  factory UserCustom.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям

    DataSnapshot infoSnapshot = snapshot.child(AppConstants.userInfoFolderPath);

    City city = City.empty();
    city = city.getEntityByIdFromList(infoSnapshot.child(AppConstants.userCityProperty).value.toString());

    Genders gender = Genders();
    gender.switchEnumFromString(infoSnapshot.child(AppConstants.userGenderProperty).value.toString());

    AppRole appRole = AppRole();
    appRole.setRoleFromDb(infoSnapshot.child(AppConstants.userRoleProperty).value.toString());

    List<MyPlaces> myPlaces = FavListsMixin.getMyPlacesEntities(snapshot.child(AppConstants.myPlacePathKey));


    // Берем из них данные и заполняем в класс Gender И возвращаем его
    return UserCustom(
      uid: infoSnapshot.child(AppConstants.userUidProperty).value.toString(),
      email: infoSnapshot.child(AppConstants.userEmailProperty).value.toString(),
      role: appRole,
      name: infoSnapshot.child(AppConstants.userNameProperty).value.toString(),
      lastname: infoSnapshot.child(AppConstants.userLastnameProperty).value.toString(),
      phone: infoSnapshot.child(AppConstants.userPhoneProperty).value.toString(),
      whatsapp: infoSnapshot.child(AppConstants.userWhatsappProperty).value.toString(),
      telegram: infoSnapshot.child(AppConstants.userTelegramProperty).value.toString(),
      instagram: infoSnapshot.child(AppConstants.userInstagramProperty).value.toString(),
      city: city,
      birthDate: DateMixin.getDateFromString(infoSnapshot.child(AppConstants.userBirthDateProperty).value.toString()),
      gender: gender,
      avatar: infoSnapshot.child(AppConstants.userAvatarProperty).value.toString(),
      registrationDate: DateMixin.getDateFromString(infoSnapshot.child(AppConstants.userRegistrationDateProperty).value.toString()),
      myPlaces: myPlaces,
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
  }

  Map<String, dynamic> generateEntityDataCode(){
    return <String, dynamic>{
      AppConstants.userUidProperty: uid,
      AppConstants.userEmailProperty: email,
      AppConstants.userRoleProperty: role.getRoleNameInString(roleEnum: role.role),
      AppConstants.userNameProperty: name,
      AppConstants.userLastnameProperty: lastname,
      AppConstants.userPhoneProperty: phone,
      AppConstants.userWhatsappProperty: whatsapp,
      AppConstants.userTelegramProperty: telegram,
      AppConstants.userInstagramProperty: instagram,
      AppConstants.userCityProperty: city.id,
      AppConstants.userBirthDateProperty: DateMixin.generateDateString(birthDate),
      AppConstants.userGenderProperty: gender.getGenderString(),
      AppConstants.userAvatarProperty: avatar,
      AppConstants.userRegistrationDateProperty : DateMixin.generateDateString(registrationDate)
    };
  }

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ ПОЛЬЗОВАТЕЛЯ -----
  Future<String> publishUserToDb({bool notAdminChanges = true}) async {

    String userPath = '${AppConstants.usersFolderPath}/$uid/${AppConstants.userInfoFolderPath}';
    Map<String, dynamic> data = generateEntityDataCode();

    String result = await MixinDatabase.publishToDB(userPath, data);

    if (notAdminChanges)
    {
      currentUser = this;
    }

    return result;
  }

  PlaceUserRole getPlaceRoleFromMyPlaces(String placeId){

    if (placeId.isNotEmpty){
      if (currentUser != null && currentUser!.myPlaces.isNotEmpty){
        for (MyPlaces tempPlace in currentUser!.myPlaces){

          if (tempPlace.placeId == placeId){
            return tempPlace.placeRole;
          }
        }
      }
    }

    return PlaceUserRole();

  }

  void deletePlaceFromMy(String id){
    if (myPlaces.any((place) => place.placeId == id)){
      myPlaces.removeWhere((place) => place.placeId == id);
    }
  }

  void addPlaceToMy(String id){

    PlaceUserRole placeRole = PlaceUserRole();
    placeRole = placeRole.getPlaceUserRole(PlaceUserRoleEnum.creator);

    if (!myPlaces.any((place) => place.placeId == id)) {
      myPlaces.add(MyPlaces(placeId: id, placeRole: placeRole));
    }

  }

  // ---- ФУНКЦИЯ ЧТЕНИЯ ИНФОРМАЦИИ О ПОЛЬЗОВАТЕЛЕ -----

  Future<UserCustom?> readUserDataFromDb({required String uid, bool onlyRead = false}) async {

    UserCustom user = UserCustom.empty();

    String userPath = '${AppConstants.usersFolderPath}/$uid';

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(userPath);

    if (snapshot != null) {
      user = UserCustom.fromSnapshot(snapshot);
      if (!onlyRead){
        currentUser = user;
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
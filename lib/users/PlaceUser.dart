import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:firebase_database/firebase_database.dart';

import '../database/database_mixin.dart';

class PlaceUser {
  String uid = '';
  String email = '';
  String name = '';
  String lastname = '';
  String avatar = '';
  PlaceUserRole roleInPlace = PlaceUserRole();

  PlaceUser({String? uid, String? email, String? name, String? lastname, String? avatar, PlaceUserRole? roleInPlace}){
    this.uid = uid ?? '';
    this.email = email ?? '';
    this.name = name ?? '';
    this.lastname = lastname ?? '';
    this.avatar = avatar ?? 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7';
    this.roleInPlace = roleInPlace ?? PlaceUserRole();
  }

  factory PlaceUser.fromSnapshot(DataSnapshot snapshot) {
    PlaceUserRole placeUserRole = PlaceUserRole();
    return PlaceUser(
      uid: snapshot.child('uid').value.toString(),
      email: snapshot.child('email').value.toString(),
      name: snapshot.child('name').value.toString(),
      lastname: snapshot.child('lastname').value.toString(),
      avatar: snapshot.child('avatar').value.toString(),
      // Роль пользователя заполняется в функции [getPlaceUserFromDb]
      roleInPlace: PlaceUserRole()
    );
  }

  /// Функция получения информации управляющих заведением
  /// <br><br>
  /// Принимает [String] uid пользователя, по которому будет считывать данные о пользователе
  /// <br>
  /// И [String] placeRole пользователя, по которому назначит роль
  /// <br><br>
  /// Вернет заполненного пользователя
  Future<PlaceUser> getPlaceUserFromDb(String uid, String placeRole) async {

    PlaceUser returnedUser = PlaceUser();
    PlaceUserRole placeUserRole = PlaceUserRole();

    String userPath = 'users/$uid/user_info';

    DataSnapshot? userSnapshot = await MixinDatabase.getInfoFromDB(userPath);
    if (userSnapshot != null){
      // Читаем имя, фамилию, аватарку пользователя
      returnedUser = PlaceUser.fromSnapshot(userSnapshot);
      // Заполняем роль пользователя
      returnedUser.roleInPlace = placeUserRole.getPlaceUserRole(placeUserRole.getPlaceUserEnumFromString(placeRole));
    }
    return returnedUser;
  }



}

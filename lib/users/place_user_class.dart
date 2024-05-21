import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/users/place_admins_item_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:firebase_database/firebase_database.dart';

import '../database/database_mixin.dart';

class PlaceUser {
  String uid = '';
  String email = '';
  String name = '';
  String lastname = '';
  String avatar = '';
  PlaceUserRole placeUserRole = PlaceUserRole();

  PlaceUser({String? uid, String? email, String? name, String? lastname, String? avatar, PlaceUserRole? roleInPlace}){
    this.uid = uid ?? '';
    this.email = email ?? '';
    this.name = name ?? '';
    this.lastname = lastname ?? '';
    this.avatar = avatar ?? 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7';
    this.placeUserRole = roleInPlace ?? PlaceUserRole();
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
  Future<PlaceUser> getPlaceUserFromDb(String uid, PlaceUserRoleEnum placeRole) async {

    PlaceUser returnedUser = PlaceUser();
    PlaceUserRole placeUserRole = PlaceUserRole();

    String userPath = 'users/$uid/user_info';

    DataSnapshot? userSnapshot = await MixinDatabase.getInfoFromDB(userPath);
    if (userSnapshot != null){
      // Читаем имя, фамилию, аватарку пользователя
      returnedUser = PlaceUser.fromSnapshot(userSnapshot);
      // Заполняем роль пользователя
      returnedUser.placeUserRole = placeUserRole.getPlaceUserRole(placeRole);
    }
    return returnedUser;
  }

  Future<List<PlaceUser>> getAdminsInfoFromDb(List<PlaceAdminsListItem> adminsList) async {
    List<PlaceUser> admins = [];

    for (PlaceAdminsListItem admin in adminsList){

      PlaceUser tempUser = PlaceUser();
      tempUser = await tempUser.getPlaceUserFromDb(admin.userId, admin.placeRole.roleInPlaceEnum);
      if (tempUser != PlaceUser()){
        admins.add(tempUser);
      }
    }
    return admins;
  }

  PlaceUser getCurrentUserRoleInPlace(UserCustom currentUser, List<PlaceUser> admins){
    PlaceUserRole role = PlaceUserRole();

    PlaceUser user = PlaceUser(
      uid: currentUser.uid,
      email: currentUser.email,
      name: currentUser.name,
      lastname: currentUser.lastname,
      avatar: currentUser.avatar,
      roleInPlace: role.getPlaceUserRole(PlaceUserRoleEnum.reader)
    );

    for(PlaceUser admin in admins){
      if (admin.uid == user.uid) {
        user.placeUserRole = admin.placeUserRole;
        break;
      }
    }

    return user;
  }

  Future<PlaceUser> getPlaceUserByEmail(String email) async {

    PlaceUser user = PlaceUser();

    DataSnapshot? usersSnapshot = await MixinDatabase.getInfoFromDB('users');
    
    if (usersSnapshot != null){
      
      for (var idFolders in usersSnapshot.children){
        String tempEmail = idFolders.child('user_info').child('email').value.toString();
        if (tempEmail == email){
          return PlaceUser.fromSnapshot(idFolders.child('user_info'));
        }
      }
      
    }

    return user;

  }

  PlaceUser generatePlaceUserFromUserCustom (UserCustom user) {
    return PlaceUser(
      uid: user.uid,
      email: user.email,
      name: user.name,
      lastname: user.lastname,
      avatar: user.avatar
    );
  }

  Future<String> writePlaceRoleInManagerAndPlace(String placeId) async {

    String result = 'success';
    String userPath = 'users/$uid/myPlaces/$placeId';
    String placePath = 'places/$placeId/managers/$uid';

    String publishInUser = await MixinDatabase.publishToDB(userPath, {
      'placeId': placeId,
      'roleId': placeUserRole.roleInPlaceEnum.name
    });

    String publishInPlace = await MixinDatabase.publishToDB(placePath, {
      'userId': uid,
      'roleId': placeUserRole.roleInPlaceEnum.name
    });

    if (publishInPlace != 'success'){
      result = publishInPlace;
    } else if (publishInUser != 'success') {
      result = publishInUser;
    }

    return result;


  }

  Future<String> deletePlaceRoleInManagerAndPlace(String placeId) async {

    String result = 'success';
    String userPath = 'users/$uid/myPlaces/$placeId';
    String placePath = 'places/$placeId/managers/$uid';

    String publishInUser = await MixinDatabase.deleteFromDb(userPath);

    String publishInPlace = await MixinDatabase.deleteFromDb(placePath);

    if (publishInPlace != 'success'){
      result = publishInPlace;
    } else if (publishInUser != 'success') {
      result = publishInUser;
    }

    return result;


  }

}

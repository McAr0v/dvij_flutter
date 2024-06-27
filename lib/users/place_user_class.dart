import 'package:dvij_flutter/constants/constants.dart';
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
    this.avatar = avatar ?? AppConstants.defaultAvatar;
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

  Future<List<PlaceUser>> getAdminsFromDb(String placeId) async {
    List<PlaceUser> admins = [];

    String usersPath = 'users';

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(usersPath);

    if (snapshot != null) {
      for (var childSnapshot in snapshot.children) {
        // Указываем путь к нужному заведению в моих завдеениях каждого пользователя
        var myPlacesFolder = childSnapshot.child('myPlaces').child(placeId);

        // Если такоя папка есть
        if (myPlacesFolder.exists) {
          // Читаем роль в заведении в БД
          String roleId = myPlacesFolder
              .child('roleId')
              .value
              .toString();

          // Устанавливаем нашу роль
          PlaceUserRole placeRole = PlaceUserRole();
          placeRole = placeRole.getPlaceUserRole(
              placeRole.getPlaceUserEnumFromString(roleId));

          PlaceUser tempUser = PlaceUser.fromSnapshot(
              childSnapshot.child('user_info'));
          tempUser.placeUserRole = placeRole;

          admins.add(tempUser);
        }
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

  Future<PlaceUser> getPlaceUserByEmail(String email, String placeId) async {

    PlaceUser user = PlaceUser();

    DataSnapshot? usersSnapshot = await MixinDatabase.getInfoFromDB('users');
    
    if (usersSnapshot != null){
      
      for (var idFolders in usersSnapshot.children) {
        String tempEmail = idFolders
            .child('user_info')
            .child('email')
            .value
            .toString();
        if (tempEmail == email) {
          user = PlaceUser.fromSnapshot(idFolders.child('user_info'));

          var myPlacesFolder = idFolders.child('myPlaces').child(placeId);

          // Если такоя папка есть
          if (myPlacesFolder.exists) {
            // Читаем роль в заведении в БД
            String roleId = myPlacesFolder
                .child('roleId')
                .value
                .toString();

            // Устанавливаем нашу роль
            PlaceUserRole placeRole = PlaceUserRole();
            placeRole = placeRole.getPlaceUserRole(
                placeRole.getPlaceUserEnumFromString(roleId));
            user.placeUserRole = placeRole;
          }
          return user;
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
    // ------ String placePath = 'places/$placeId/managers/$uid';

    String publishInUser = await MixinDatabase.publishToDB(userPath, {
      'placeId': placeId,
      'roleId': placeUserRole.roleInPlaceEnum.name
    });

    /* ------ String publishInPlace = await MixinDatabase.publishToDB(placePath, {
      'userId': uid,
      'roleId': placeUserRole.roleInPlaceEnum.name
    });

    if (publishInPlace != 'success'){
      result = publishInPlace;
    } else if (publishInUser != 'success') {
      result = publishInUser;
    }*/

    if (publishInUser != 'success') {
      result = publishInUser;
    }

    return result;


  }

  Future<String> deletePlaceRoleInManagerAndPlace(String placeId) async {

    String result = 'success';
    String userPath = 'users/$uid/myPlaces/$placeId';
    // ---- String placePath = 'places/$placeId/managers/$uid';

    String publishInUser = await MixinDatabase.deleteFromDb(userPath);

    // ----- String publishInPlace = await MixinDatabase.deleteFromDb(placePath);

    /* ------ if (publishInPlace != 'success'){
      result = publishInPlace;
    } else if (publishInUser != 'success') {
      result = publishInUser;
    }*/

    if (publishInUser != 'success') {
      result = publishInUser;
    }

    return result;


  }

}

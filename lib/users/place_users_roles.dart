import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/users/place_admins_item_class.dart';
import 'package:dvij_flutter/users/place_user_class.dart';

enum PlaceUserRoleEnum {
  admin,
  org,
  creator,
  reader
}

class PlaceUserRole with MixinDatabase {
  String title = '';
  PlaceUserRoleEnum roleInPlace = PlaceUserRoleEnum.reader;
  String desc = '';
  int controlLevel = 0;

  PlaceUserRole({String? title, PlaceUserRoleEnum? roleInPlace, String? desc, int? controlLevel}){
    this.title = title ?? this.title;
    this.roleInPlace = roleInPlace ?? this.roleInPlace;
    this.desc = desc ?? this.desc;
    this.controlLevel = controlLevel ?? this.controlLevel;
  }

  PlaceUserRoleEnum getPlaceUserEnumFromString(String role){

    switch (role){
      case 'admin': return PlaceUserRoleEnum.admin;
      case 'org': return PlaceUserRoleEnum.org;
      case 'creator': return PlaceUserRoleEnum.creator;
      default: return PlaceUserRoleEnum.reader;
    }

  }

  List<PlaceUserRole> getPlaceUserRoleList(){
    List<PlaceUserRole> tempList = [];
    tempList.add(getPlaceUserRole(PlaceUserRoleEnum.admin));
    tempList.add(getPlaceUserRole(PlaceUserRoleEnum.reader));
    tempList.add(getPlaceUserRole(PlaceUserRoleEnum.org));
    return tempList;
  }

  String generatePlaceRoleEnumForPlaceUser(PlaceUserRoleEnum placeRole) {
    switch (placeRole) {
      case PlaceUserRoleEnum.reader:
        {
          return 'reader';
        }
      case PlaceUserRoleEnum.admin:
        {
          return 'admin';
        }
      case PlaceUserRoleEnum.org:
        {
          return 'org';
        }
      case PlaceUserRoleEnum.creator:
        {
          return 'creator';
        }
    }
  }

  PlaceUserRole getPlaceUserRole (PlaceUserRoleEnum placeRole) {

    switch (placeRole) {
      case PlaceUserRoleEnum.reader: {
        return PlaceUserRole(
          title: 'Обычный пользователь',
          roleInPlace: placeRole,
          desc: 'Обычный пользователь, который может только читать данные о заведении',
          controlLevel: 10,
        );
      }

      case PlaceUserRoleEnum.creator: {
        return PlaceUserRole(
          title: 'Создатель',
          roleInPlace: placeRole,
          desc: 'Полный доступ ко всем функциям. Единственный кто может удалить место',
          controlLevel: 100,
        );
      }

      case PlaceUserRoleEnum.org: {
        return PlaceUserRole(
          title: 'Организатор',
          roleInPlace: placeRole,
          desc: 'Может добавлять мероприятия и акции от имени заведения',
          controlLevel: 60,
        );
      }

      case PlaceUserRoleEnum.admin: {
        return PlaceUserRole(
          title: 'Администратор',
          roleInPlace: placeRole,
          desc: 'Может редактировать место, добавлять управляющих и менять роли',
          controlLevel: 90,
        );
      }
    }
  }

  PlaceUserRole searchPlaceUserRoleInAdminsList (List<PlaceAdminsListItem> admins, PlaceUser currentUser){
    PlaceUserRole role = PlaceUserRole();
    role = role.getPlaceUserRole(PlaceUserRoleEnum.reader);
    for (PlaceAdminsListItem user in admins){
      if (user.userId == currentUser.uid){
        return user.placeRole;
      }
    }
    return role;
  }

}
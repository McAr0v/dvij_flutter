import 'package:dvij_flutter/database/database_mixin.dart';

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
    this.desc = title ?? this.desc;
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

}
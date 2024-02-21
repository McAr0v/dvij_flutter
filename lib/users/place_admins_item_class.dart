import 'package:dvij_flutter/users/place_users_roles.dart';

class PlaceAdminsListItem {
  String userId = '';
  PlaceUserRole placeRole = PlaceUserRole();

  PlaceAdminsListItem({String? userId, String? placeRole}){
    PlaceUserRole tempRole = PlaceUserRole();
    this.userId = userId ?? this.userId;
    this.placeRole = placeRole != null ? tempRole.getPlaceUserRole(tempRole.getPlaceUserEnumFromString(placeRole)) : this.placeRole;
  }

}
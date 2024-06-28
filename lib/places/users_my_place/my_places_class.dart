import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:firebase_database/firebase_database.dart';

class MyPlaces {
  String placeId;
  PlaceUserRole placeRole;

  MyPlaces({
    required this.placeId,
    required this.placeRole
  });

  factory MyPlaces.empty(){
    return MyPlaces(placeId: '', placeRole: PlaceUserRole());
  }

  factory MyPlaces.fromSnapshot(DataSnapshot snapshot){

    PlaceUserRole placeUserRole = PlaceUserRole();
    PlaceUserRoleEnum roleEnum = placeUserRole.getPlaceUserEnumFromString(snapshot.child('roleId').value.toString());

    placeUserRole = placeUserRole.getPlaceUserRole(roleEnum);

    return MyPlaces(
        placeId: snapshot.child('placeId').value.toString(),
        placeRole: placeUserRole
    );
  }



}
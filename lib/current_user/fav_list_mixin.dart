import 'package:dvij_flutter/places/users_my_place/my_places_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:firebase_database/firebase_database.dart';

mixin FavListsMixin {
  static List<String> getFavEntitiesId(DataSnapshot snapshot, String childName){
    List<String> favIds = [];

    for (var childSnapshot in snapshot.children) {
      favIds.add(childSnapshot.child(childName).value.toString());
    }

    return favIds;

  }

  static List<MyPlaces> getMyPlacesEntities(DataSnapshot snapshot){
    List<MyPlaces> myPlaces = [];

    for (var childSnapshot in snapshot.children) {
      MyPlaces tempPlace = MyPlaces.fromSnapshot(childSnapshot);
      if (tempPlace.placeRole.roleInPlaceEnum != PlaceUserRoleEnum.reader){
        myPlaces.add(tempPlace);
      }
    }

    return myPlaces;

  }

}
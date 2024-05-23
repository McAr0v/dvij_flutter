import 'package:firebase_database/firebase_database.dart';

mixin FavListsMixin {
  List<String> getFavEntitiesId(DataSnapshot snapshot, String childName){
    List<String> favIds = [];

    for (var childSnapshot in snapshot.children) {
      favIds.add(childSnapshot.child(childName).value.toString());
    }

    return favIds;

  }
}
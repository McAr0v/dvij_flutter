import 'package:firebase_database/firebase_database.dart';
import '../current_user/user_class.dart';
import '../database/database_mixin.dart';

mixin UsersListsMixin {

  static List<UserCustom> downloadedUsers = [];

  Future<List<UserCustom>> getAllUsersFromDb({bool order = true}) async {

    List<UserCustom> users = [];

    String usersPath = 'users';

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(usersPath);

    if (snapshot != null) {
      for (var childSnapshot in snapshot.children) {
        users.add(UserCustom.fromSnapshot(childSnapshot));
      }

      sortUsersByEmail(users, order);

      downloadedUsers = users;

    }

    // Возвращаем список
    return users;
  }

  void sortUsersByEmail(List<UserCustom> users, bool order) {

    if (order) {
      users.sort((a, b) => a.email.compareTo(b.email));
    } else {
      users.sort((a, b) => b.email.compareTo(a.email));
    }
  }

  void sortUsersByName(List<UserCustom> users, bool order) {

    if (order) {
      users.sort((a, b) => a.name.compareTo(b.name));
    } else {
      users.sort((a, b) => b.name.compareTo(a.name));
    }
  }

}
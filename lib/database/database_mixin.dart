import 'package:firebase_database/firebase_database.dart';

mixin MixinDatabase{

  Future<DataSnapshot?> getInfoFromDB(String path) async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref().child(path);
      DataSnapshot snapshot = await reference.get();
      return snapshot;
    } catch (e) {
      print('Ошибка при получении снимка данных: $e');
      return null;
    }
  }

  Future<String> publishToDB(String path, Map<String, dynamic> data) async {
    try {
      await FirebaseDatabase.instance.ref().child(path).set(data);
      return 'success';
    } catch (e) {
      return 'Ошибка при публикации данных: $e';
    }
  }

  Future<String> deleteFromDb(String path) async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref().child(path);

      DataSnapshot snapshot = await reference.get();

      if (!snapshot.exists) {
        return 'Данные не найдены';
      }

      await reference.remove();

      return 'success';

    } catch (error) {
      return 'Ошибка при удалении: $error';
    }
  }

  String? generateKey() {
    return FirebaseDatabase.instance.ref().push().key;
  }

}
import 'package:firebase_database/firebase_database.dart';

mixin MixinDatabase{

  static Future<DataSnapshot?> getInfoFromDB(String path) async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref().child(path);
      DataSnapshot snapshot = await reference.get();
      return snapshot;
    } catch (e) {
      return null;
    }
  }

  static Future<String> publishToDB(String path, Map<String, dynamic> data) async {
    try {
      await FirebaseDatabase.instance.ref().child(path).set(data);
      return 'success';
    } catch (e) {
      return 'Ошибка при публикации данных: $e';
    }
  }

  static Map<String, dynamic> generateDataCode(String keyId, dynamic value) {
    return <String, dynamic> {
      keyId: value
    };
  }

  static Future<String> deleteFromDb(String path) async {
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

  static String? generateKey() {
    return FirebaseDatabase.instance.ref().push().key;
  }
}
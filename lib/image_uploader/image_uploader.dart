import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ImageUploader {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImageInProfile(String uid, File pickedFile) async {
    // Получите ссылку на ваш объект в Firebase Storage
    final storageRef = _storage.ref().child('avatars').child(uid).child('avatar_$uid.jpeg');

    // Выполните загрузку файла
    final uploadTask = storageRef.putFile(File(pickedFile.path));

    // Дождитесь завершения загрузки и получите URL загруженного файла
    final TaskSnapshot taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Вернуть URL загруженного файла
    return downloadURL;
  }
}
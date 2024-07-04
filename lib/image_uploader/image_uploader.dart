import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// --- ФУНКЦИИ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ В STORAGE ---

enum ImageFolderEnum {
  users,
  events,
  places,
  promos
}

class ImageUploader {
  // Инициализируем Storage
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _getFolderPath (ImageFolderEnum folderEnum){
    switch (folderEnum) {
      case ImageFolderEnum.users: return 'avatars';
      case ImageFolderEnum.events: return 'events';
      case ImageFolderEnum.places: return 'places';
      case ImageFolderEnum.promos: return 'promos';
    }
  }

  Future<String?> uploadImage(String entityId, File pickedFile, ImageFolderEnum folderEnum) async {

    // Ссылка на ваш объект в Firebase Storage
    // PS - чтобы не забивать память, я решил, что я буду перезаписывать старую аватарку

    final storageRef = _storage.ref().child(_getFolderPath(folderEnum)).child(entityId).child('image_$entityId.jpeg');

    // Выгружаем аватар
    final uploadTask = storageRef.putFile(File(pickedFile.path));

    // Дожидаемся завершения загрузки и получием URL загруженного файла
    final TaskSnapshot taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Возвращаем URL загруженного файла
    return downloadURL;
  }

  Future<String> removeImage(ImageFolderEnum folderEnum, String entityId) async {

    final storageRef = _storage.ref().child(_getFolderPath(folderEnum)).child(entityId).child('image_$entityId.jpeg');

    try {
      await storageRef.delete();
      return 'success';
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}': ${e.message}");
      return e.toString();
    }
  }

  // --- ФУНКЦИЯ ЗАГРУЗКИ АВАТАРКИ ПОЛЬЗОВАТЕЛЯ ----

  Future<String?> uploadImageInProfile(String uid, File pickedFile) async {

    // Ссылка на ваш объект в Firebase Storage
    // PS - чтобы не забивать память, я решил, что я буду перезаписывать старую аватарку

    FirebaseStorage storage = FirebaseStorage.instance;

    final storageRef = storage.ref().child('avatars').child(uid).child('image_$uid.jpeg');

    // Выгружаем аватар
    final uploadTask = storageRef.putFile(File(pickedFile.path));

    // Дожидаемся завершения загрузки и получием URL загруженного файла
    final TaskSnapshot taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Возвращаем URL загруженного файла
    return downloadURL;
  }

  static Future<String?> uploadImageInPlace(String placeId, File pickedFile) async {

    // Ссылка на ваш объект в Firebase Storage
    // PS - чтобы не забивать память, я решил, что я буду перезаписывать старую аватарку

    FirebaseStorage storage = FirebaseStorage.instance;

    final storageRef = storage.ref().child('places').child(placeId).child('image_$placeId.jpeg');

    // Выгружаем аватар
    final uploadTask = storageRef.putFile(File(pickedFile.path));

    // Дожидаемся завершения загрузки и получием URL загруженного файла
    final TaskSnapshot taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Возвращаем URL загруженного файла
    return downloadURL;
  }

  static Future<String?> uploadImageInEvent(String eventId, File pickedFile) async {

    // Ссылка на ваш объект в Firebase Storage
    // PS - чтобы не забивать память, я решил, что я буду перезаписывать старую аватарку

    FirebaseStorage storage = FirebaseStorage.instance;

    final storageRef = storage.ref().child('events').child(eventId).child('image_$eventId.jpeg');

    // Выгружаем аватар
    final uploadTask = storageRef.putFile(File(pickedFile.path));

    // Дожидаемся завершения загрузки и получием URL загруженного файла
    final TaskSnapshot taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Возвращаем URL загруженного файла
    return downloadURL;
  }

  static Future<String?> uploadImageInPromo(String promoId, File pickedFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    // Ссылка на ваш объект в Firebase Storage
    // PS - чтобы не забивать память, я решил, что я буду перезаписывать старую аватарку

    final storageRef = storage.ref().child('promos').child(promoId).child('image_$promoId.jpeg');

    // Выгружаем аватар
    final uploadTask = storageRef.putFile(File(pickedFile.path));

    // Дожидаемся завершения загрузки и получием URL загруженного файла
    final TaskSnapshot taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Возвращаем URL загруженного файла
    return downloadURL;
  }

  static Future<String> deleteImage(String folder, String entityId) async {

    FirebaseStorage storage = FirebaseStorage.instance;

    final storageRef = storage.ref().child(folder).child(entityId).child('image_$entityId.jpeg');

    try {
      await storageRef.delete();
      return 'success';
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}': ${e.message}");
      return e.toString();
    }
  }

}
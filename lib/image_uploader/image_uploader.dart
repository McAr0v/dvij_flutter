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

    final storageRef = _storage.ref().child(_getFolderPath(folderEnum)).child(entityId).child('image_$entityId.jpeg');

    // Выгружаем изображение
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

}
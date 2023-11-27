import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /*Future<File?> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final compressedImage = await compressImage(imageFile);
      return compressedImage;
    } else {
        return null;
    }
  }*/

  Future<XFile?> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      return pickedFile;
    } else {
      return null;
    }
  }

  Future<File> compressImage(File imageFile) async {
    final rawImage = img.decodeImage(imageFile.readAsBytesSync());

    int targetSize = 1000;

    // Определение ориентации изображения
    bool isVertical = rawImage!.height > rawImage.width;

    // Расчет размеров
    int targetWidth, targetHeight;
    if (isVertical) {
      targetHeight = targetSize;
      targetWidth = ((rawImage.width / rawImage.height) * targetHeight).round();
    } else {
      targetWidth = targetSize;
      targetHeight = ((rawImage.height / rawImage.width) * targetWidth).round();
    }

    // Уменьшение размера изображения
    final resizedImage = img.copyResize(rawImage, width: targetWidth, height: targetHeight);

    // Создание файла сжатого изображения
    final compressedImage = File('${imageFile.path}_compressed.jpg')
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 80));

    return compressedImage;
  }
}
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

// ---- ФУНКЦИОНАЛ ВЫБОРА КАРТИНКИ ИЗ ГАЛЕРЕИ -----

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  // --- ВЫБОР КАРТИНКИ -----

  Future<File?> pickImage(ImageSource source) async {
    // Открываем галерею и ждем выбора картинки от пользователя
    final pickedFile = await _picker.pickImage(source: source);

    // Если пользователь выбрал картинку
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      return file;
    } else {
      // Если ничего не выбрал
      return null;
    }
  }

  // --- ФУНКЦИЯ СЖАТИЯ КАРТИНКИ -----

  Future<File> compressImage(File imageFile) async {

    // Декодируем картинку
    final rawImage = img.decodeImage(imageFile.readAsBytesSync());

    // Переменная максимального размера изображения по бОльшей стороне
    int targetSize = 500;

    // Определение ориентации изображения
    bool isVertical = rawImage!.height > rawImage.width;

    // Расчет размеров
    int targetWidth, targetHeight;

    // Если вертикальная
    if (isVertical) {
      // Тогда высота равна максимальному размеру длины изображения
      targetHeight = targetSize;
      // Ширина пропорционально уменьшается
      targetWidth = ((rawImage.width / rawImage.height) * targetHeight).round();
    } else {
      // Если горизонтальная, то ширина равна максимальному размеру длины изображения
      targetWidth = targetSize;
      // Высота пропорционально уменьшается
      targetHeight = ((rawImage.height / rawImage.width) * targetWidth).round();
    }

    // Уменьшаем размеры изображения
    final resizedImage = img.copyResize(rawImage, width: targetWidth, height: targetHeight);

    // Компрессируем изображение
    final compressedImage = File('${imageFile.path}_compressed.jpg')
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 80));

    // Возвращаем сжатое изображение
    return compressedImage;
  }
}
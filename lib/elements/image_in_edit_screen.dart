import 'package:flutter/material.dart';
import 'dart:io';

class ImageInEditScreen extends StatelessWidget {
  final String? backgroundImageUrl;
  final File? backgroundImageFile;
  final VoidCallback onEditPressed;

  const ImageInEditScreen({super.key, this.backgroundImageUrl, this.backgroundImageFile, required this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth, // Ширина равна максимальной ширине
            height: constraints.maxWidth, // Фиксированная высота
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (backgroundImageUrl != null)
                  Ink.image(
                    image: NetworkImage(backgroundImageUrl!),
                    fit: BoxFit.cover,
                  ),
                if (backgroundImageFile != null)
                  Image.file(
                    backgroundImageFile!,
                    fit: BoxFit.cover,
                  ),
                ElevatedButton(
                  onPressed: onEditPressed,
                  child: Text('Изменить фотографию'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
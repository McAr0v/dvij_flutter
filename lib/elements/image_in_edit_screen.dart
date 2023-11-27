import 'package:flutter/material.dart';
import 'dart:io';

class ImageInEditScreen extends StatelessWidget {
  final String? backgroundImageUrl;
  final File? backgroundImageFile;
  final VoidCallback onEditPressed;

  ImageInEditScreen({Key? key, this.backgroundImageUrl, this.backgroundImageFile, required this.onEditPressed}) : super(key: key);

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
                if (backgroundImageFile != null)
                  Image.file(
                    backgroundImageFile!,
                    fit: BoxFit.cover,
                  ),
                if (backgroundImageUrl != null)
                  Ink.image(
                    image: NetworkImage(backgroundImageUrl!),
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
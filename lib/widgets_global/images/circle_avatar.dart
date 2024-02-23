import 'package:flutter/material.dart';

class CircleAvatarWidget extends StatelessWidget {
  final double radius;
  final String imagePath;

  const CircleAvatarWidget({required this.imagePath, this.radius = 30, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey, // Цвет фона, который будет виден во время загрузки
      child: ClipOval(
        child: FadeInImage(
          placeholder: const AssetImage('assets/u_user.png'),
          image: NetworkImage(imagePath),
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/error_image.png'); // Изображение ошибки, если загрузка не удалась
          },
        ),
      ),
    );
  }

}
import 'package:flutter/material.dart';

class ImageWithPlaceHolderWidget extends StatelessWidget {
  final double heightPercentFromWidth;
  final double topLeftRadius;
  final double topRightRadius;
  final double bottomLeftRadius;
  final double bottomRightRadius;
  final String imagePath;
  final double? height;

  const ImageWithPlaceHolderWidget({
    required this.imagePath,
    this.heightPercentFromWidth = 1.2,
    this.bottomLeftRadius = 20,
    this.bottomRightRadius = 20,
    this.topRightRadius = 0,
    this.topLeftRadius = 0,
    this.height,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? MediaQuery.of(context).size.width * heightPercentFromWidth, // Ширина экрана
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FadeInImage.assetNetwork(
            placeholder: 'assets/u_user.png',
            image: imagePath,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/error_image.png'); // Изображение ошибки, если загрузка не удалась
            },
          ).image,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeftRadius),
            topRight: Radius.circular(topRightRadius),
            bottomLeft: Radius.circular(bottomLeftRadius),
            bottomRight: Radius.circular(bottomRightRadius)
        ),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(topLeftRadius),
                  topRight: Radius.circular(topRightRadius),
                  bottomLeft: Radius.circular(bottomLeftRadius),
                  bottomRight: Radius.circular(bottomRightRadius)
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent, // Здесь можете использовать любой другой цвет или полную прозрачность
                  Colors.black.withOpacity(0.1), // Начальный цвет (черный с прозрачностью)
                  Colors.black.withOpacity(0.3), // Начальный цвет (черный с прозрачностью)
                  Colors.black.withOpacity(0.5), // Начальный цвет (черный с прозрачностью)
                  Colors.black.withOpacity(0.7), // Начальный цвет (черный с прозрачностью)
                  Colors.black.withOpacity(0.9), // Начальный цвет (черный с прозрачностью)
                ],
              ), // Здесь можно настроить уровень прозрачности и цвет фона
              //borderRadius: BorderRadius.circular(15), // настройте радиус скругления углов для фона
            ),
          ),
        ],
      ),
    );
  }

}
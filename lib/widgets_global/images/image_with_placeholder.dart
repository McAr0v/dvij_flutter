import 'package:flutter/cupertino.dart';

class ImageWithPlaceHolderWidget extends StatelessWidget {
  final double heightPercentFromWidth;
  final double topLeftRadius;
  final double topRightRadius;
  final double bottomLeftRadius;
  final double bottomRightRadius;
  final String imagePath;

  const ImageWithPlaceHolderWidget({
    required this.imagePath,
    this.heightPercentFromWidth = 0.7,
    this.bottomLeftRadius = 20,
    this.bottomRightRadius = 20,
    this.topRightRadius = 20,
    this.topLeftRadius = 20,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * heightPercentFromWidth, // Ширина экрана
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
    );
  }

}
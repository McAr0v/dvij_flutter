import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/text_size_enum.dart';
import 'package:flutter/material.dart';

class HeadlineAndDesc extends StatelessWidget {
  final String headline;
  final String description;
  final TextSizeEnum textSize;
  final TextSizeEnum descSize;
  final double padding;
  final Color textColor;
  final Color descColor;

  const HeadlineAndDesc({
    Key? key,
    required this.headline,
    required this.description,
    this.textSize = TextSizeEnum.bodyMedium,
    this.descSize = TextSizeEnum.labelMedium,
    this.padding = 0,
    this.textColor = AppColors.white,
    this.descColor = AppColors.greyText,
  }) : super(key: key);

  // --- ВИДЖЕТ ОТОБРАЖЕНИЯ ЗАГОЛОВКА И ПОДПИСИ -----

  @override
  Widget build(BuildContext context) {

    TextSizeClass textSizeClass = TextSizeClass(size: textSize);
    TextSizeClass descSizeClass = TextSizeClass(size: descSize);

    // Получаем размеры текстов
    TextStyle? textStyle = textSizeClass.getTextStyleWithColorFromEnum(context, textColor);
    TextStyle? descStyle = descSizeClass.getTextStyleWithColorFromEnum(context, descColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          softWrap: true,
          style: textStyle
        ),

        SizedBox(height: padding,),

        Text(
          description,
          softWrap: true,
          style: descStyle
        ),
      ],
    );
  }
}
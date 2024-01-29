import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/app_colors.dart';

class IconAndTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String textSize;
  final double iconSize;
  final double padding;
  final Color textColor;
  final Color iconColor;

  const IconAndTextWidget({
    Key? key,
    required this.icon,
    required this.text,
    this.textSize = 'body',
    this.iconSize = 20,
    this.padding = 5,
    this.textColor = AppColors.white,
    this.iconColor = AppColors.white

  }) : super(key: key);

  // --- ВИДЖЕТ ОТОБРАЖЕНИЯ ЗАГОЛОВКА И ПОДПИСИ -----

  @override
  Widget build(BuildContext context) {

    TextStyle? style = Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor);

    switch (textSize) {
      case 'body': style = Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor);
      case 'label': style = Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor);
      case 'title': style = Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor);
      default: style = Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
        SizedBox(width: padding),
        Text(
          text,
          style: style,
        )
      ],
    );
  }
}
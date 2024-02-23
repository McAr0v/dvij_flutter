import 'package:dvij_flutter/widgets_global/text_widgets/text_size_enum.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/app_colors.dart';

class IconAndTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final TextSizeEnum textSize;
  final double iconSize;
  final double padding;
  final Color textColor;
  final Color iconColor;

  const IconAndTextWidget({
    Key? key,
    required this.icon,
    required this.text,
    this.textSize = TextSizeEnum.bodyMedium,
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
      case TextSizeEnum.bodyMedium: style = Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor);
      case TextSizeEnum.bodySmall: style = Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor);
      case TextSizeEnum.labelMedium: style = Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor);
      case TextSizeEnum.labelSmall: style = Theme.of(context).textTheme.labelSmall?.copyWith(color: textColor);
      case TextSizeEnum.headlineMedium: style = Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor);
      case TextSizeEnum.headlineSmall: style = Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor);
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
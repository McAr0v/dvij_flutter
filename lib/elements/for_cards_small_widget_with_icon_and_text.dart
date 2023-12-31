import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class SmallWidgetForCardsWithIconAndText extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color iconColor;
  final Color backgroundColor;
  final bool side;
  final VoidCallback? onPressed; // Добавлено для обработки нажатия

  const SmallWidgetForCardsWithIconAndText({
    Key? key,
    this.icon,
    required this.text,
    required this.iconColor,
    this.backgroundColor = AppColors.greyOnBackground,
    this.side = true,
    this.onPressed, // Добавлено для обработки нажатия
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed, // Добавлено для обработки нажатия
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (side && icon != null) Icon(
              icon,
              color: iconColor,
              size: 24.0,
            ),
            if (side && icon != null) SizedBox(width: 10),
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            if (!side && icon != null) SizedBox(width: 10),
            if (!side && icon != null) Icon(
              icon,
              color: iconColor,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
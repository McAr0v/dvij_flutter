import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class SmallWidgetForCardsWithIconAndText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color backgroundColor;
  final bool side;

  const SmallWidgetForCardsWithIconAndText({
    Key? key,
    required this.icon,
    required this.text,
    required this.iconColor,
    this.backgroundColor = AppColors.greyOnBackground,
    this.side = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0), // Регулируйте отступы по вашему усмотрению
      decoration: BoxDecoration(
        color: backgroundColor, // Замените на ваш цвет фона
        borderRadius: BorderRadius.circular(8.0), // Регулируйте радиус углов по вашему усмотрению
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (side) Icon(
            icon,
            color: iconColor,
            size: 24.0,
          ),
          if (side) SizedBox(width: 10),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          if (!side) SizedBox(width: 10),
          if (!side) Icon(
            icon,
            color: iconColor,
            size: 24.0,
          ),
        ],
      )
     );
  }
}
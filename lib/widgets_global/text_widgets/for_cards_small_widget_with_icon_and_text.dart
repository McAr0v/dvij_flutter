import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class IconAndTextInTransparentSurfaceWidget extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final bool side;
  final VoidCallback? onPressed; // Добавлено для обработки нажатия

  const IconAndTextInTransparentSurfaceWidget({
    Key? key,
    this.icon,
    required this.text,
    required this.iconColor,
    this.textColor = AppColors.white,
    this.backgroundColor = AppColors.greyOnBackground,
    this.side = true,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8.0),
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
            if (side && icon != null) const SizedBox(width: 10),
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor),
            ),
            if (!side && icon != null) const SizedBox(width: 10),
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
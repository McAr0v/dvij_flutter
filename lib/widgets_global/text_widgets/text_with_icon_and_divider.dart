import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import 'headline_and_desc.dart';

class TextWithIconAndDivider extends StatelessWidget {
  final String headline;
  final String description;
  final IconData icon;
  final double iconSize;

  const TextWithIconAndDivider({
    Key? key,
    required this.headline,
    required this.description,
    required this.icon,
    this.iconSize = 22
  }) : super(key: key);

  // --- ВИДЖЕТ ОТОБРАЖЕНИЯ ЗАГОЛОВКА И ПОДПИСИ -----

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          color: AppColors.greyText, // Цвет линии
          thickness: 1, // Толщина линии
        ),

        const SizedBox(height: 20.0),

        Row(
          children: [
            Icon(icon, color: AppColors.greyText, size: iconSize,),
            const SizedBox(width: 15.0),
            Expanded(child: HeadlineAndDesc(headline: headline, description: description),),
          ],
        ),

        const SizedBox(height: 20.0),

      ],
    );
  }
}
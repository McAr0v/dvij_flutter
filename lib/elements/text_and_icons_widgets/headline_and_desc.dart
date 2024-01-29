import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class HeadlineAndDesc extends StatelessWidget {
  final String headline;
  final String description;
  final String textSize;

  const HeadlineAndDesc({
    Key? key,
    required this.headline,
    required this.description,
    this.textSize = 'normal'
  }) : super(key: key);

  // --- ВИДЖЕТ ОТОБРАЖЕНИЯ ЗАГОЛОВКА И ПОДПИСИ -----

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- ЕСЛИ НОРМАЛЬНЫЙ СТАНДАРТНЫЙ ЗАГОЛОВОК ----
        if (textSize == 'normal') Text(
          headline,
          softWrap: true,
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,
              height: 1.3
          ),
        ),

        // --- ЕСЛИ НУЖЕН БОЛЬШОЙ ЗАГОЛОВОК -----
        if (textSize == 'big') Text(
          headline,
          softWrap: true,
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.bold,
              height: 1.3
          ),
        ),

        Text(
          description,
          softWrap: true,
          style: const TextStyle(
            color: AppColors.greyText,
            fontSize: 12,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
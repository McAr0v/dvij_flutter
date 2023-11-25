import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class HeadlineAndDesc extends StatelessWidget {
  final String headline;
  final String description;

  const HeadlineAndDesc({
    Key? key,
    required this.headline,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,
              height: 1.3
          ),
        ),
        //const SizedBox(height: 8), // добавьте пространство между заголовком и описанием
        Text(
          description,
          softWrap: true, // автоматический перенос текста на новую строку
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
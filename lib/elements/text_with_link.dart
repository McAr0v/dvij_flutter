import 'package:flutter/material.dart';

import '../navigation/custom_bottom_navigation_bar.dart';
import '../themes/app_colors.dart';

class TextWithLink extends StatelessWidget {
  final String text; // передаваемая переменная
  final String linkedText; // передаваемая переменная
  final String uri; // передаваемая переменная

  const TextWithLink({super.key, this.text = '', required this.linkedText, required this.uri}); // Указываем значения по умолчанию


  // Содержание контейнера

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text != '') Text(text, style: Theme.of(context).textTheme.bodyMedium, softWrap: true,),

        GestureDetector(
          onTap: () {
            // Переход на страницу политики конфиденциальности
            // Замените '/privacy_policy' на ваш реальный путь маршрута
            Navigator.pushNamed(context, uri);
          },
          child: Text(
              linkedText,
              style: const TextStyle(
                  color: AppColors.brandColor,
                  fontSize: 16,
                  fontFamily: 'SfProDisplay',
                  fontWeight: FontWeight.normal,
                  height: 1.3,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.brandColor,


              )
          ),
        ),
      ],
    );
  }
}
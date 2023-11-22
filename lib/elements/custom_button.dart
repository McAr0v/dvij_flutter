import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../navigation/custom_bottom_navigation_bar.dart';
import '../themes/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String state; // передаваемая переменная

  CustomButton({this.state = 'normal'}); // Указываем значения по умолчанию

  Color getButtonColor() {
    switch (state) {
      case 'normal':
        return AppColors.brandColor;
      case 'success':
        return Colors.green; // Замените на ваш цвет для успешного статуса
      case 'error':
        return Colors.red; // Замените на ваш цвет для ошибочного статуса
    // Добавьте другие кейсы по мере необходимости
      default:
        return AppColors.brandColor;
    }
  }


  // Содержание контейнера

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: ShapeDecoration(
        color: getButtonColor(),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2, color: getButtonColor()),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Row(
        //mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Icon( Icons.edit)
          ),
          Text(
            'Текст кнопки',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400
            ),
          ),
          Container(
            width: 22,
            height: 22,
            child: Icon( Icons.edit)
          ),
        ],
      ),
    );
  }
}
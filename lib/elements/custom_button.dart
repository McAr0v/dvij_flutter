import 'package:dvij_flutter/elements/icons_elements/svg_icon.dart';
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String state; // передаваемая переменная
  final String buttonText;
  final VoidCallback onTapMethod;
  final String leftIconRoot;
  final String rightIconRoot;

  CustomButton({this.state = 'normal', required this.buttonText, required this.onTapMethod, this.leftIconRoot = '', this.rightIconRoot = ''}); // Указываем значения по умолчанию

  // Содержание контейнера

  @override
  Widget build(BuildContext context) {

    Color getButtonColor() {
      switch (state) {
        case 'normal':
          return Theme.of(context).colorScheme.primary;
        case 'success':
          return Colors.green; // Замените на ваш цвет для успешного статуса
        case 'error':
          return AppColors.attentionRed; // Замените на ваш цвет для ошибочного статуса
      // Добавьте другие кейсы по мере необходимости
        case 'secondary':
          return Theme.of(context).colorScheme.background;
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    Color getBorderColor() {
      switch (state) {
        case 'normal':
          return Theme.of(context).colorScheme.primary;
        case 'success':
          return Colors.green; // Замените на ваш цвет для успешного статуса
        case 'error':
          return AppColors.attentionRed; // Замените на ваш цвет для ошибочного статуса
      // Добавьте другие кейсы по мере необходимости
        case 'secondary':
          return Theme.of(context).colorScheme.primary;
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    Color getTextAndIconColor() {
      switch (state) {
      /*case 'normal':
        return AppColors.greyOnBackground;
      case 'success':
        return AppColors.greyOnBackground; // Замените на ваш цвет для успешного статуса
      case 'error':
        return AppColors.greyOnBackground; // Замените на ваш цвет для ошибочного статуса
    // Добавьте другие кейсы по мере необходимости
       */
        case 'secondary':
          return Theme.of(context).colorScheme.primary;
        default:
          return Theme.of(context).colorScheme.onBackground;
      }
    }

    var iconColor = getTextAndIconColor();

    return GestureDetector(
      onTap: onTapMethod,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: ShapeDecoration(
          color: getButtonColor(),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2, color: getBorderColor()),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          //mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leftIconRoot != '')
              SvgIcon(
                  assetPath: 'assets/$leftIconRoot',
                  width: 20,
                  height: 20,
                  color: iconColor
              ),

            if (leftIconRoot != '')
              SizedBox(width: 15.0),


            Text(
              buttonText,
              style: TextStyle(
                  color: getTextAndIconColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'SfProDisplay'
              ),
            ),

            if (rightIconRoot != '')
              SizedBox(width: 15.0),

            if (rightIconRoot != '')
              SvgIcon(
                  assetPath: 'assets/$rightIconRoot',
                  width: 20,
                  height: 20,
                  color: getTextAndIconColor()
              ),
          ],
        ),
      )
    );

  }
}
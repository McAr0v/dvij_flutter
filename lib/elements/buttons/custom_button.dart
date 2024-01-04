import 'package:dvij_flutter/elements/icons_elements/svg_icon.dart';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String state;
  final String buttonText;
  final VoidCallback onTapMethod;
  final String leftIconRoot;
  final String rightIconRoot;

  const CustomButton({super.key, this.state = 'normal', required this.buttonText, required this.onTapMethod, this.leftIconRoot = '', this.rightIconRoot = ''}); // Указываем значения по умолчанию

  // --- ВИДЖЕТ КАСТОМНОЙ КНОПКИ ------

  @override
  Widget build(BuildContext context) {

    // Выбор цвета кнопки в зависимости от переданного состояния кнопки

    Color getButtonColor() {
      switch (state) {
        case 'normal':
          return Theme.of(context).colorScheme.primary;
        case 'success':
          return Colors.green;
        case 'error':
          return AppColors.attentionRed;
        case 'secondary':
          return Theme.of(context).colorScheme.background;
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    // Выбор цвета границы в зависимости от переданного состояния кнопки

    Color getBorderColor() {
      switch (state) {
        case 'normal':
          return Theme.of(context).colorScheme.primary;
        case 'success':
          return Colors.green;
        case 'error':
          return AppColors.attentionRed;
        case 'secondary':
          return Theme.of(context).colorScheme.primary;
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    // Выбор цвета текста в зависимости от передаваемого состояния

    Color getTextAndIconColor() {
      switch (state) {
        case 'secondary':
          return Theme.of(context).colorScheme.primary;
        default:
          return Theme.of(context).colorScheme.onBackground;
      }
    }

    var iconColor = getTextAndIconColor();

    // --- САМА КНОПКА ----

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
              const SizedBox(width: 15.0),


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
              const SizedBox(width: 15.0),

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
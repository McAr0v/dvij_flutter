import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

Future<bool?> exitDialog(BuildContext context, String message, String confirmText, String cancelText) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.greyOnBackground,
        title: Text(
            message,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return Colors.transparent;
                },
              ),
              padding: MaterialStateProperty.resolveWith<EdgeInsets?>(
                    (Set<MaterialState> states) {
                  return const EdgeInsets.fromLTRB(20, 0, 0, 20);
                },
              ),
              textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                    (Set<MaterialState> states) {
                  return const TextStyle(
                      fontSize: 16,
                      fontFamily: 'SfProDisplay',
                      fontWeight: FontWeight.normal,
                      height: 1.3
                  );
                },
              ),
              foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return AppColors.attentionRed;
                },
              ),
              side: MaterialStateProperty.resolveWith<BorderSide?>(
                    (Set<MaterialState> states) {
                  return const BorderSide(
                    color: Colors.transparent, // Цвет границы
                    width: 0.0, // Толщина границы
                  );
                },
              ),
              minimumSize: MaterialStateProperty.resolveWith<Size?>(
                    (Set<MaterialState> states) {
                  return Size(0, 0); // Задайте минимальную ширину и высоту
                },
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(false); // Закрыть диалог и вернуть `false`
            },
            child: Text(
              cancelText,
              style: TextStyle(
                color: Colors.red, // Устанавливаем цвет текста для кнопки "Нет"
              ),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return Colors.transparent;
                },
              ),
              padding: MaterialStateProperty.resolveWith<EdgeInsets?>(
                    (Set<MaterialState> states) {
                  return const EdgeInsets.fromLTRB(20, 0, 0, 20);
                },
              ),
              textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                    (Set<MaterialState> states) {
                  return const TextStyle(
                      fontSize: 16,
                      fontFamily: 'SfProDisplay',
                      fontWeight: FontWeight.normal,
                      height: 1.3
                  );
                },
              ),
              foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return AppColors.attentionRed;
                },
              ),
              side: MaterialStateProperty.resolveWith<BorderSide?>(
                    (Set<MaterialState> states) {
                  return const BorderSide(
                    color: Colors.transparent, // Цвет границы
                    width: 0.0, // Толщина границы
                  );
                },
              ),
              minimumSize: MaterialStateProperty.resolveWith<Size?>(
                    (Set<MaterialState> states) {
                  return Size(0, 0); // Задайте минимальную ширину и высоту
                },
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(true); // Закрыть диалог и вернуть `true`
            },
            child: Text(
              confirmText,
              style: TextStyle(
                color: Colors.green, // Устанавливаем цвет текста для кнопки "Да"
              ),
            ),
          ),
        ],
      );
    },
  );
}
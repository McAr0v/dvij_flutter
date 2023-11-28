import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:flutter/material.dart';

// ---- ВИДЖЕТ ОТОБРАЖЕНИЯ ВСПЛЫВАЮШЕГО ДИАЛОГА -----

class PopUpDialog {
  static Future<bool?> showConfirmationDialog(
      BuildContext context, {
        required String title,
        required Color backgroundColor,
        required String confirmButtonText,
        required String cancelButtonText,
      }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: backgroundColor,
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          buttonPadding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20.0),
          insetPadding: const EdgeInsets.symmetric(vertical: 20.0),
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20.0),

          // TODO Сделать отступы между кнопками в всплываюшем диалоге

          actions: [
            CustomButton(
              buttonText: cancelButtonText,
              onTapMethod: () {
                Navigator.of(context).pop(false); // Закрыть диалоговое окно
              },
            ),
            CustomButton(
              state: 'error',
              buttonText: confirmButtonText,
              onTapMethod: () {
                Navigator.of(context).pop(true); // Закрыть диалоговое окно
              },
            ),
          ],
        );
      },
    );
  }
}
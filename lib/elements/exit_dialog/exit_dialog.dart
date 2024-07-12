import 'package:dvij_flutter/elements/buttons/custom_only_text_button.dart';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

// TODO обернуть виджет exitDialog в нормальный виджет

Future<bool?> exitDialog(BuildContext context, String message, String confirmText, String cancelText, String headline) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        buttonPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
        backgroundColor: AppColors.greyOnBackground,
        actionsPadding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
        titlePadding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
        title: Text(
          headline,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        actionsAlignment: MainAxisAlignment.end,

        actions: [
          CustomOnlyTextButton(
            buttonText: cancelText,
            textColor: AppColors.attentionRed,
            onTap: (){
              Navigator.of(context).pop(false); // Закрыть диалог и вернуть `false`
            },
            smallOrBig: false,
          ),

          CustomOnlyTextButton(
            buttonText: confirmText,
            textColor: Colors.green,
            onTap: () {
              Navigator.of(context).pop(true); // Закрыть диалог и вернуть `true`
            },
            smallOrBig: false,
          ),

        ],
      );
    },
  );
}
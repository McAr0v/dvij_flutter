import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class DataPickerCustom extends StatelessWidget {
  final String? date;
  final String labelText;
  final VoidCallback onActionPressed;

  DataPickerCustom({required this.onActionPressed, this.date, required this.labelText});



  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: TextEditingController(text: date?.isNotEmpty ?? true ? date! : 'Дата не выбрана'),
                  //initialValue: cityName?.isNotEmpty ?? true ? cityName! : 'Город не выбран',
                  style: Theme.of(context).textTheme.bodyMedium,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: labelText,
                    labelStyle: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 12,
                      fontFamily: 'SfProDisplay',
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    //contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            )
        ),
        SizedBox(width: 8.0),

        Card(
          color: AppColors.brandColor,
          child: IconButton(
            onPressed: onActionPressed,
            icon: Icon(
              Icons.edit,
              color: AppColors.greyOnBackground,
            ),
          ),
        )
      ],
    );
  }
}
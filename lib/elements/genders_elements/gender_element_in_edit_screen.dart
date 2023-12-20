import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class GenderElementInEditScreen extends StatelessWidget {
  final String? genderName;
  final VoidCallback onActionPressed;

  const GenderElementInEditScreen({super.key, required this.onActionPressed, this.genderName});



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
                  controller: TextEditingController(text: genderName?.isNotEmpty ?? true ? genderName! : 'Гендер не выбран'),
                  //initialValue: cityName?.isNotEmpty ?? true ? cityName! : 'Город не выбран',
                  style: Theme.of(context).textTheme.bodyMedium,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Пол',
                    labelStyle: TextStyle(
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
        const SizedBox(width: 8.0),

        Card(
          color: AppColors.brandColor,
          child: IconButton(
            onPressed: onActionPressed,
            icon: const Icon(
              Icons.edit,
              color: AppColors.greyOnBackground,
            ),
          ),
        )
      ],
    );
  }
}
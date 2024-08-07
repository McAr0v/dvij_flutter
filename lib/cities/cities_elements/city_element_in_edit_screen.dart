import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class CityElementInEditScreen extends StatelessWidget {
  final String? cityName;
  final VoidCallback onActionPressed;

  const CityElementInEditScreen({super.key, required this.onActionPressed, this.cityName});



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
                  controller: TextEditingController(text: cityName?.isNotEmpty ?? true ? cityName! : 'Город не выбран'),
                  style: Theme.of(context).textTheme.bodyMedium,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Город',
                    labelStyle: TextStyle(
                      color: AppColors.greyText,
                      fontSize: 12,
                      fontFamily: 'SfProDisplay',
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
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
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class RoleInAppElementInEditScreen extends StatelessWidget {
  final String? roleInAppName;
  final VoidCallback onActionPressed;

  const RoleInAppElementInEditScreen({super.key, required this.onActionPressed, this.roleInAppName});



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
                  controller: TextEditingController(text: roleInAppName?.isNotEmpty ?? true ? roleInAppName! : 'Ролья для приложения не выбрана'),
                  //initialValue: cityName?.isNotEmpty ?? true ? cityName! : 'Город не выбран',
                  style: Theme.of(context).textTheme.bodyMedium,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Роль в приложении',
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
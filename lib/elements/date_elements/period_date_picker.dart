import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';


class PeriodDatePickerCustom extends StatelessWidget {
  final String? startDate;
  final String startLabelText;
  final VoidCallback onStartActionPressed;
  final String? endDate;
  final String endLabelText;
  final VoidCallback onEndActionPressed;

  const PeriodDatePickerCustom({super.key,
    required this.onStartActionPressed,
    this.startDate,
    required this.startLabelText,
    this.endDate,
    required this.onEndActionPressed,
    required this.endLabelText
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(

          children: [
            Text(startDate ?? 'Не выбрано', style: Theme.of(context).textTheme.bodyMedium,),
            const SizedBox(width: 10,),
            Card(
              color: AppColors.brandColor,
              child: IconButton(
                onPressed: onEndActionPressed,
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.greyOnBackground,
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Text(startDate ?? 'Не выбрано', style: Theme.of(context).textTheme.bodyMedium,),
            const SizedBox(width: 10,),
            Card(
              color: AppColors.brandColor,
              child: IconButton(
                onPressed: onEndActionPressed,
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.greyOnBackground,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
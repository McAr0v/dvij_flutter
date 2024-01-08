import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';

class WorkTimeTextWidget extends StatelessWidget {
  final String dayName;
  final String startTime;
  final String endTime;
  final bool isBig;

  WorkTimeTextWidget({
    required this.dayName,
    required this.startTime,
    required this.endTime,
    this.isBig = false,
  });

  @override
  Widget build(BuildContext context) {

    String time = '';
    TextStyle? textStyle = Theme.of(context).textTheme.bodySmall;

    if (isBig) textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.brandColor);

    if (startTime == 'Выходной' || endTime == 'Выходной'){
      time = 'Выходной';
    } else {
      time = '$startTime - $endTime';
    }

    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.1, // 5% ширины экрана
          child: Text(
            '$dayName:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        //SizedBox(width: 20,),
        Text(
            time,
          style: textStyle,
        ),
      ],
    );
  }
}
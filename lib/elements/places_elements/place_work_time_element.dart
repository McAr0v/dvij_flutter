import 'package:dvij_flutter/elements/places_elements/work_time_text_widget.dart';
import 'package:dvij_flutter/methods/days_functions.dart';
import 'package:flutter/material.dart';

import '../../classes/place_class.dart';
import '../../themes/app_colors.dart';

class PlaceWorkTimeCard extends StatelessWidget {
  final Place place;

  const PlaceWorkTimeCard({super.key,
    required this.place
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        //border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15.0),
        color: AppColors.greyOnBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Режим работы:',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          WorkTimeTextWidget(dayName: 'ПН', startTime: place.mondayStartTime, endTime: place.mondayFinishTime, isBig: currentDayOfWeek(1)),
          WorkTimeTextWidget(dayName: 'ВТ', startTime: place.tuesdayStartTime, endTime: place.tuesdayFinishTime, isBig: currentDayOfWeek(2)),
          WorkTimeTextWidget(dayName: 'СР', startTime: place.wednesdayStartTime, endTime: place.wednesdayFinishTime, isBig: currentDayOfWeek(3)),
          WorkTimeTextWidget(dayName: 'ЧТ', startTime: place.thursdayStartTime, endTime: place.thursdayFinishTime, isBig: currentDayOfWeek(4)),
          WorkTimeTextWidget(dayName: 'ПТ', startTime: place.fridayStartTime, endTime: place.fridayFinishTime, isBig: currentDayOfWeek(5)),
          WorkTimeTextWidget(dayName: 'СБ', startTime: place.saturdayStartTime, endTime: place.saturdayFinishTime, isBig: currentDayOfWeek(6)),
          WorkTimeTextWidget(dayName: 'ВС', startTime: place.sundayStartTime, endTime: place.sundayFinishTime, isBig: currentDayOfWeek(7)),
        ],
      ),
    );
  }
}
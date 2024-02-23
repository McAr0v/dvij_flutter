import 'package:dvij_flutter/dates/date_type_enum.dart';
import 'package:dvij_flutter/methods/days_functions.dart';
import 'package:dvij_flutter/places/places_elements/work_time_text_widget.dart';
import 'package:flutter/material.dart';
import '../../elements/shedule_elements/schedule_regular_and_irregular_widget.dart';
import '../../places/place_class.dart';
import '../../themes/app_colors.dart';

/*class PlaceWorkTimeCard extends StatelessWidget {
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



          Text(
            'Режим работы:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10.0),
          WorkTimeTextWidget(dayName: 'ПН', startTime: place.openingHours.monday.startTime.toString(), endTime: place.openingHours.monday.endTime.toString(), isBig: currentDayOfWeek(1)),
          WorkTimeTextWidget(dayName: 'ВТ', startTime: place.openingHours.tuesday.startTime.toString(), endTime: place.openingHours.tuesday.endTime.toString(), isBig: currentDayOfWeek(2)),
          WorkTimeTextWidget(dayName: 'СР', startTime: place.openingHours.wednesday.startTime.toString(), endTime: place.openingHours.wednesday.endTime.toString(), isBig: currentDayOfWeek(3)),
          WorkTimeTextWidget(dayName: 'ЧТ', startTime: place.openingHours.thursday.startTime.toString(), endTime: place.openingHours.thursday.endTime.toString(), isBig: currentDayOfWeek(4)),
          WorkTimeTextWidget(dayName: 'ПТ', startTime: place.openingHours.friday.startTime.toString(), endTime: place.openingHours.friday.endTime.toString(), isBig: currentDayOfWeek(5)),
          WorkTimeTextWidget(dayName: 'СБ', startTime: place.openingHours.saturday.startTime.toString(), endTime: place.openingHours.saturday.endTime.toString(), isBig: currentDayOfWeek(6)),
          WorkTimeTextWidget(dayName: 'ВС', startTime: place.openingHours.sunday.startTime.toString(), endTime: place.openingHours.sunday.endTime.toString(), isBig: currentDayOfWeek(7)),
        ],
      ),
    );
  }
}*/
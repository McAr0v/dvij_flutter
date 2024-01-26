import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../classes/event_type_enum.dart';
import '../../themes/app_colors.dart';
import '../headline_and_desc.dart';

class ScheduleOnceAndLongWidgetTwo extends StatelessWidget {
  final double horizontalPadding;
  final String onceDate;
  final String longStartDate;
  final String longEndDate;
  final String startTime;
  final String endTime;
  final String dateHeadline;
  final String dateDesc;
  final double verticalPadding;
  final Color backgroundColor;
  final EventTypeEnum eventTypeEnum;


  ScheduleOnceAndLongWidgetTwo({
    this.horizontalPadding = 30,
    this.verticalPadding = 20,
    required this.dateHeadline,
    required this.dateDesc,
    this.backgroundColor = AppColors.greyOnBackground,
    required this.eventTypeEnum,
    this.onceDate = '',
    this.longStartDate = '',
    this.longEndDate = '',
    required this.startTime,
    required this.endTime,

  });



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            if (eventTypeEnum == EventTypeEnum.once && onceDate != '') Container(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding (
                child: HeadlineAndDesc(headline: getOurDateFormat(onceDate, '-'), description: 'Дата проведения'),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),



            if (eventTypeEnum == EventTypeEnum.long && longStartDate != '') Container(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding (
                child: HeadlineAndDesc(headline: '${getOurDateFormat(longStartDate, '-')} - ${getOurDateFormat(longEndDate, '-')}', description: 'Даты проведения'),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),

            const SizedBox(width: 10,),

            /*if (eventTypeEnum == EventTypeEnum.long && longEndDate != '') Expanded(
              child: HeadlineAndDesc(headline: getHumanDate(longEndDate, '-'), description: 'Последний день')
            ),*/

            //const SizedBox(width: 20,),

          ],
        ),

        const SizedBox(height: 10,),

        if (startTime != '' && endTime != '' && startTime != endTime) Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding (
            child: HeadlineAndDesc(
                headline: 'с $startTime до $endTime',
                description: 'Время проведения'
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          ),
        ),

      ],
    );
  }
}
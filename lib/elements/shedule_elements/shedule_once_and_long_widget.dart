import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../classes/event_type_enum.dart';
import '../../themes/app_colors.dart';
import '../headline_and_desc.dart';

class ScheduleOnceAndLongWidget extends StatelessWidget {
  final double horizontalPadding;
  final String onceDate;
  final String longStartDate;
  final String longEndDate;
  final String startTime;
  final String endTime;
  final String headline;
  final String desc;
  final double verticalPadding;
  final Color backgroundColor;
  final EventTypeEnum eventTypeEnum;


  ScheduleOnceAndLongWidget({
    this.horizontalPadding = 30,
    this.verticalPadding = 20,
    required this.headline,
    required this.desc,
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
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        child: Row(
          children: [
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headline, style: Theme.of(context).textTheme.titleMedium,),
                    Text(desc, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (eventTypeEnum == EventTypeEnum.once && onceDate != '') HeadlineAndDesc(headline: getHumanDate(onceDate, '-'), description: 'Дата проведения'),
                            if (eventTypeEnum == EventTypeEnum.long && longStartDate != '') HeadlineAndDesc(headline: getHumanDate(longStartDate, '-'), description: 'Первый день'),
                            if (eventTypeEnum == EventTypeEnum.long && longStartDate != '') const SizedBox(height: 20,),
                            if (startTime != '' && endTime != '' && startTime != endTime && eventTypeEnum == EventTypeEnum.long) HeadlineAndDesc(
                                headline: 'с $startTime до $endTime',
                                description: 'Время проведения'
                            ),
                          ],
                        ),

                        SizedBox(width: 30,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (startTime != '' && endTime != '' && startTime != endTime && eventTypeEnum == EventTypeEnum.once) HeadlineAndDesc(
                                headline: 'с $startTime до $endTime',
                                description: 'Время проведения'
                            ),
                            if (eventTypeEnum == EventTypeEnum.long && longEndDate != '') HeadlineAndDesc(headline: getHumanDate(longEndDate, '-'), description: 'Последний день')
                          ],
                        ),
                      ],
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
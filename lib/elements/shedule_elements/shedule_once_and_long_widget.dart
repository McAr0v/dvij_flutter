import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../classes/date_type_enum.dart';
import '../../themes/app_colors.dart';
import '../text_and_icons_widgets/headline_and_desc.dart';

class ScheduleOnceAndLongWidget extends StatelessWidget {
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
  final DateTypeEnum eventTypeEnum;


  ScheduleOnceAndLongWidget({
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
                    Text(dateHeadline, style: Theme.of(context).textTheme.titleMedium,),
                    Text(dateDesc, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (eventTypeEnum == DateTypeEnum.once && onceDate != '') HeadlineAndDesc(headline: getHumanDate(onceDate, '-'), description: 'Дата проведения'),
                            if (eventTypeEnum == DateTypeEnum.long && longStartDate != '') HeadlineAndDesc(headline: getHumanDate(longStartDate, '-'), description: 'Первый день'),
                            if (eventTypeEnum == DateTypeEnum.long && longStartDate != '') const SizedBox(height: 20,),
                            if (startTime != '' && endTime != '' && startTime != endTime && eventTypeEnum == DateTypeEnum.long) HeadlineAndDesc(
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
                            if (startTime != '' && endTime != '' && startTime != endTime && eventTypeEnum == DateTypeEnum.once) HeadlineAndDesc(
                                headline: 'с $startTime до $endTime',
                                description: 'Время проведения'
                            ),
                            if (eventTypeEnum == DateTypeEnum.long && longEndDate != '') HeadlineAndDesc(headline: getHumanDate(longEndDate, '-'), description: 'Последний день')
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
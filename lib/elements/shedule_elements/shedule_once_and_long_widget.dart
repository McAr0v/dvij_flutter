import 'package:dvij_flutter/dates/long_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../classes/date_type_enum.dart';
import '../../dates/date_mixin.dart';
import '../../methods/date_class.dart';
import '../../themes/app_colors.dart';
import '../text_and_icons_widgets/headline_and_desc.dart';

class ScheduleOnceAndLongWidget extends StatelessWidget {
  final double horizontalPadding;
  final OnceDate? onceDate;
  final LongDate? longDates;
  final String dateHeadline;
  final String dateDesc;
  final double verticalPadding;
  final Color backgroundColor;
  final DateTypeEnum dateTypeEnum;


  ScheduleOnceAndLongWidget({
    this.horizontalPadding = 30,
    this.verticalPadding = 20,
    required this.dateHeadline,
    required this.dateDesc,
    this.backgroundColor = AppColors.greyOnBackground,
    required this.dateTypeEnum,
    this.onceDate,
    this.longDates

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
                            if (dateTypeEnum == DateTypeEnum.once && onceDate != null)
                              HeadlineAndDesc(
                                  headline: DateMixin.getHumanDateFromDateTime(onceDate!.startOnlyDate, needYear: true),
                                  description: 'Дата проведения'
                              ),
                            if (dateTypeEnum == DateTypeEnum.long && longDates != null)
                              HeadlineAndDesc(
                                  headline: DateMixin.getHumanDateFromDateTime(longDates!.startOnlyDate, needYear: true),
                                  description: 'Первый день'
                              ),
                            if (dateTypeEnum == DateTypeEnum.long && longDates != null)
                              const SizedBox(height: 20,),
                            if (dateTypeEnum == DateTypeEnum.long && longDates != null)
                              HeadlineAndDesc(
                                headline: TimeMixin.getTimeRange(
                                    longDates!.startStartDate,
                                    longDates!.endEndDate
                                ),
                                description: 'Время проведения'
                            ),
                          ],
                        ),

                        const SizedBox(width: 30,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (dateTypeEnum == DateTypeEnum.once && onceDate != null) HeadlineAndDesc(
                                headline: TimeMixin.getTimeRange(
                                    onceDate!.startDate,
                                    onceDate!.endDate
                                ),
                                description: 'Время проведения'
                            ),
                            if (dateTypeEnum == DateTypeEnum.long && longDates != null)
                              HeadlineAndDesc(
                                  headline: DateMixin.getHumanDateFromDateTime(longDates!.endOnlyDate, needYear: true),
                                  description: 'Последний день'
                              )
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
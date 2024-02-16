import 'package:dvij_flutter/dates/irregular_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../classes/date_type_enum.dart';
import '../../dates/date_mixin.dart';
import '../../themes/app_colors.dart';
import '../text_and_icons_widgets/headline_and_desc.dart';

class ScheduleRegularAndIrregularWidget extends StatelessWidget {
  final double horizontalPadding;
  final IrregularDate? irregularDays;
  final String headline;
  final String desc;
  final double verticalPadding;
  final Color backgroundColor;
  final DateTypeEnum dateTypeEnum;
  final RegularDate? regularTimes; // Передаваемая переменная


  ScheduleRegularAndIrregularWidget({
    this.horizontalPadding = 30,
    this.verticalPadding = 20,
    required this.headline,
    required this.desc,
    this.backgroundColor = AppColors.greyOnBackground,
    required this.dateTypeEnum,
    this.regularTimes,
    this.irregularDays,
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

                        if (dateTypeEnum == DateTypeEnum.regular && regularTimes != null) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(7, (index) {
                            return Column(
                              children: [
                                if (
                                regularTimes!.getDayFromIndex(index).startTime.toString() != 'Не выбрано'
                                    && regularTimes!.getDayFromIndex(index).startTime.toString() != regularTimes!.getDayFromIndex(index).endTime.toString())
                                  HeadlineAndDesc(headline: DateMixin.getHumanWeekday(index+1, false), description: 'День недели'),
                                if (
                                regularTimes!.getDayFromIndex(index).startTime.toString() != 'Не выбрано'
                                    && regularTimes!.getDayFromIndex(index).startTime.toString() != regularTimes!.getDayFromIndex(index).endTime.toString())
                                  const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),

                        if (dateTypeEnum == DateTypeEnum.irregular && irregularDays!.dates.isNotEmpty && irregularDays != null) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(irregularDays!.dates.length, (index) {
                            OnceDate tempDay = irregularDays!.dates[index];
                            return Column(
                              children: [
                                HeadlineAndDesc(headline: DateMixin.getHumanDateFromDateTime(tempDay.startOnlyDate,), description: 'Дата'),
                                const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),



                        SizedBox(width: 30,),

                        if (dateTypeEnum == DateTypeEnum.regular && regularTimes != null) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(7, (index) {
                            return Column(
                              children: [
                                if (
                                regularTimes!.getDayFromIndex(index).startTime.toString() != 'Не выбрано'
                                    && regularTimes!.getDayFromIndex(index).startTime.toString() != regularTimes!.getDayFromIndex(index).endTime.toString())
                                  HeadlineAndDesc(
                                    headline: 'с ${regularTimes!.getDayFromIndex(index).startTime.toString()} до ${regularTimes!.getDayFromIndex(index).endTime.toString()}',
                                    description: 'Время проведения'
                                ),
                                if (
                                regularTimes!.getDayFromIndex(index).startTime.toString() != 'Не выбрано'
                                    && regularTimes!.getDayFromIndex(index).startTime.toString() != regularTimes!.getDayFromIndex(index).endTime.toString())
                                  const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),

                        if (dateTypeEnum == DateTypeEnum.irregular && irregularDays!.dateIsNotEmpty() && irregularDays != null) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(irregularDays!.dates.length, (index) {
                            OnceDate tempDay = irregularDays!.dates[index];
                            return Column(
                              children: [
                                HeadlineAndDesc(
                                    headline: TimeMixin.getTimeRange(tempDay.startDate, tempDay.endDate),
                                    description: 'Время проведения'
                                ),
                                const SizedBox(height: 10,),
                              ],
                            );
                          }),
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
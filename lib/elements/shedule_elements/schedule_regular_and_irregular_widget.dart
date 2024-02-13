import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../classes/date_type_enum.dart';
import '../../dates/date_mixin.dart';
import '../../methods/date_class.dart';
import '../../themes/app_colors.dart';
import '../text_and_icons_widgets/headline_and_desc.dart';

class ScheduleRegularAndIrregularWidget extends StatelessWidget {
  final double horizontalPadding;
  final List<Map<String, DateTime>>? irregularDays;
  final String headline;
  final String desc;
  final double verticalPadding;
  final Color backgroundColor;
  final DateTypeEnum dateTypeEnum;
  final Map<String, String>? regularTimes; // Передаваемая переменная


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

                        if (dateTypeEnum == DateTypeEnum.regular && regularTimes!.isNotEmpty && regularTimes != null) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(regularTimes!.length, (index) {
                            return Column(
                              children: [
                                if (regularTimes!['startTime${index+1}'] != 'Не выбрано' && regularTimes!['startTime${index+1}']!=regularTimes!['endTime${index+1}']) HeadlineAndDesc(headline: DateMixin.getHumanWeekday(index, false), description: 'День недели'),
                                if (regularTimes!['startTime${index+1}'] != 'Не выбрано' && regularTimes!['startTime${index+1}']!=regularTimes!['endTime${index+1}']) const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),

                        if (dateTypeEnum == DateTypeEnum.irregular && irregularDays!.isNotEmpty && irregularDays != null) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(irregularDays!.length, (index) {
                            Map<String, DateTime> tempDay = irregularDays![index];
                            return Column(
                              children: [
                                HeadlineAndDesc(headline: DateMixin.getHumanDateFromDateTime(tempDay['date-startOnlyDate']!,), description: 'Дата'),
                                const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),



                        SizedBox(width: 30,),

                        if (dateTypeEnum == DateTypeEnum.regular && regularTimes!.isNotEmpty && regularTimes != null) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(regularTimes!.length, (index) {
                            return Column(
                              children: [
                                if (regularTimes!['startTime${index+1}'] != 'Не выбрано' && regularTimes!['startTime${index+1}']!=regularTimes!['endTime${index+1}']) HeadlineAndDesc(
                                    headline: 'с ${regularTimes!['startTime${index+1}']} до ${regularTimes!['endTime${index+1}']}',
                                    description: 'Время проведения'
                                ),
                                if (regularTimes!['startTime${index+1}'] != 'Не выбрано' && regularTimes!['startTime${index+1}']!=regularTimes!['endTime${index+1}']) const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),

                        if (dateTypeEnum == DateTypeEnum.irregular && irregularDays!.isNotEmpty && irregularDays != null) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(irregularDays!.length, (index) {
                            Map<String, DateTime> tempDay = irregularDays![index];
                            return Column(
                              children: [
                                HeadlineAndDesc(
                                    headline: TimeMixin.getTimeRange(tempDay['date-startDate']!, tempDay['date-endDate']!),
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
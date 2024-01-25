import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../classes/event_type_enum.dart';
import '../../themes/app_colors.dart';
import '../headline_and_desc.dart';

class ScheduleRegularAndIrregularWidget extends StatelessWidget {
  final double horizontalPadding;
  final List<String> irregularDays;
  final List<String> irregularStartTime;
  final List<String> irregularEndTime;
  final String headline;
  final String desc;
  final double verticalPadding;
  final Color backgroundColor;
  final EventTypeEnum eventTypeEnum;
  final List<String> regularStartTimes; // Передаваемая переменная
  final List<String> regularFinishTimes;


  ScheduleRegularAndIrregularWidget({
    this.horizontalPadding = 30,
    this.verticalPadding = 20,
    required this.headline,
    required this.desc,
    this.backgroundColor = AppColors.greyOnBackground,
    required this.eventTypeEnum,
    this.regularStartTimes = const [],
    this.regularFinishTimes = const [],
    this.irregularDays = const [],
    this.irregularStartTime = const [],
    this.irregularEndTime = const []

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

                        if (eventTypeEnum == EventTypeEnum.regular && regularStartTimes.isNotEmpty && regularFinishTimes.isNotEmpty) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(regularStartTimes.length, (index) {
                            return Column(
                              children: [
                                if (regularStartTimes[index] != '00:00' && regularStartTimes[index]!=regularFinishTimes[index]) HeadlineAndDesc(headline: getHumanWeekday(index, false), description: 'День недели'),
                                if (regularStartTimes[index] != '00:00' && regularStartTimes[index]!=regularFinishTimes[index]) const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),

                        if (eventTypeEnum == EventTypeEnum.irregular && irregularStartTime.isNotEmpty && irregularEndTime.isNotEmpty && irregularDays.isNotEmpty) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(irregularDays.length, (index) {
                            return Column(
                              children: [
                                if (irregularStartTime[index] != '00:00' && irregularStartTime[index]!=irregularEndTime[index]) HeadlineAndDesc(headline: getHumanDate(irregularDays[index], '-'), description: 'Дата'),
                                if (irregularStartTime[index] != '00:00' && irregularStartTime[index]!=irregularEndTime[index]) const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),



                        SizedBox(width: 30,),

                        if (eventTypeEnum == EventTypeEnum.regular && regularStartTimes.isNotEmpty && regularFinishTimes.isNotEmpty) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(regularStartTimes.length, (index) {
                            return Column(
                              children: [
                                if (regularStartTimes[index] != '00:00' && regularStartTimes[index]!=regularFinishTimes[index]) HeadlineAndDesc(
                                    headline: 'с ${regularStartTimes[index]} до ${regularFinishTimes[index]}',
                                    description: 'Время проведения'
                                ),
                                if (regularStartTimes[index] != '00:00' && regularStartTimes[index]!=regularFinishTimes[index]) const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),

                        if (eventTypeEnum == EventTypeEnum.irregular && irregularStartTime.isNotEmpty && irregularEndTime.isNotEmpty && irregularDays.isNotEmpty) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(irregularDays.length, (index) {
                            return Column(
                              children: [
                                if (irregularStartTime[index] != '00:00' && irregularStartTime[index]!=irregularEndTime[index]) HeadlineAndDesc(
                                    headline: 'с ${irregularStartTime[index]} до ${irregularEndTime[index]}',
                                    description: 'Время проведения'
                                ),
                                if (irregularStartTime[index] != '00:00' && irregularStartTime[index]!=irregularEndTime[index]) const SizedBox(height: 10,),
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
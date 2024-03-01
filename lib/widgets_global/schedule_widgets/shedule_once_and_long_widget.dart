import 'package:dvij_flutter/dates/long_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dates/date_type_enum.dart';
import '../../dates/date_mixin.dart';
import '../../themes/app_colors.dart';
import '../text_widgets/headline_and_desc.dart';

class ScheduleOnceAndLongWidget extends StatefulWidget {
  final double horizontalPadding;
  final OnceDate? onceDate;
  final LongDate? longDates;
  final String dateHeadline;
  final String dateDesc;
  final double verticalPadding;
  final Color backgroundColor;
  final DateTypeEnum dateTypeEnum;


  const ScheduleOnceAndLongWidget({super.key,
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
  ScheduleOnceAndLongWidgetState createState() => ScheduleOnceAndLongWidgetState();

}

class ScheduleOnceAndLongWidgetState extends State<ScheduleOnceAndLongWidget> {
  bool openSchedule = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          openSchedule = !openSchedule;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: widget.verticalPadding, horizontal: widget.horizontalPadding),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.dateHeadline, style: Theme.of(context).textTheme.titleMedium,),
                                  const SizedBox(height: 5,),
                                  Text(widget.dateDesc, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
                                ],
                              )
                          ),

                          const SizedBox(width: 10,),

                          IconButton(
                              onPressed: (){
                                setState(() {
                                  openSchedule = !openSchedule;
                                });

                              },
                              icon: Icon(openSchedule == false ? FontAwesomeIcons.chevronRight : FontAwesomeIcons.chevronDown, size: 20,)
                          )
                        ],
                      ),
                      if (openSchedule) const SizedBox(height: 20,),
                      if (openSchedule) Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              if (widget.dateTypeEnum == DateTypeEnum.once && widget.onceDate != null)
                                HeadlineAndDesc(
                                    headline: DateMixin.getHumanDateFromDateTime(widget.onceDate!.startOnlyDate, needYear: true),
                                    description: 'Дата проведения'
                                ),
                              if (widget.dateTypeEnum == DateTypeEnum.long && widget.longDates != null)
                                HeadlineAndDesc(
                                    headline: DateMixin.getHumanDateFromDateTime(widget.longDates!.startOnlyDate, needYear: true),
                                    description: 'Первый день'
                                ),
                              if (widget.dateTypeEnum == DateTypeEnum.long && widget.longDates != null)
                                const SizedBox(height: 20,),
                              if (widget.dateTypeEnum == DateTypeEnum.long && widget.longDates != null)
                                HeadlineAndDesc(
                                    headline: TimeMixin.getTimeRange(
                                        widget.longDates!.startStartDate,
                                        widget.longDates!.endEndDate
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
                              if (widget.dateTypeEnum == DateTypeEnum.once && widget.onceDate != null) HeadlineAndDesc(
                                  headline: TimeMixin.getTimeRange(
                                      widget.onceDate!.startDate,
                                      widget.onceDate!.endDate
                                  ),
                                  description: 'Время проведения'
                              ),
                              if (widget.dateTypeEnum == DateTypeEnum.long && widget.longDates != null)
                                HeadlineAndDesc(
                                    headline: DateMixin.getHumanDateFromDateTime(widget.longDates!.endOnlyDate, needYear: true),
                                    description: 'Последний день'
                                )
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
      ),
    );
  }
}
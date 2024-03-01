import 'package:dvij_flutter/dates/irregular_date_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dates/date_mixin.dart';
import '../../dates/once_date_class.dart';
import '../../dates/time_mixin.dart';
import '../../themes/app_colors.dart';
import '../text_widgets/headline_and_desc.dart';

class ScheduleIrregularWidget extends StatefulWidget {
  final double horizontalPadding;
  final IrregularDate? irregularDays;
  final String headline;
  final String desc;
  final double verticalPadding;
  final Color backgroundColor;
  final bool isPlace; // Передаваемая переменная


  const ScheduleIrregularWidget({super.key,
    this.horizontalPadding = 30,
    this.verticalPadding = 20,
    required this.headline,
    required this.desc,
    this.backgroundColor = AppColors.greyOnBackground,
    this.irregularDays,
    this.isPlace = false,
  });

  @override
  ScheduleIrregularWidgetState createState() => ScheduleIrregularWidgetState();
}

class ScheduleIrregularWidgetState extends State<ScheduleIrregularWidget> {

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
                                  Text(widget.headline, style: Theme.of(context).textTheme.titleMedium,),
                                  const SizedBox(height: 5,),
                                  Text(widget.desc, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
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

                          if (widget.irregularDays!.dates.isNotEmpty && widget.irregularDays != null) Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(widget.irregularDays!.dates.length, (index) {
                              OnceDate tempDay = widget.irregularDays!.dates[index];
                              return Column(
                                children: [
                                  HeadlineAndDesc(headline: DateMixin.getHumanDateFromDateTime(tempDay.startOnlyDate,), description: 'Дата'),
                                  const SizedBox(height: 10,),
                                ],
                              );
                            }),
                          ),


                          const SizedBox(width: 30,),

                          if (widget.irregularDays!.dateIsNotEmpty() && widget.irregularDays != null) Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(widget.irregularDays!.dates.length, (index) {
                              OnceDate tempDay = widget.irregularDays!.dates[index];
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
      ),
    );
  }
}
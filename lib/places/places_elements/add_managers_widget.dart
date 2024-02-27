import 'package:dvij_flutter/dates/irregular_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dates/date_type_enum.dart';
import '../../dates/date_mixin.dart';
import '../../themes/app_colors.dart';
import '../../widgets_global/text_widgets/headline_and_desc.dart';

class AddManagersWidget extends StatefulWidget {
  final double horizontalPadding;
  final RegularDate regularDate;
  final String headline;
  final String desc;
  final double verticalPadding;
  final Color backgroundColor;
  final bool isPlace; // Передаваемая переменная


  const AddManagersWidget({super.key,
    this.horizontalPadding = 30,
    this.verticalPadding = 20,
    required this.headline,
    required this.desc,
    this.backgroundColor = AppColors.greyOnBackground,
    required this.regularDate,
    this.isPlace = false,
  });

  @override
  _AddManagersWidgetState createState() => _AddManagersWidgetState();
}

class _AddManagersWidgetState extends State<AddManagersWidget> {
  bool openSchedule = false;


  @override
  Widget build(BuildContext context) {


    return Container(
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
                              children: [
                                Text(widget.headline, style: Theme.of(context).textTheme.titleMedium,),
                                const SizedBox(height: 5,),
                                Text(widget.desc, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                          children: List.generate(7, (index) {
                            bool haveDate = widget.regularDate.getDayFromIndex(index).startTime.toString() != 'Не выбрано'
                                && widget.regularDate.getDayFromIndex(index).startTime.toString() != widget.regularDate.getDayFromIndex(index).endTime.toString();
                            return Column(
                              children: [
                                if (haveDate) HeadlineAndDesc(headline: DateMixin.getHumanWeekday(index+1, false), description: 'День недели'),
                                if (haveDate) const SizedBox(height: 10,),
                                if (!haveDate && widget.isPlace) HeadlineAndDesc(headline: DateMixin.getHumanWeekday(index+1, false), description: 'День недели'),
                                if (!haveDate && widget.isPlace) const SizedBox(height: 10,),
                              ],
                            );
                          }),
                        ),

                        SizedBox(width: 30,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(7, (index) {
                            bool haveDate = widget.regularDate.getDayFromIndex(index).startTime.toString() != 'Не выбрано'
                                && widget.regularDate.getDayFromIndex(index).startTime.toString() != widget.regularDate.getDayFromIndex(index).endTime.toString();
                            return Column(
                              children: [

                                if (haveDate)
                                  HeadlineAndDesc(
                                      headline: 'с ${widget.regularDate.getDayFromIndex(index).startTime.toString()} до ${widget.regularDate.getDayFromIndex(index).endTime.toString()}',
                                      description: !widget.isPlace ? 'Время проведения' : 'Время работы'
                                  ),
                                if (!haveDate && widget.isPlace)
                                  const HeadlineAndDesc(
                                      headline: 'Выходной',
                                      description: 'Время работы'
                                  ),
                                if (haveDate)
                                  const SizedBox(height: 10,),
                                if (!haveDate && widget.isPlace)
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
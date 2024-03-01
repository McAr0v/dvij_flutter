import 'package:dvij_flutter/dates/long_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/widgets_global/schedule_widgets/schedule_irregular_widget.dart';
import 'package:dvij_flutter/widgets_global/schedule_widgets/schedule_regular_widget.dart';
import 'package:dvij_flutter/widgets_global/schedule_widgets/shedule_once_and_long_widget.dart';
import 'package:flutter/cupertino.dart';

import '../../dates/date_type_enum.dart';
import '../../dates/irregular_date_class.dart';

class ScheduleWidget extends StatelessWidget {

  final EventCustom? event;
  final PromoCustom? promo;

  const ScheduleWidget({super.key, this.event, this.promo}); // Передаваемая переменная


  @override
  Widget build(BuildContext context) {

    DateTypeEnum dateTypeEnum = event != null ? event!.dateType : promo!.dateType;
    OnceDate onceDate = event != null ? event!.onceDay : promo!.onceDay;
    LongDate longDate = event != null ? event!.longDays : promo!.longDays;
    RegularDate regularDate = event != null ? event!.regularDays : promo!.regularDays;
    IrregularDate irregularDate = event != null ? event!.irregularDays : promo!.irregularDays;
    String entityName = event != null ? 'Мероприятие' : 'Акция';

    return Stack(
      children: [
        if (dateTypeEnum == DateTypeEnum.once || dateTypeEnum == DateTypeEnum.long) ScheduleOnceAndLongWidget(
          dateHeadline: dateTypeEnum == DateTypeEnum.once? 'Дата проведения' : 'Расписание',
          dateDesc: dateTypeEnum == DateTypeEnum.once? '$entityName проводится один раз' : '$entityName проводится каждую неделю в определенные дни',
          dateTypeEnum: dateTypeEnum,
          onceDate: dateTypeEnum == DateTypeEnum.once? onceDate : null,
          longDates: dateTypeEnum == DateTypeEnum.long ? longDate : null,
        ),

        if (dateTypeEnum == DateTypeEnum.regular) ScheduleRegularWidget(
            headline: 'Расписание',
            desc: '$entityName проводится каждую неделю в определенные дни',
            regularDate: regularDate,
            isPlace: false
        ),

        if (dateTypeEnum == DateTypeEnum.irregular) ScheduleIrregularWidget(
          irregularDays: irregularDate,
          headline: 'Расписание',
          desc: '$entityName проводится в определенные дни',
        ),
      ],
    );
  }

}
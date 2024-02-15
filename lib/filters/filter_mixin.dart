import '../classes/date_type_enum.dart';
import '../dates/date_mixin.dart';
import '../events/event_class.dart';

mixin FilterMixin {

  static bool checkEventDatesForFilter (
      EventCustom event,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    DateTypeEnum dateTypeEnum = event.dateType;

    switch (dateTypeEnum) {
      case DateTypeEnum.once: return event.onceDay.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.long: return event.longDays.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.regular: return checkEventRegularDayForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.irregular: return event.irregularDays.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
    }

  }

  static bool checkEventRegularDayForFilter (
      EventCustom event,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    // ФУНКЦИЯ ПРОВЕРКИ РЕГУЛЯРНОЙ ДАТЫ НА ПОПАДАНИЕ В ЗАДАННЫЙ ПЕРИОД

    bool result = false;

    List<int> eventWeekDays = [];
    List<int> filterWeekDays = [];

    // Считываем дни недели, в которые проводится мероприятие
    for (int i = 0; i<7; i++){

      String startTime = event.regularDays['startTime${i+1}']!;

      if (startTime != 'Не выбрано') eventWeekDays.add(i+1);

    }

    // Считываем дни недели периода из фильтра

    for (int i = 0; i<7; i++){

      DateTime tempDate = selectedStartDatePeriod.add(Duration(days: i));

      if (DateMixin.dateIsBeforeEnd(tempDate, selectedEndDatePeriod)){
        filterWeekDays.add(tempDate.weekday);
      }
    }

    for (int eventWeekDay in eventWeekDays){
      if (eventWeekDays.isNotEmpty && filterWeekDays.isNotEmpty && filterWeekDays.contains(eventWeekDay)) {
        result = true;
      }
    }

    return result;

  }
}
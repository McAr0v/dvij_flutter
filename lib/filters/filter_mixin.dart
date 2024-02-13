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
      case DateTypeEnum.once: return checkEventOnceDayForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.long: return checkEventLongDayForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.regular: return checkEventRegularDayForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.irregular: return checkEventIrregularDayForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);
    }

  }

  static bool checkEventOnceDayForFilter (
      EventCustom event,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    // ФУНКЦИЯ ПРОВЕРКИ ОДИНОЧНОЙ ДАТЫ НА ПОПАДАНИЕ В ЗАДАННЫЙ ПЕРИОД

    return DateMixin.dateIsInPeriod(event.onceDay['date-startOnlyDate']!, selectedStartDatePeriod, selectedEndDatePeriod);

  }

  static bool checkEventLongDayForFilter (
      EventCustom event,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    // ФУНКЦИЯ ПРОВЕРКИ ДАТЫ В ВИДЕ ПЕРИОДА НА ПОПАДАНИЕ В ЗАДАННЫЙ ПЕРИОД

    DateTime eventStartDate = event.longDays['startDate-startOnlyDate']!;
    DateTime eventEndDate = event.longDays['endDate-endDate']!;

    print(event.longDays['startDate-startOnlyDate']!);
    print(event.longDays['startDate-startDate']!);
    print(event.longDays['startDate-endDate']!);
    print(event.longDays['endDate-startOnlyDate']!);
    print(event.longDays['endDate-startDate']!);
    print(event.longDays['endDate-endDate']!);

    return (eventStartDate.isBefore(selectedEndDatePeriod) || eventStartDate.isAtSameMomentAs(selectedEndDatePeriod)) &&
        (eventEndDate.isAfter(selectedStartDatePeriod) || eventEndDate.isAtSameMomentAs(selectedStartDatePeriod));

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

  static bool checkEventIrregularDayForFilter(
      EventCustom event,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ){

    // Проходим по списку
    for (int i = 0; i<event.irregularDays.length; i++){

      Map<String, DateTime> tempDay = event.irregularDays[i];

      if (DateMixin.dateIsInPeriod(tempDay['date-startOnlyDate']!, selectedStartDatePeriod, selectedEndDatePeriod)){
        return true;
      }

    }

    return false;

  }

}
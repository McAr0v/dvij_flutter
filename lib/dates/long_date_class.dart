import 'date_mixin.dart';
import '../interfaces/dates_interface.dart';

class LongDate with DateMixin implements IDates<LongDate> {

  DateTime startStartDate = DateTime(2100);
  DateTime startEndDate = DateTime(2100);
  DateTime endStartDate = DateTime(2100);
  DateTime endEndDate = DateTime(2100);
  DateTime startOnlyDate = DateTime(2100);
  DateTime endOnlyDate = DateTime(2100);

  LongDate({
    DateTime? startStartDate,
    DateTime? startEndDate,
    DateTime? endStartDate,
    DateTime? endEndDate,
    DateTime? startOnlyDate,
    DateTime? endOnlyDate,
  })
  {
    this.startStartDate = startStartDate ?? this.startStartDate;
    this.startEndDate = startEndDate ?? this.startEndDate;
    this.endStartDate = endStartDate ?? this.endStartDate;
    this.endEndDate = endEndDate ?? this.endEndDate;
    this.startOnlyDate = startOnlyDate ?? this.startOnlyDate;
    this.endOnlyDate = endOnlyDate ?? this.endOnlyDate;
  }

  @override
  bool dateIsNotEmpty() {
    DateTime defaultDate = DateTime(2100);
    return startStartDate != defaultDate
        && startEndDate != defaultDate
        && startOnlyDate != defaultDate
        && endOnlyDate != defaultDate
        && endEndDate != defaultDate
        && endStartDate != defaultDate
    ;
  }

  static Map<String, dynamic> generateLongMapForEntity (DateTime startDate, DateTime endDate, String startTime, String endTime){
    return {
      'startTime': startTime,
      'endTime': endTime,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  @override
  LongDate generateDateForEntity(Map<String, dynamic> mapOfArguments) {

    LongDate longDate = LongDate();

    String startTime = mapOfArguments['startTime'];
    String endTime = mapOfArguments['endTime'];
    DateTime startDay = mapOfArguments['startDate'];
    DateTime endDay = mapOfArguments['endDate'];

    if (startTime != 'Не выбрано' && endTime != 'Не выбрано'){

      DateTime startDateStartDate = DateTime.parse(
          '${startDay.year}-${DateMixin.getCorrectMonthOrDate(startDay.month)}-${DateMixin.getCorrectMonthOrDate(startDay.day)} $startTime');
      DateTime startDateEndDate = DateTime.parse(
          '${startDay.year}-${DateMixin.getCorrectMonthOrDate(startDay.month)}-${DateMixin.getCorrectMonthOrDate(startDay.day)} $endTime');
      DateTime endDateStartDate = DateTime.parse(
          '${endDay.year}-${DateMixin.getCorrectMonthOrDate(endDay.month)}-${DateMixin.getCorrectMonthOrDate(endDay.day)} $startTime');
      DateTime endDateEndDate = DateTime.parse(
          '${endDay.year}-${DateMixin.getCorrectMonthOrDate(endDay.month)}-${DateMixin.getCorrectMonthOrDate(endDay.day)} $endTime');

      if (startDateStartDate.isAfter(startDateEndDate)){
        startDateEndDate = startDateEndDate.add(const Duration(days: 1));
        endDateEndDate = endDateEndDate.add(const Duration(days: 1));
      }

      longDate.startStartDate = startDateStartDate;
      longDate.startEndDate = startDateEndDate;
      longDate.startOnlyDate = startDay;
      longDate.endStartDate = endDateStartDate;
      longDate.endEndDate = endDateEndDate;
      longDate.endOnlyDate = endDay;

    }

    return longDate;
  }

  @override
  String generateDateStingForDb() {
    if (dateIsNotEmpty()) {
      return '{'
          '"startDate": "${startStartDate.year}-${DateMixin.getCorrectMonthOrDate(startStartDate.month)}-${DateMixin.getCorrectMonthOrDate(startStartDate.day)}", '
          '"endDate": "${endOnlyDate.year}-${DateMixin.getCorrectMonthOrDate(endOnlyDate.month)}-${DateMixin.getCorrectMonthOrDate(endOnlyDate.day)}", '
          '"startTime": "${DateMixin.getCorrectMonthOrDate(startStartDate.hour)}:${DateMixin.getCorrectMonthOrDate(startStartDate.minute)}", '
          '"endTime": "${DateMixin.getCorrectMonthOrDate(endEndDate.hour)}:${DateMixin.getCorrectMonthOrDate(endEndDate.minute)}"'
          '}';
    } else {
      return '';
    }
  }

  @override
  LongDate getFromJson(String json) {
    LongDate result = LongDate();

    String startDateString = extractDateOrTimeFromJson(json, 'startDate');
    String endDateString = extractDateOrTimeFromJson(json, 'endDate');
    String startTime = extractDateOrTimeFromJson(json, 'startTime');
    String endTime = extractDateOrTimeFromJson(json, 'endTime');

    if (startTime != 'Не выбрано' && endTime != 'Не выбрано') {

      DateTime startStartDate = DateTime.parse('$startDateString $startTime');
      DateTime startEndDate = DateTime.parse('$startDateString $endTime');
      DateTime startOnlyDate = DateTime.parse(startDateString);

      DateTime endStartDate = DateTime.parse('$endDateString $startTime');
      DateTime endEndDate = DateTime.parse('$endDateString $endTime');
      DateTime endOnlyDate = DateTime.parse(endDateString);


      if (endEndDate.isBefore(endStartDate)) endEndDate = endEndDate.add(const Duration(days: 1));
      if (startEndDate.isBefore(startStartDate)) startEndDate = startEndDate.add(const Duration(days: 1));

      result.startOnlyDate = startOnlyDate;
      result.startStartDate = startStartDate;
      result.startEndDate = startEndDate;
      result.endStartDate = endStartDate;
      result.endEndDate = endEndDate;
      result.endOnlyDate = endOnlyDate;

    }
    return result;
  }

  @override
  bool todayOrNot() {
    bool today = false;
    // Проверяем - сегодня вообще находится в периоде проведения или нет
    bool inPeriod = DateMixin.nowIsInPeriod(startOnlyDate, endEndDate);
    // Если сегодня в периоде, проверим на сегодня - не завершилось ли уже мероприятие или акция
    if (inPeriod) {
      DateTime todayDay = DateTime.now();
      DateTime tempStartDay = DateTime(todayDay.year, todayDay.month, todayDay.day);
      DateTime tempEndDay = DateTime(todayDay.year, todayDay.month, todayDay.day, endEndDate.hour, endEndDate.minute);

      // Если дата завершения не равна дате начала, значит заканчивается после полуночи
      // и нужно добавить к временной переменной день

      if (endEndDate.day != endStartDate.day) tempEndDay = tempEndDay.add(const Duration(days: 1));

      today = DateMixin.nowIsInPeriod(tempStartDay, tempEndDay);

    }
    return today;
  }

  @override
  bool checkDateForFilter(DateTime startPeriod, DateTime endPeriod) {
    return (startOnlyDate.isBefore(endPeriod) || startOnlyDate.isAtSameMomentAs(endPeriod)) &&
        (endStartDate.isAfter(startPeriod) || endStartDate.isAtSameMomentAs(startPeriod));
  }



}
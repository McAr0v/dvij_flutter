import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/dates/dates_interface.dart';

class OnceDate with DateMixin implements IDates<OnceDate> {

  DateTime startDate = DateTime(2100);
  DateTime endDate = DateTime(2100);
  DateTime startOnlyDate = DateTime(2100);

  OnceDate({DateTime? startDate, DateTime? endDate, DateTime? startOnlyDate}){
    this.startDate = startDate ?? this.startDate;
    this.endDate = endDate ?? this.endDate;
    this.startOnlyDate = startOnlyDate ?? this.startOnlyDate;
  }


  @override
  OnceDate getFromJson(String json) {
    OnceDate tempDates = OnceDate();

    String onceDay = extractDateOrTimeFromJson(json, 'date');
    String startTime = extractDateOrTimeFromJson(json, 'startTime');
    String endTime = extractDateOrTimeFromJson(json, 'endTime');

    if (startTime != 'Не выбрано' && endTime != 'Не выбрано') {

      DateTime startDate = DateTime.parse(
          '$onceDay $startTime');

      DateTime endDate = DateTime.parse(
          '$onceDay $endTime');

      DateTime startDateOnlyDate = DateTime.parse(onceDay);

      if (endDate.isBefore(startDate)) endDate = endDate.add(const Duration(days: 1));

      tempDates.startOnlyDate = startDateOnlyDate;
      tempDates.startDate = startDate;
      tempDates.endDate = endDate;

    }
    return tempDates;
  }

  @override
  String generateDateStingForDb() {
    if (dateIsNotEmpty()){

      return '{'
          '"date": "${startDate.year}-${DateMixin.getCorrectMonthOrDate(startDate.month)}-${DateMixin.getCorrectMonthOrDate(startDate.day)}", '
          '"startTime": "${DateMixin.getCorrectMonthOrDate(startDate.hour)}:${DateMixin.getCorrectMonthOrDate(startDate.minute)}", '
          '"endTime": "${DateMixin.getCorrectMonthOrDate(endDate.hour)}:${DateMixin.getCorrectMonthOrDate(endDate.minute)}"'
          '}';
    } else {
      return '';
    }
  }

  @override
  bool dateIsNotEmpty() {
    DateTime defaultDate = DateTime(2100);
    return startDate != defaultDate && startOnlyDate != defaultDate && endDate != defaultDate;
  }

  static Map<String, dynamic> generateOnceMapForEntity (DateTime day, String startTime, String endTime){
    return {
      'startTime': startTime,
      'endTime': endTime,
      'date': day
    };
  }

  @override
  OnceDate generateDateForEntity(Map<String, dynamic> mapOfArguments) {

    OnceDate onceDate = OnceDate();

    String startTime = mapOfArguments['startTime'];
    String endTime = mapOfArguments['endTime'];
    DateTime onceDay = mapOfArguments['date'];

    if (startTime != 'Не выбрано' && endTime != 'Не выбрано'){

      DateTime startDate = DateTime.parse(
          '${onceDay.year}-${DateMixin.getCorrectMonthOrDate(onceDay.month)}-${DateMixin.getCorrectMonthOrDate(onceDay.day)} $startTime');

      DateTime endDate = DateTime.parse(
          '${onceDay.year}-${DateMixin.getCorrectMonthOrDate(onceDay.month)}-${DateMixin.getCorrectMonthOrDate(onceDay.day)} $endTime');

      if (endDate.isBefore(startDate)) endDate = endDate.add(const Duration(days: 1));

      onceDate.startDate = startDate;
      onceDate.startOnlyDate = onceDay;
      onceDate.endDate = endDate;

    }

    return onceDate;
  }

  @override
  bool todayOrNot() {
    if (startDate.isAfter(endDate)) endDate = endDate.add(const Duration(days: 1));
    return DateMixin.nowIsInPeriod(startOnlyDate, endDate);
  }

  @override
  bool checkDateForFilter(DateTime startPeriod, DateTime endPeriod) {
    return DateMixin.dateIsInPeriod(startOnlyDate, startPeriod, endPeriod);
  }



}
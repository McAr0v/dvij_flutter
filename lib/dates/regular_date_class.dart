import 'dart:core';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/dates/times/time_class.dart';
import 'package:dvij_flutter/dates/times/times_in_date_class.dart';

import 'date_mixin.dart';
import 'dates_interface.dart';

class RegularDate with DateMixin, TimeMixin implements IDates<RegularDate> {

  TimesInDate monday = TimesInDate();
  TimesInDate tuesday = TimesInDate();
  TimesInDate wednesday = TimesInDate();
  TimesInDate thursday = TimesInDate();
  TimesInDate friday = TimesInDate();
  TimesInDate saturday = TimesInDate();
  TimesInDate sunday = TimesInDate();

  RegularDate();

  @override
  bool checkDateForFilter(DateTime startPeriod, DateTime endPeriod) {
    // TODO: implement checkDateForFilter
    throw UnimplementedError();
  }


  // --- ЗАКОНЧИЛ ЗДЕЕСЬ
  @override
  bool dateIsNotEmpty() {
    bool result = true;

    for (int i = 0; i<7; i++){
      TimesInDate tempTime = getDayFromIndex(i);
      if (tempTime.emptyTimeOrNot() == true) result = false;
    }

    return result;
  }

  static Map<String, dynamic> generateOnceMapForEntity (List<String> startTimes, List<String> endTimes){
    return {
      'startTimes': startTimes,
      'endTimes': endTimes,
    };
  }

  TimesInDate getDayFromIndex (int index){
    switch (index) {
      case 0 : return monday;
      case 1 : return tuesday;
      case 2 : return wednesday;
      case 3 : return thursday;
      case 4 : return friday;
      case 5 : return saturday;
      default : return sunday;
    }
  }

  @override
  RegularDate generateDateForEntity(Map<String, dynamic> mapOfArguments) {
    List<String> startTimes = mapOfArguments['startTimes'];
    List<String> endTimes = mapOfArguments['endTimes'];

    RegularDate tempDate = RegularDate();

    tempDate.monday = TimesInDate(startTime: startTimes[0], endTime: endTimes[0]);
    tempDate.tuesday = TimesInDate(startTime: startTimes[1], endTime: endTimes[1]);
    tempDate.wednesday = TimesInDate(startTime: startTimes[2], endTime: endTimes[2]);
    tempDate.thursday = TimesInDate(startTime: startTimes[3], endTime: endTimes[3]);
    tempDate.friday = TimesInDate(startTime: startTimes[4], endTime: endTimes[4]);
    tempDate.saturday = TimesInDate(startTime: startTimes[5], endTime: endTimes[5]);
    tempDate.sunday = TimesInDate(startTime: startTimes[6], endTime: endTimes[6]);

    return tempDate;


  }

  @override
  String generateDateStingForDb() {
    return '{'
        '"startTime${1}": "${monday.startTime.toString()}", "endTime${1}": "${monday.endTime.toString()}", '
        '"startTime${2}": "${tuesday.startTime.toString()}", "endTime${2}": "${tuesday.endTime.toString()}", '
        '"startTime${3}": "${wednesday.startTime.toString()}", "endTime${3}": "${wednesday.endTime.toString()}", '
        '"startTime${4}": "${thursday.startTime.toString()}", "endTime${4}": "${thursday.endTime.toString()}", '
        '"startTime${5}": "${friday.startTime.toString()}", "endTime${5}": "${friday.endTime.toString()}", '
        '"startTime${6}": "${saturday.startTime.toString()}", "endTime${6}": "${saturday.endTime.toString()}", '
        '"startTime${7}": "${sunday.startTime.toString()}", "endTime${7}": "${sunday.endTime.toString()}", '
        '}';
  }

  @override
  RegularDate getFromJson(String json) {

    RegularDate tempDate = RegularDate();

    tempDate.monday = TimesInDate(startTime: extractDateOrTimeFromJson(json, 'startTime${1}'), endTime: extractDateOrTimeFromJson(json, 'endTime${1}'));
    tempDate.tuesday = TimesInDate(startTime: extractDateOrTimeFromJson(json, 'startTime${2}'), endTime: extractDateOrTimeFromJson(json, 'endTime${2}'));
    tempDate.wednesday = TimesInDate(startTime: extractDateOrTimeFromJson(json, 'startTime${3}'), endTime: extractDateOrTimeFromJson(json, 'endTime${3}'));
    tempDate.thursday = TimesInDate(startTime: extractDateOrTimeFromJson(json, 'startTime${4}'), endTime: extractDateOrTimeFromJson(json, 'endTime${4}'));
    tempDate.friday = TimesInDate(startTime: extractDateOrTimeFromJson(json, 'startTime${5}'), endTime: extractDateOrTimeFromJson(json, 'endTime${5}'));
    tempDate.saturday = TimesInDate(startTime: extractDateOrTimeFromJson(json, 'startTime${6}'), endTime: extractDateOrTimeFromJson(json, 'endTime${6}'));
    tempDate.sunday = TimesInDate(startTime: extractDateOrTimeFromJson(json, 'startTime${7}'), endTime: extractDateOrTimeFromJson(json, 'endTime${7}'));

    return tempDate;

  }

  @override
  bool todayOrNot() {
    // TODO: implement todayOrNot
    throw UnimplementedError();
  }



}
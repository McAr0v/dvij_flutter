import 'package:dvij_flutter/dates/times/time_class.dart';

class TimesInDate {
  TimeCustom startTime = TimeCustom();
  TimeCustom endTime = TimeCustom();

  TimesInDate({String? startTime, String? endTime}) {
    this.startTime = startTime != null ? TimeCustom(time: startTime) : TimeCustom();
    this.endTime = endTime != null ? TimeCustom(time: endTime) : TimeCustom();
  }

  bool emptyTimeOrNot(){
    return !(startTime.toString() == 'Не выбрано' || endTime.toString() == 'Не выбрано');
  }

}
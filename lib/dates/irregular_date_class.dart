import 'package:dvij_flutter/dates/once_date_class.dart';
import 'date_mixin.dart';
import '../interfaces/dates_interface.dart';

class IrregularDate with DateMixin implements IDates<IrregularDate> {

  List<OnceDate> dates = [];

  IrregularDate({
    List<OnceDate>? dates
  }) {
    this.dates = dates ?? this.dates;
  }

  @override
  bool dateIsNotEmpty() {
    return dates.isNotEmpty;
  }

  static Map<String, dynamic> generateIrregularMapForEntity ( List<DateTime> dates, List<String> startTimes, List<String> endTimes){
    return {
      'dates': dates,
      'startTimes': startTimes,
      'endTimes': endTimes,
    };
  }

  @override
  IrregularDate generateDateForEntity(Map<String, dynamic> mapOfArguments) {

    // Здесь хранятся выбранные даты нерегулярных дней
    List<DateTime> chosenDays = mapOfArguments['dates'];
    // Выбранные даты начала
    List<String> chosenStartTimes = mapOfArguments['startTimes'];
    // Выбранные даты завершения
    List<String> chosenEndTimes = mapOfArguments['endTimes'];

    IrregularDate date = IrregularDate();

    for (int i = 0; i<chosenDays.length; i++){
      Map<String, dynamic> tempMap = {
        'date': chosenDays[i],
        'startTime': chosenStartTimes[i],
        'endTime': chosenEndTimes[i]
      };
      OnceDate tempDate = OnceDate();
      date.dates.add(tempDate.generateDateForEntity(tempMap));
    }
    return date;
  }

  @override
  String generateDateStingForDb() {
    String result = '';

    if (dateIsNotEmpty()){
      if (dates.length >= 2){
        // Сортируем список словарей с датами по DateTime
        dates.sort((a, b) => a.startDate.compareTo(b.startDate));
      }

      result = '[';

      for (int i = 0; i<dates.length; i++){

        OnceDate tempDate = dates[i];

        result = '$result{'
            '"date": '
            '"${tempDate.startDate.year}-'
            '${DateMixin.getCorrectMonthOrDate(tempDate.startDate.month)}-'
            '${DateMixin.getCorrectMonthOrDate(tempDate.startDate.day)}", '
            '"startTime": '
            '"${DateMixin.getCorrectMonthOrDate(tempDate.startDate.hour)}:${DateMixin.getCorrectMonthOrDate(tempDate.startDate.minute)}", '
            '"endTime": '
            '"${DateMixin.getCorrectMonthOrDate(tempDate.endDate.hour)}:${DateMixin.getCorrectMonthOrDate(tempDate.endDate.minute)}"'
            '}';


        if (dates.length -1 != i){
          result = '${result}_';
        }
      }
      result = '$result]';
    }
    return result;
  }

  @override
  IrregularDate getFromJson(String json) {
    IrregularDate irregularDate = IrregularDate();

    if (json != ''){
      List<String> datesList = _splitJsonWithManyDates(json);


      for (int i = 0; i < datesList.length; i++){
        OnceDate temp = OnceDate();
        irregularDate.dates.add(temp.getFromJson(datesList[i]));
      }
    }
    return irregularDate;
  }

  List<String> _splitJsonWithManyDates(String json){
    // Удаляем квадратные скобки в начале и в конце строки
    String trimmedJsonString = json.substring(1, json.length - 1);

    // Разделяем элементы списка по символу нижнего подчеркивания '_'
    return trimmedJsonString.split('_');

  }

  @override
  bool todayOrNot() {
    for (OnceDate onceDate in dates){
      bool result = onceDate.todayOrNot();
      if (result) return true;
    }
    return false;
  }

  List<int> getIrregularTodayIndexes(){
    DateTime timeNow = DateTime.now();
    List<int> tempList = [];

    if (dateIsNotEmpty()){

      for (int i = 0; i<dates.length; i++){

        OnceDate tempDay = dates[i];

        if (tempDay.startDate.day == timeNow.day && tempDay.startDate.month == timeNow.month){
          tempList.add(i);
        }
      }
    }
    return tempList;
  }

  @override
  bool checkDateForFilter(DateTime startPeriod, DateTime endPeriod) {
    // Проходим по списку

    for (OnceDate date in dates){
      if (DateMixin.dateIsInPeriod(date.startOnlyDate, startPeriod, endPeriod)){
        return true;
      }
    }

    return false;
  }

}
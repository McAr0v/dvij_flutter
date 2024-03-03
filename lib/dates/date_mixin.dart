import 'dart:convert';
import 'package:dvij_flutter/dates/date_type_enum.dart';
import 'package:dvij_flutter/dates/irregular_date_class.dart';
import 'package:dvij_flutter/dates/long_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';

mixin DateMixin {

  static DateTime getDateFromString(String date){
    return DateTime.parse(date);
  }

  static String generateDateString(DateTime date){
    return '${date.year}-${getCorrectMonthOrDate(date.month)}-${getCorrectMonthOrDate(date.day)}';
  }

  static String getCorrectMonthOrDate(int number){
    if (number < 10) {
      return '0$number';
    } else {
      return '$number';
    }
  }

  static String getMonthName (String month)
  {
    switch (month)
    {
      case '1': return 'января';
      case '01': return 'января';
      case '2': return 'февраля';
      case '02': return 'февраля';
      case '3': return 'марта';
      case '03': return 'марта';
      case '4': return 'апреля';
      case '04': return 'апреля';
      case '5': return 'мая';
      case '05': return 'мая';
      case '6': return 'июня';
      case '06': return 'июня';
      case '7': return 'июля';
      case '07': return 'июля';
      case '8': return 'августа';
      case '08': return 'августа';
      case '9': return 'сентября';
      case '09': return 'сентября';
      case '10': return 'октября';
      case '11': return 'ноября';
      default: return 'декабря';
    }
  }

  static String getHumanWeekday (int weekdayIndex, bool cut)
  {
    switch (weekdayIndex)
    {
      case 1: return !cut ? 'Понедельник' : 'Пн';
      case 2: return !cut ? 'Вторник' : 'Вт';
      case 3: return !cut ? 'Среда' : 'Ср';
      case 4: return !cut ? 'Четверг' : 'Чт';
      case 5: return !cut ? 'Пятница' : 'Пт';
      case 6: return !cut ? 'Суббота' : 'Сб';
      case 7: return !cut ? 'Воскресенье' : 'Вс';

      default: return !cut ? 'Неизвестный индекс дня недели' : 'Err';
    }
  }

  static String getHumanDate (String date, String symbol, {bool needYear = true})
  {
    List<String> stringElements = date.split(symbol);
    String month = getMonthName(stringElements[1]);

    if (needYear) {
      return '${stringElements[2]} $month ${stringElements[0]}';
    } else {
      return '${stringElements[2]} $month';
    }

  }

  static String getHumanDateFromDateTime (DateTime date, {bool needYear = true})
  {
    String month = getMonthName('${date.month}');

    if (needYear) {
      return '${getCorrectMonthOrDate(date.day)} $month ${date.year}';
    } else {
      return '${getCorrectMonthOrDate(date.day)} $month';
    }

  }

  static bool nowIsInPeriod (DateTime startDate, DateTime endDate){
    return nowIsAfterStart(startDate) && nowIsBeforeEnd(endDate);
  }

  static bool nowIsAfterStart (DateTime checkedDate){
    return DateTime.now().isAfter(checkedDate) || DateTime.now().isAtSameMomentAs(checkedDate);
  }

  static bool nowIsBeforeEnd (DateTime checkedDate){
    return DateTime.now().isBefore(checkedDate) || DateTime.now().isAtSameMomentAs(checkedDate);
  }

  static bool dateIsInPeriod (DateTime checkedDate, DateTime startDate, DateTime endDate){
    return dateIsAfterStart(checkedDate, startDate) && dateIsBeforeEnd(checkedDate, endDate);
  }

  static bool dateIsAfterStart (DateTime checkedDate, DateTime startDate){
    return checkedDate.isAfter(startDate) || checkedDate.isAtSameMomentAs(startDate);
  }

  static bool dateIsBeforeEnd (DateTime checkedDate, DateTime endDate){
    return checkedDate.isBefore(endDate) || checkedDate.isAtSameMomentAs(endDate);
  }

  /// Функция получения даты или времени из Json-строки из Firebase RealTimeDatabase
  ///
  /// <br>
  /// [String] jsonString - это сама строка, которую нужно декодировать
  ///
  /// <br>
  /// [String] fieldId - это ключевое плово, по которому парсится значение
  String extractDateOrTimeFromJson(String jsonString, String fieldId) {

    // Декодируем JSON строку
    Map<String, dynamic> json = jsonDecode(jsonString);

    // Извлекаем значение "date"
    String dateStr = json[fieldId];

    return dateStr;
  }

  /// Функция определяет, сегодня состоится мероприятие или акция, или нет
  ///
  /// <br>
  ///
  /// Определяет данный параметр для любого из типов дат.
  static bool todayOrNot(
          DateTypeEnum dateType,
          OnceDate onceDay,
          LongDate longDays,
          RegularDate regularDays,
          IrregularDate irregularDays,
      ){

    switch (dateType) {
      case DateTypeEnum.once : {
        return onceDay.todayOrNot();
      }

      case DateTypeEnum.long : {
        return longDays.todayOrNot();
      }

      case DateTypeEnum.regular : {
        return regularDays.todayOrNot();
      }

      case DateTypeEnum.irregular : {
        return irregularDays.todayOrNot();
      }

    }
  }

  static String checkTimeAndDate(
      DateTypeEnum eventType,
      DateTime selectedDayInOnceType,
      String onceDayStartTime,
      String onceDayFinishTime,
      DateTime selectedStartDayInLongType,
      DateTime selectedEndDayInLongType,
      String longDayStartTime,
      String longDayFinishTime,
      List<String> regularStartTimes,
      List<String> regularFinishTimes,
      List<DateTime> chosenIrregularDays,
      List<String> chosenIrregularStartTime,
      List<String> chosenIrregularEndTime,

      ){
    if (eventType == DateTypeEnum.once){
      return checkOnceDayOnErrors(selectedDayInOnceType, onceDayStartTime, onceDayFinishTime);
    } else if (eventType == DateTypeEnum.long) {
      if (selectedStartDayInLongType == DateTime(2100) || selectedEndDayInLongType == DateTime(2100)){
        return 'Не выбрана дата!';
      } else if (longDayStartTime == longDayFinishTime) {
        return 'Время начала и время завершения не могут быть одинаковы';
      } else if (longDayStartTime == 'Не выбрано' || longDayFinishTime == 'Не выбрано'){
        return 'Не выбрано время!';
      } else {
        return 'success';
      }
    } else if (eventType == DateTypeEnum.regular) {

      bool emptyTimes = true;
      bool haveErrorInTime = false;

      for (int i = 0; i<regularStartTimes.length; i++){
        if (regularStartTimes[i] != regularFinishTimes[i]){
          emptyTimes = false;
          if (regularStartTimes[i] == 'Не выбрано' || regularFinishTimes[i] == 'Не выбрано'){
            haveErrorInTime = true;
          }
        }
      }

      if (emptyTimes) {
        return 'Не указано расписание ни для одного дня!';
      } else if (haveErrorInTime) {
        return 'Где-то не выбрано время начала или завершения';
      } else {
        return 'success';
      }


    } else if (eventType == DateTypeEnum.irregular) {
      bool notHaveErrors = true;
      String errorMessage = '';

      if (chosenIrregularDays.isEmpty || chosenIrregularEndTime.isEmpty || chosenIrregularStartTime.isEmpty){
        return 'Список нерегулярных дат пуст. Выберите хотя бы 1 дату';
      }

      for (int i = 0; i<chosenIrregularDays.length; i++){
        String tempMessage = checkOnceDayOnErrors(chosenIrregularDays[i], chosenIrregularStartTime[i], chosenIrregularEndTime[i]);
        if (tempMessage != 'success'){
          notHaveErrors = false;
          errorMessage = tempMessage;
        }
      }

      if (notHaveErrors) {
        return 'success';
      } else {
        return errorMessage;
      }

    } else {
      return 'Произошла ошибка с датой или временем. Проверь их';
    }
  }

  static String checkOnceDayOnErrors(
      DateTime selectedDayInOnceType,
      String onceDayStartTime,
      String onceDayFinishTime,
      ){

    if (selectedDayInOnceType == DateTime(2100)){
      return 'Не выбрана дата!';
    } else if (onceDayStartTime == onceDayFinishTime) {
      return 'Время начала и время завершения не могут быть одинаковы';
    } else if (onceDayStartTime == 'Не выбрано' || onceDayFinishTime == 'Не выбрано'){
      return 'Не выбрано время!';
    } else {
      return 'success';
    }

  }

}
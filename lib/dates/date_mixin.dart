import 'dart:convert';

import 'package:dvij_flutter/classes/date_type_enum.dart';

mixin DateMixin {

  static DateTime getDateFromString(String date){
    return DateTime.parse(date);
  }

  static String generateDateSting(DateTime date){
    return '${date.year}-${_getCorrectMonthOrDate(date.month)}-${_getCorrectMonthOrDate(date.day)}';
  }

  static String _getCorrectMonthOrDate(int number){
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

  static bool nowIsInPeriod (DateTime startDate, DateTime endDate){
    return nowIsAfterStart(startDate) && nowIsBeforeEnd(endDate);
  }

  static bool nowIsAfterStart (DateTime checkedDate){
    return DateTime.now().isAfter(checkedDate) || DateTime.now().isAtSameMomentAs(checkedDate);
  }

  static bool nowIsBeforeEnd (DateTime checkedDate){
    return DateTime.now().isBefore(checkedDate) || DateTime.now().isAtSameMomentAs(checkedDate);
  }

  /// Отдельная функция для получения списка дат для нерегулярных дат
  ///
  /// <br>
  ///
  /// В целом повторяет функцию обычного парсинга дат из json [getDateFromJson] c
  /// небольшими отличиями
  ///
  /// <br>
  ///
  /// Просто обновляет переданные списки датами
  static void getIrregularDateFromJson (
      String json,
      List<DateTime> irregularDaysStart,
      List<DateTime> irregularDaysEnd,
      List<DateTime> irregularDaysOnlyDate
      ){

    List<String> datesList = [];
    List<String> startTimeList = [];
    List<String> endTimeList = [];

    if (json != ''){
      parseJsonStringWithManyDates(json, datesList, startTimeList, endTimeList);

      for (int i = 0; i < datesList.length; i++){
        if (startTimeList[i] != 'Не выбрано' && endTimeList[i] != 'Не выбрано') {
          // Разделяем часы и минуты для парсинга
          List<String> startHourAndMinutes = startTimeList[i].split(':');
          List<String> endHourAndMinutes = endTimeList[i].split(':');

          DateTime startDate = DateTime.parse(
              '${datesList[i]} ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}');

          DateTime endDate = DateTime.parse(
              '${datesList[i]} ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}');

          if (endDate.isBefore(startDate)) endDate.add(const Duration(days: 1));

          irregularDaysStart.add(startDate);

          irregularDaysEnd.add(endDate);

          irregularDaysOnlyDate.add(DateTime.parse(datesList[i]));

        }
      }
    }
  }


  /// Функция парсинга дат и времени из Json-строки со множеством встроенных дат
  ///
  /// <br>
  ///
  /// ОБновляет переданные списки значениями из Json
  ///
  /// <br>
  ///
  /// Формат Json-строки
  ///
  /// <br>
  /// [
  ///
  /// {"date": "2024-01-30", "startTime": "04:00", "endTime": "02:00"},
  ///
  /// {"date": "2024-01-31", "startTime": "04:00", "endTime": "15:00"},
  ///
  /// {"date": "2024-02-02", "startTime": "04:00", "endTime": "13:30"},
  ///
  /// ]
  static void parseJsonStringWithManyDates(
      String inputString, List<String> datesList, List<String> startTimeList, List<String> endTimeList) {
    RegExp dateRegExp = RegExp(r'"date": "([^"]+)"');
    RegExp startTimeRegExp = RegExp(r'"startTime": "([^"]+)"');
    RegExp endTimeRegExp = RegExp(r'"endTime": "([^"]+)"');

    List<Match> matches = dateRegExp.allMatches(inputString).toList();
    for (Match match in matches) {
      datesList.add(match.group(1)!);
    }

    matches = startTimeRegExp.allMatches(inputString).toList();
    for (Match match in matches) {
      startTimeList.add(match.group(1)!);
    }

    matches = endTimeRegExp.allMatches(inputString).toList();
    for (Match match in matches) {
      endTimeList.add(match.group(1)!);
    }
  }

  /// Функция получения списка дат из json
  ///
  /// <br>
  ///
  /// Формат Json - {"date": "2024-01-30", "startTime": "05:30", "endTime": "17:00"}
  ///
  /// <br>
  ///
  /// В нее нужно передать:
  ///
  /// 1 - json-строку, полученную из firebase realtime database
  ///
  /// 2 - dateKey - ключ, по которому лежит дата
  ///
  /// 3 - startTimeKey и endTimeKey - ключи, по которым лежит время начало и конца
  ///
  /// <br>
  /// Функция вернет список дат в формате DateTime
  ///
  /// <br>
  /// Даты по индексу:
  ///
  /// <br>
  /// [0] - Дата начала с временем
  ///
  /// [1] - Дата завершения с временем
  ///
  /// [2] - Только дата на начало дня (время будет указано 00:00)
  static List<DateTime> getDateFromJson (String json, String dateKey, String startTimeKey, String endTimeKey){
    List<DateTime> daysList = [];

    String onceDay = extractDateOrTimeFromJson(json, dateKey);
    String startTime = extractDateOrTimeFromJson(json, startTimeKey);
    String endTime = extractDateOrTimeFromJson(json, endTimeKey);

    if (startTime != 'Не выбрано' && endTime != 'Не выбрано') {
      // Разделяем часы и минуты для парсинга
      List<String> startHourAndMinutes = startTime.split(':');
      List<String> endHourAndMinutes = endTime.split(':');

      DateTime startDate = DateTime.parse(
          '$onceDay ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}');

      DateTime endDate = DateTime.parse(
          '$onceDay ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}');

      if (endDate.isBefore(startDate)) endDate.add(const Duration(days: 1));

      daysList.add(startDate);

      daysList.add(endDate);

      daysList.add(DateTime.parse(onceDay));

    }
    return daysList;

  }


  /// Функция получения списка периода дат из json
  ///
  /// <br>
  ///
  /// Формат Json-строки: {"startDate": "2100-01-01", "endDate": "2100-01-01", "startTime": "Не выбрано", "endTime": "Не выбрано"}
  ///
  /// <br>
  /// В нее нужно передать:
  ///
  /// 1 - json-строку, полученную из firebase realtime database
  ///
  /// 2 - startDateKey и endDateKey - ключи, по которым лежат даты начала и конца
  ///
  /// 3 - startTimeKey и endTimeKey - ключи, по которым лежит время начало и конца
  ///
  /// <br>
  /// Функция вернет список дат в формате DateTime
  ///
  /// <br>
  /// Даты по индексу:
  ///
  /// <br>
  /// [0],[3] - Даты начала с временем
  ///
  /// [1],[4] - Даты завершения с временем
  ///
  /// [2],[5] - Только даты на начало дня (время будет указано 00:00)

  static List<DateTime> getPeriodDatesFromJson (String json, String startDateKey, String endDateKey,  String startTimeKey, String endTimeKey){
    List<DateTime> startDates = getDateFromJson(json, startDateKey, startTimeKey, endTimeKey);
    List<DateTime> endDates = getDateFromJson(json, endDateKey, startTimeKey, endTimeKey);

    return [...startDates, ...endDates];
  }


  /// Функция получения даты или времени из Json-строки из Firebase RealTimeDatabase
  ///
  /// <br>
  /// [String] jsonString - это сама строка, которую нужно декодировать
  ///
  /// <br>
  /// [String] fieldId - это ключевое плово, по которому парсится значение
  static String extractDateOrTimeFromJson(String jsonString, String fieldId) {

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
      List<DateTime> onceDay,
      List<DateTime> longDay,
      List<String> regularDaysStart,
      List<String> regularDaysEnd,
      List<DateTime> irregularDaysStart,
      List<DateTime> irregularDaysEnd,
      List<DateTime> irregularDaysOnlyDate
      ){

    switch (dateType) {
      case DateTypeEnum.once : {
        return nowIsInPeriod(onceDay[2], onceDay[1]);
      }

      case DateTypeEnum.long : {
        bool today = false;
        // Проверяем - сегодня вообще находится в периоде проведения или нет
        bool inPeriod = nowIsInPeriod(longDay[2], longDay[4]);
        // Если сегодня в периоде, проверим на сегодня - не завершилось ли уже мероприятие или акция
        if (inPeriod) {
          DateTime todayDay = DateTime.now();
          DateTime tempStartDay = DateTime(todayDay.year, todayDay.month, todayDay.day);
          DateTime tempEndDay = DateTime(todayDay.year, todayDay.month, todayDay.day, longDay[4].hour, longDay[4].minute);

          // Если дата завершения не равна дате начала, значит заканчивается после полуночи
          // и нужно добавить к временной переменной день

          if (longDay[4].day != longDay[0].day) tempEndDay.add(const Duration(days: 1));

          today = nowIsInPeriod(tempStartDay, tempEndDay);

        }
        return today;
      }

      case DateTypeEnum.regular : {
        DateTime currentDayDate = DateTime.now();
        int currentDay = currentDayDate.weekday;

        String startTimeToday = regularDaysStart[currentDay-1];
        String endTimeToday = regularDaysEnd[currentDay-1];

        if (startTimeToday != 'Не выбрано' && endTimeToday != 'Не выбрано'){
          // Разделяем часы и минуты для парсинга
          List<String> startHourAndMinutes = startTimeToday.split(':');
          List<String> endHourAndMinutes = endTimeToday.split(':');

          // Парсим начальную дату до минут для сравнения
          DateTime parsedStartTimeToMinutes = DateTime.parse('${currentDayDate.year}-${_getCorrectMonthOrDate(currentDayDate.month)}-${_getCorrectMonthOrDate(currentDayDate.day)} ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}');

          // Парсим начальную дату уже без точности до минут
          DateTime parsedStartTime = DateTime.parse('${currentDayDate.year}-${_getCorrectMonthOrDate(currentDayDate.month)}-${_getCorrectMonthOrDate(currentDayDate.day)}');
          // Парсим конечную дату с точностью до минуты
          DateTime parsedEndTime = DateTime.parse('${currentDayDate.year}-${_getCorrectMonthOrDate(currentDayDate.month)}-${_getCorrectMonthOrDate(currentDayDate.day)} ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}');

          // Проверка - если время завершения раньше чем время начала
          // Именно для этого нужна переменная начального времени с точностью до минуты
          // Если как бы завершение будет проходить в следущий день, то добавляем к финишной дате 1 день
          if (parsedStartTimeToMinutes.isAfter(parsedEndTime)){
            parsedEndTime = parsedEndTime.add(const Duration(days: 1));
          }

          return nowIsInPeriod(parsedStartTime, parsedEndTime);

      } else {
        return false;
        }
      }

      case DateTypeEnum.irregular : {
        for (int i = 0; i<irregularDaysStart.length; i++){
          bool result = nowIsInPeriod(irregularDaysOnlyDate[i], irregularDaysEnd[i]);

          // Первый попавшийся элемент в списке вернет тру, значит сегодня
          if (result) return true;
        }
        return false;
      }

    }
  }

  /// Функция генерации Json строки для типа дат Once
  ///
  /// Принимает список дат и возвращает нужную строку для записи в БД
  ///
  /// Получаемый формат строки Json - {"date": "2024-01-30", "startTime": "05:30", "endTime": "17:00"}
  static String generateOnceTypeDate(List<DateTime> dates){
    DateTime startDateAndTime = dates[0];
    DateTime endDateAndTime = dates[1];

    return '{'
        '"date": "${startDateAndTime.year}-${_getCorrectMonthOrDate(startDateAndTime.month)}-${_getCorrectMonthOrDate(startDateAndTime.day)}", '
        '"startTime": "${_getCorrectMonthOrDate(startDateAndTime.hour)}:${_getCorrectMonthOrDate(startDateAndTime.minute)}", '
        '"endTime": "${_getCorrectMonthOrDate(endDateAndTime.hour)}:${_getCorrectMonthOrDate(endDateAndTime.minute)}"'
        '}';
  }

  static String generateLongTypeDate(List<DateTime> dates){
    // [0],[3] - Даты начала с временем
    // [1],[4] - Даты завершения с временем

    DateTime startDateAndTime = dates[0];
    DateTime endDateAndTime = dates[4];

    return '{'
        '"startDate": "${startDateAndTime.year}-${_getCorrectMonthOrDate(startDateAndTime.month)}-${_getCorrectMonthOrDate(startDateAndTime.day)}", '
        '"endDate": "${endDateAndTime.year}-${_getCorrectMonthOrDate(endDateAndTime.month)}-${_getCorrectMonthOrDate(endDateAndTime.month)}", '
        '"startTime": "${_getCorrectMonthOrDate(startDateAndTime.hour)}:${_getCorrectMonthOrDate(startDateAndTime.minute)}", '
        '"endTime": "${_getCorrectMonthOrDate(endDateAndTime.hour)}:${_getCorrectMonthOrDate(endDateAndTime.minute)}"'
        '}';
  }

  static String generateRegularTypeDate(
      List<String> startTimes,
      List<String> endTimes
      ){
    String result = '';

    if (startTimes.isNotEmpty){

      result = '{';

      for (int i = 0; i<startTimes.length; i++){

        if (i != startTimes.length-1){
          result = '$result"startTime${i+1}": "${startTimes[i]}", "endTime${i+1}": "${endTimes[i]}", ';
        } else {

          result = '$result"startTime${i+1}": "${startTimes[i]}", "endTime${i+1}": "${endTimes[i]}"';

        }
      }

      result = '$result}';
    }

    return result;
  }

}
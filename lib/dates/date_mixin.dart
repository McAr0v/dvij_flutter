import 'dart:convert';

import 'package:dvij_flutter/classes/date_type_enum.dart';
import 'package:dvij_flutter/methods/date_functions.dart';

mixin DateMixin {

  static DateTime getDateFromString(String date){
    return DateTime.parse(date);
  }

  static String generateDateString(DateTime date){
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
      return '${_getCorrectMonthOrDate(date.day)} $month ${date.year}';
    } else {
      return '${_getCorrectMonthOrDate(date.day)} $month';
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
  /// Разделяет большой Json на список регулярных дат и с помощью функции [getDateFromJson]
  /// формирует список дат
  ///
  /// <br>
  ///
  /// По сути, возвращает список OnceDay, только их несколько
  static List<Map<String, DateTime>> getIrregularDatesFromJson (String json){

    List<Map<String, DateTime>> list = [];

    if (json != ''){
      List<String> datesList = splitJsonWithManyDates(json);

      for (int i = 0; i < datesList.length; i++){
        list.add(getDateFromJson(datesList[i], 'date', 'startTime', 'endTime'));
      }
    }
    return list;
  }

  /// Функция разделения одной большой Json строки со списком дат
  /// на список отдельных дат в формате OnceDay
  ///
  /// <br>
  /// Вернет список с таким содержимым
  ///
  /// Формат Json - {"date": "2024-01-30", "startTime": "05:30", "endTime": "17:00"}

  static List<String> splitJsonWithManyDates(String json){
    // Удаляем квадратные скобки в начале и в конце строки
    String trimmedJsonString = json.substring(1, json.length - 1);

    // Разделяем элементы списка по символу нижнего подчеркивания '_'

    return trimmedJsonString.split('_');

  }

  static String generateIrregularString(List<Map<String, DateTime>> dateTimeList) {

    String result = '';

    if (dateTimeList.isNotEmpty){
      if (dateTimeList.length >= 2){
        // Сортируем список словарей с датами по DateTime
        dateTimeList.sort((a, b) => a['date-startDate']!.compareTo(b['date-startDate']!));
      }

      result = '[';

      for (int i = 0; i<dateTimeList.length; i++){

        Map<String, DateTime> tempTime = dateTimeList[i];

        result = '$result{'
            '"date": '
            '"${tempTime['date-startDate']!.year}-'
            '${correctMonthOrDate(tempTime['date-startDate']!.month)}-'
            '${correctMonthOrDate(tempTime['date-startDate']!.day)}", '
            '"startTime": '
            '"${correctMonthOrDate(tempTime['date-startDate']!.hour)}:${correctMonthOrDate(tempTime['date-startDate']!.minute)}", '
            '"endTime": '
            '"${correctMonthOrDate(tempTime['date-endDate']!.hour)}:${correctMonthOrDate(tempTime['date-endDate']!.minute)}"'
            '}_';
      }

      result = '$result]';

    }

    return result;

  }

  /*/// Функция парсинга дат и времени из Json-строки со множеством встроенных дат
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
  }*/

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
  /// Функция вернет список дат в формате словаря
  ///
  /// <br>
  /// Ключи к датам:
  ///
  /// <br>
  /// $dateKey-startDate - Дата начала с временем
  ///
  /// $dateKey-endDate - Дата завершения с временем
  ///
  /// $dateKey-startOnlyDate - Только дата на начало дня (время будет указано 00:00)
  static Map<String, DateTime> getDateFromJson (String json, String dateKey, String startTimeKey, String endTimeKey){
    Map<String, DateTime> daysList = {};

    String onceDay = extractDateOrTimeFromJson(json, dateKey);
    String startTime = extractDateOrTimeFromJson(json, startTimeKey);
    String endTime = extractDateOrTimeFromJson(json, endTimeKey);

    if (startTime != 'Не выбрано' && endTime != 'Не выбрано') {
      // Разделяем часы и минуты для парсинга
      /*List<String> startHourAndMinutes = startTime.split(':');
      List<String> endHourAndMinutes = endTime.split(':');

      DateTime startDate = DateTime.parse(
          '$onceDay ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}');

      DateTime endDate = DateTime.parse(
          '$onceDay ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}');*/

      // TODO Если не будет парсится дата, значит нужно вернуть закоментированный кусок
      DateTime startDate = DateTime.parse(
          '$onceDay $startTime');

      DateTime endDate = DateTime.parse(
          '$onceDay $endTime');

      if (endDate.isBefore(startDate)) endDate.add(const Duration(days: 1));

      daysList.putIfAbsent('$dateKey-startDate', () => startDate);
      daysList.putIfAbsent('$dateKey-endDate', () => endDate);
      daysList.putIfAbsent('$dateKey-startOnlyDate', () => DateTime.parse(onceDay));

    }
    return daysList;

  }

  /// Функция генерации Json строки для типа дат Once
  ///
  /// Принимает список дат и возвращает нужную строку для записи в БД
  ///
  /// Получаемый формат строки Json - {"date": "2024-01-30", "startTime": "05:30", "endTime": "17:00"}
  static String generateOnceTypeDate(Map<String, DateTime> dates){
    if (dates.isNotEmpty){
      DateTime startDateAndTime = dates['date-startDate']!;
      DateTime endDateAndTime = dates['date-endDate']!;

      return '{'
          '"date": "${startDateAndTime.year}-${_getCorrectMonthOrDate(startDateAndTime.month)}-${_getCorrectMonthOrDate(startDateAndTime.day)}", '
          '"startTime": "${_getCorrectMonthOrDate(startDateAndTime.hour)}:${_getCorrectMonthOrDate(startDateAndTime.minute)}", '
          '"endTime": "${_getCorrectMonthOrDate(endDateAndTime.hour)}:${_getCorrectMonthOrDate(endDateAndTime.minute)}"'
          '}';
    } else {
      return '';
    }

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
  /// Функция вернет список дат в формате словаря
  ///
  /// <br>
  /// Даты по ключам:
  ///
  /// <br>
  /// $startDateKey-startDate - Первая дата - начало с временем
  ///
  /// $startDateKey-endDate - Первая дата - конец с временем
  ///
  /// $startDateKey-startOnlyDate - Первая дата - Только дата на начало дня (время будет указано 00:00)
  ///
  /// $endDateKey-startDate - Вторая дата - начало с временем
  ///
  /// $endDateKey-endDate - Вторая дата - конец с временем
  ///
  /// $endDateKey-startOnlyDate - Вторая дата - Только дата на начало дня (время будет указано 00:00)

  static Map<String, DateTime> getPeriodDatesFromJson (String json, String startDateKey, String endDateKey,  String startTimeKey, String endTimeKey){
    Map<String, DateTime> startDates = getDateFromJson(json, startDateKey, startTimeKey, endTimeKey);
    Map<String, DateTime> endDates = getDateFromJson(json, endDateKey, startTimeKey, endTimeKey);

    return {...startDates, ...endDates};
  }

  static String generateLongTypeDate(Map<String, DateTime> dates){

    DateTime startDateAndTime = dates['startDate-startDate']!;
    DateTime endOnlyDate = dates['endDate-startDate']!;
    DateTime endDateAndTime = dates['endDate-endDate']!;

    return '{'
        '"startDate": "${startDateAndTime.year}-${_getCorrectMonthOrDate(startDateAndTime.month)}-${_getCorrectMonthOrDate(startDateAndTime.day)}", '
        '"endDate": "${endOnlyDate.year}-${_getCorrectMonthOrDate(endOnlyDate.month)}-${_getCorrectMonthOrDate(endOnlyDate.day)}", '
        '"startTime": "${_getCorrectMonthOrDate(startDateAndTime.hour)}:${_getCorrectMonthOrDate(startDateAndTime.minute)}", '
        '"endTime": "${_getCorrectMonthOrDate(endDateAndTime.hour)}:${_getCorrectMonthOrDate(endDateAndTime.minute)}"'
        '}';
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
          Map<String, DateTime> onceDay,
          Map<String, DateTime> longDays,
          Map<String, String> regularDays,
          List<Map<String, DateTime>> irregularDays,
      ){

    switch (dateType) {
      case DateTypeEnum.once : {
        return nowIsInPeriod(onceDay['date-startOnlyDate']!, onceDay['date-endDay']!);
      }

      case DateTypeEnum.long : {
        bool today = false;
        // Проверяем - сегодня вообще находится в периоде проведения или нет
        bool inPeriod = nowIsInPeriod(longDays['startDate-startOnlyDate']!, longDays['endDate-endDate']!);
        // Если сегодня в периоде, проверим на сегодня - не завершилось ли уже мероприятие или акция
        if (inPeriod) {
          DateTime todayDay = DateTime.now();
          DateTime tempStartDay = DateTime(todayDay.year, todayDay.month, todayDay.day);
          DateTime tempEndDay = DateTime(todayDay.year, todayDay.month, todayDay.day, longDays['endDate-endDate']!.hour, longDays['endDate-endDate']!.minute);

          // Если дата завершения не равна дате начала, значит заканчивается после полуночи
          // и нужно добавить к временной переменной день

          if (longDays['endDate-endDate']!.day != longDays['endDate-startDate']!.day) tempEndDay.add(const Duration(days: 1));

          today = nowIsInPeriod(tempStartDay, tempEndDay);

        }
        return today;
      }

      case DateTypeEnum.regular : {
        DateTime currentDayDate = DateTime.now();
        int currentDay = currentDayDate.weekday;

        String startTimeToday = regularDays['startTime$currentDay']!;
        String endTimeToday = regularDays['endTime$currentDay']!;

        if (startTimeToday != 'Не выбрано' && endTimeToday != 'Не выбрано'){
          // Разделяем часы и минуты для парсинга
          //List<String> startHourAndMinutes = startTimeToday.split(':');
          //List<String> endHourAndMinutes = endTimeToday.split(':');

          // Парсим начальную дату до минут для сравнения
          DateTime parsedStartTimeToMinutes = DateTime.parse('${currentDayDate.year}-${_getCorrectMonthOrDate(currentDayDate.month)}-${_getCorrectMonthOrDate(currentDayDate.day)} $startTimeToday');

          // Парсим начальную дату уже без точности до минут
          DateTime parsedStartTime = DateTime.parse('${currentDayDate.year}-${_getCorrectMonthOrDate(currentDayDate.month)}-${_getCorrectMonthOrDate(currentDayDate.day)}');
          // Парсим конечную дату с точностью до минуты
          DateTime parsedEndTime = DateTime.parse('${currentDayDate.year}-${_getCorrectMonthOrDate(currentDayDate.month)}-${_getCorrectMonthOrDate(currentDayDate.day)} $endTimeToday');

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
        for (int i = 0; i<irregularDays.length; i++){
          Map<String, DateTime> tempDict = irregularDays[i];
          bool result = nowIsInPeriod(tempDict['date-startOnlyDate']!, tempDict['date-endDay']!);

          // Первый попавшийся элемент в списке вернет тру, значит сегодня
          if (result) return true;
        }
        return false;
      }

    }
  }

  static List<int> getIrregularTodayIndexes(List<Map<String, DateTime>> irregularDays){
    DateTime timeNow = DateTime.now();
    List<int> tempList = [];

    if (irregularDays.isNotEmpty){

      for (int i = 0; i<irregularDays.length; i++){

        Map <String, DateTime> tempDay = irregularDays[i];

        if (tempDay['date-startDate']!.day == timeNow.day && tempDay['date-startDate']!.month == timeNow.month){
          tempList.add(i);
        }
      }
    }
    return tempList;
  }



  static Map<String, DateTime> generateOnceDayDateForEvent(DateTime onceDay, String startTime, String endTime){
    Map<String, DateTime> tempMap = {};

    DateTime startDate = DateTime.parse(
        '${onceDay.year}-${_getCorrectMonthOrDate(onceDay.month)}-${_getCorrectMonthOrDate(onceDay.day)} $startTime');

    DateTime endDate = DateTime.parse(
        '${onceDay.year}-${_getCorrectMonthOrDate(onceDay.month)}-${_getCorrectMonthOrDate(onceDay.day)} $endTime');

    if (endDate.isBefore(startDate)) endDate.add(const Duration(days: 1));

    tempMap.putIfAbsent('date-startDate', () => startDate);
    tempMap.putIfAbsent('date-endDate', () => endDate);
    tempMap.putIfAbsent('date-startOnlyDate', () => onceDay);

    return tempMap;
  }

  static Map<String, DateTime> generateLongDayDatesForEvent(DateTime startDay, DateTime endDay, String startTime, String endTime){
    Map<String, DateTime> tempMap = {};

    DateTime startDateStartDate = DateTime.parse(
        '${startDay.year}-${_getCorrectMonthOrDate(startDay.month)}-${_getCorrectMonthOrDate(startDay.day)} $startTime');
    DateTime startDateEndDate = DateTime.parse(
        '${startDay.year}-${_getCorrectMonthOrDate(startDay.month)}-${_getCorrectMonthOrDate(startDay.day)} $endTime');
    DateTime endDateStartDate = DateTime.parse(
        '${endDay.year}-${_getCorrectMonthOrDate(endDay.month)}-${_getCorrectMonthOrDate(endDay.day)} $startTime');
    DateTime endDateEndDate = DateTime.parse(
        '${endDay.year}-${_getCorrectMonthOrDate(endDay.month)}-${_getCorrectMonthOrDate(endDay.day)} $endTime');

    if (startDateStartDate.isAfter(startDateEndDate)){
      startDateEndDate.add(const Duration(days: 1));
      endDateEndDate.add(const Duration(days: 1));
    }

    tempMap.putIfAbsent('startDate-startDate', () => startDateStartDate);
    tempMap.putIfAbsent('startDate-endDate', () => startDateEndDate);
    tempMap.putIfAbsent('endDate-startDate', () => endDateStartDate);
    tempMap.putIfAbsent('endDate-endDate', () => endDateEndDate);
    tempMap.putIfAbsent('startDate-startOnlyDate', () => startDay);
    tempMap.putIfAbsent('endDate-startOnlyDate', () => endDay);

    return tempMap;

  }

  static List<Map<String, DateTime>> generateIrregularDatesForEvent(List<DateTime> days, List<String> startTimes, List<String> endTimes){

    List<Map<String, DateTime>> tempList = [];

    for (int i = 0; i<days.length; i++){
      tempList.add(generateOnceDayDateForEvent(days[i], startTimes[i], endTimes[i]));
    }

    return tempList;

  }

}
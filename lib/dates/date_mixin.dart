import 'dart:convert';

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
    return DateTime.now().isAfter(checkedDate);
  }

  static bool nowIsBeforeEnd (DateTime checkedDate){
    return DateTime.now().isBefore(checkedDate);
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

          irregularDaysStart.add(DateTime.parse(
              '${datesList[i]} ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}'));

          irregularDaysEnd.add(DateTime.parse(
              '${datesList[i]} ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}'));

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

      daysList.add(DateTime.parse(
          '$onceDay ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}'));

      daysList.add(DateTime.parse(
          '$onceDay ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}'));

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

}
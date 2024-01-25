
import 'dart:convert';

import '../classes/event_class.dart';
import '../classes/event_type_enum.dart';
import '../classes/pair.dart';

List<int> splitDate(String date, String symbol)
{

  List<String> stringElements = date.split(symbol);
  List<int> intElements = stringElements.map((String element) {
    return int.tryParse(element) ?? 0; // Если не удается преобразовать в int, используйте 0 или другое значение по умолчанию
  }).toList();

  return intElements;
}

String switchMonth (String month)
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

String getHumanWeekday (int weekdayIndex, bool cut)
{
  switch (weekdayIndex)
  {
    case 0: return !cut ? 'Понедельник' : 'Пн';
    case 1: return !cut ? 'Вторник' : 'Вт';
    case 2: return !cut ? 'Среда' : 'Ср';
    case 3: return !cut ? 'Четверг' : 'Чт';
    case 4: return !cut ? 'Пятница' : 'Пт';
    case 5: return !cut ? 'Суббота' : 'Сб';
    case 6: return !cut ? 'Воскресенье' : 'Вс';

    default: return !cut ? 'Неизвестный индекс дня недели' : 'Err';
  }
}

String getHumanDate (String date, String symbol)
{
  List<String> stringElements = date.split(symbol);
  String month = switchMonth(stringElements[1]);
  return '${stringElements[2]} $month ${stringElements[0]}';
}

DateTime getDateFromString (String date)
{
  List<int> temp = splitDate(date, '-');
  return DateTime(temp[0], temp[1], temp[2]);
}

String extractDateOrTimeFromJson(String jsonString, String fieldId) {
  // Декодируем JSON строку
  Map<String, dynamic> json = jsonDecode(jsonString);

  // Извлекаем значение "date"
  String dateStr = json[fieldId];

  return dateStr;
}

String correctMonthOrDate (int month) {
  if (month < 10) {
    return '0$month';
  } else {
    return '$month';
  }
}

String generateOnceTypeDate(DateTime date, String startTime, String endTime){
  return '{"date": "${date.year}-${correctMonthOrDate(date.month)}-${correctMonthOrDate(date.day)}", "startTime": "$startTime", "endTime": "$endTime"}';
}

String generateLongTypeDate(DateTime startDate, DateTime endDate, String startTime, String endTime){
  return '{"startDate": "${startDate.year}-${correctMonthOrDate(startDate.month)}-${correctMonthOrDate(startDate.day)}", "endDate": "${endDate.year}-${correctMonthOrDate(endDate.month)}-${correctMonthOrDate(endDate.day)}", "startTime": "$startTime", "endTime": "$endTime"}';
}

String generateRegularTypeDateTwo(
    List<String> startTimes,
    List<String> endTimes
    ){
  String result = '';

  String temp = '{'
      '"startTime1": "01:00", "endTime1": "01:30", '
      '"startTime2": "02:00", "endTime2": "02:30", '
      '"startTime3": "03:00", "endTime3": "03:30", '
      '"startTime4": "04:00", "endTime4": "04:30", '
      '"startTime5": "05:00", "endTime5": "05:30", '
      '"startTime6": "06:00", "endTime6": "06:30", '
      '"startTime7": "07:00", "endTime7": "07:30"'
      '}';

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

String generateRegularTypeDate(
    String mondayStartTime,
    String mondayFinishTime,
    String tuesdayStartTime,
    String tuesdayFinishTime,
    String wednesdayStartTime,
    String wednesdayFinishTime,
    String thursdayStartTime,
    String thursdayFinishTime,
    String fridayStartTime,
    String fridayFinishTime,
    String saturdayStartTime,
    String saturdayFinishTime,
    String sundayStartTime,
    String sundayFinishTime,
    ){
  return '{'
      '"startTime1": "$mondayStartTime", "endTime1": "$mondayFinishTime", '
      '"startTime2": "$tuesdayStartTime", "endTime2": "$tuesdayFinishTime", '
      '"startTime3": "$wednesdayStartTime", "endTime3": "$wednesdayFinishTime", '
      '"startTime4": "$thursdayStartTime", "endTime4": "$thursdayFinishTime", '
      '"startTime5": "$fridayStartTime", "endTime5": "$fridayFinishTime", '
      '"startTime6": "$saturdayStartTime", "endTime6": "$saturdayFinishTime", '
      '"startTime7": "$sundayStartTime", "endTime7": "$sundayFinishTime"'
      '}';
}

String generateIrregularTypeDate(
    List<DateTime> dates,
    List<String> startTimes,
    List<String> endTimes,
    ){

  String result = '';

  if (dates.isNotEmpty){

    result = '[';

    for (int i = 0; i<dates.length; i++){

      result = '$result{"date": "${dates[i].year}-${correctMonthOrDate(dates[i].month)}-${correctMonthOrDate(dates[i].day)}", "startTime": "${startTimes[i]}", "endTime": "${endTimes[i]}"}, ';

    }

    result = '$result]';
  }

  return result;
}

String sortDateTimeListAndRelatedData(List<DateTime> dateTimeList, List<String> startTime, List<String> endTime) {
  // Создаем список пар, содержащих DateTime и связанные данные
  List<Pair<DateTime, Pair<String, String>>> combinedList = [];

  for (int i = 0; i < dateTimeList.length; i++) {
    combinedList.add(Pair(dateTimeList[i], Pair(startTime[i], endTime[i])));
  }

  // Сортируем список пар по DateTime
  combinedList.sort((a, b) => a.first.compareTo(b.first));

  // Обновляем исходные списки после сортировки
  for (int i = 0; i < dateTimeList.length; i++) {
    dateTimeList[i] = combinedList[i].first;
    startTime[i] = combinedList[i].second.first;
    endTime[i] = combinedList[i].second.second;
  }

  return generateIrregularTypeDate(dateTimeList, startTime, endTime);

}

bool todayEventOrNot(EventCustom event) {

  if (event.eventType == EventCustom.getNameEventTypeEnum(EventTypeEnum.once)){

    String onceDay = extractDateOrTimeFromJson(event.onceDay, 'date');
    DateTime dayInOnceType = DateTime.parse(onceDay);

    return checkDateOnToday(dayInOnceType);

  } else if (event.eventType == EventCustom.getNameEventTypeEnum(EventTypeEnum.long)){

    String longStartDay = extractDateOrTimeFromJson(event.longDays, 'startDate');
    String longEndDay = extractDateOrTimeFromJson(event.longDays, 'endDate');
    DateTime startDayInLongType = DateTime.parse(longStartDay);
    DateTime endDayInLongType = DateTime.parse(longEndDay);

    return checkLongDatesOnToday(startDayInLongType, endDayInLongType);

  } else if (event.eventType == EventCustom.getNameEventTypeEnum(EventTypeEnum.regular)){

    return checkRegularDatesOnToday(event.regularDays);

  } else if (event.eventType == EventCustom.getNameEventTypeEnum(EventTypeEnum.irregular)){

// Это список для временного хранения дат в стринге из БД при парсинге
    List<String> tempIrregularDaysString = [];

// Парсим даты
    parseIrregularDatesString(event.irregularDays, tempIrregularDaysString);

    for (String date in tempIrregularDaysString){
// Преобразуем дату из String в DateTime
      DateTime tempDate = getDateFromString(date);
// Проверяем - дату - сегодня или нет
      bool result = checkDateOnToday(tempDate);
      if (result) return true;
    }
    return false;
  }
  return false;
}

void parseIrregularDatesString(
    String inputString, List<String> datesList) {
  RegExp dateRegExp = RegExp(r'"date": "([^"]+)"');

  List<Match> matches = dateRegExp.allMatches(inputString).toList();
  for (Match match in matches) {
    datesList.add(match.group(1)!);
  }
}


bool checkRegularDatesOnToday (String regularTimes) {

  int currentDay = DateTime.now().add(const Duration(hours: 6)).weekday;

  String startTimeToday = extractDateOrTimeFromJson(regularTimes, 'startTime$currentDay');
  String endTimeToday = extractDateOrTimeFromJson(regularTimes, 'endTime$currentDay');

  if (startTimeToday == '00:00' && endTimeToday == '00:00') {
    return false;
  } else {
    return true;
  }
}

bool checkLongDatesOnToday(DateTime startDate, DateTime endDate){
  DateTime today = DateTime.now().add(const Duration(hours: 6));
  return today.isAfter(startDate.subtract(Duration(days: 1))) && today.isBefore(endDate.add(Duration(days: 1)));
}

bool checkDateOnToday(DateTime eventDate) {
  DateTime today = DateTime.now().add(const Duration(hours: 6));
  return eventDate.year == today.year && eventDate.month == today.month && eventDate.day == today.day;
}
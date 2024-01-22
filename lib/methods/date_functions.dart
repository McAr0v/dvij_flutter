
import 'dart:convert';

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
    case '2': return 'февраля';
    case '3': return 'марта';
    case '4': return 'апреля';
    case '5': return 'мая';
    case '6': return 'июня';
    case '7': return 'июля';
    case '8': return 'августа';
    case '9': return 'сентября';
    case '10': return 'октября';
    case '11': return 'ноября';
    default: return 'декабря';
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

String generateOnceTypeDate(DateTime date, String startTime, String endTime){
  return '{"date": "${date.year}-${date.month}-${date.day}", "startTime": "$startTime", "endTime": "$endTime"}';
}

String generateLongTypeDate(DateTime startDate, DateTime endDate, String startTime, String endTime){
  return '{"startDate": "${startDate.year}-${startDate.month}-${startDate.day}", "endDate": "${endDate.year}-${endDate.month}-${endDate.day}", "startTime": "$startTime", "endTime": "$endTime"}';
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

      if (i != 6){
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

      result = '$result{"date": "${dates[i].year}-${dates[i].month}-${dates[i].day}", "startTime": "${startTimes[i]}", "endTime": "${endTimes[i]}"}, ';

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
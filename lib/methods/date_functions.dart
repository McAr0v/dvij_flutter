
import 'dart:convert';

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
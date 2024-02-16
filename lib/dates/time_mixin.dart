import 'dart:convert';

mixin TimeMixin {

  static String extractTimeFromJson(String jsonString, String fieldId) {

    // Декодируем JSON строку
    Map<String, dynamic> json = jsonDecode(jsonString);

    // Извлекаем значение "date"
    String dateStr = json[fieldId];

    return dateStr;
  }

  static String _getCorrectTime(int number){
    if (number < 10) {
      return '0$number';
    } else {
      return '$number';
    }
  }

  static String getTimeRange(DateTime startDate, DateTime endDate){

    return 'c ${_getCorrectTime(startDate.hour)}:${_getCorrectTime(startDate.minute)} '
        'до ${_getCorrectTime(endDate.hour)}:${_getCorrectTime(endDate.minute)}';

  }

  static String getTimeFromDateTime(DateTime date){
    return '${_getCorrectTime(date.hour)}:${_getCorrectTime(date.minute)}';
  }

}
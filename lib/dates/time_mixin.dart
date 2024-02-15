import 'dart:convert';

mixin TimeMixin {

  static String extractTimeFromJson(String jsonString, String fieldId) {

    // Декодируем JSON строку
    Map<String, dynamic> json = jsonDecode(jsonString);

    // Извлекаем значение "date"
    String dateStr = json[fieldId];

    return dateStr;
  }

  /*/// Функция получения словаря времени из Json-строки из FireBaseRealtimeDatabase
  ///
  /// <br>
  ///
  /// Функция вернет словарь значений по ключу.
  ///
  /// <br>
  ///
  /// Нужно передать:
  ///
  /// <br>
  ///
  /// [String] json - сама строка из БД
  ///
  /// [String] defaultValue - значение по умолчанию, которым заполнятся списки
  ///
  /// <br>
  ///
  /// Формат строки Json - {"startTime1": "Не выбрано", "endTime1": "Не выбрано", "startTime2": "Не выбрано", "endTime2": "Не выбрано", "startTime3": "Не выбрано", "endTime3": "Не выбрано", "startTime4": "Не выбрано", "endTime4": "Не выбрано", "startTime5": "Не выбрано", "endTime5": "Не выбрано", "startTime6": "Не выбрано", "endTime6": "Не выбрано", "startTime7": "Не выбрано", "endTime7": "Не выбрано"}
  ///
  ///
  static Map<String, String> getTimeDictionaryFromJson (String json, String defaultValue) {

    Map<String, String> dictionary = _fillTimeMapWithDefaultValues(defaultValue, 7);

    for (int i = 1; i<8; i++){
      dictionary['startTime$i'] = extractTimeFromJson(json, 'startTime$i');
      dictionary['endTime$i'] = extractTimeFromJson(json, 'endTime$i');
    }

    return dictionary;

  }*/

  /// Функция заполнения словаря времени значениями по умолчанию
  ///
  /// <br>
  ///
  /// Вернет словарь, заполненный значениями.
  ///
  /// <br>
  ///
  /// Нужно передать в функцию:
  ///
  /// [String] value - значение, которым будет заполняться список
  ///
  /// [int] count - количество этих элементов в списке
  static Map<String, String> _fillTimeMapWithDefaultValues(String value, int count){

    Map<String, String> dictionary = {};

    for (int i = 0; i < count; i++){

      dictionary.putIfAbsent('startTime${i+1}', () => value);
      dictionary.putIfAbsent('endTime${i+1}', () => value);

    }

    return dictionary;

  }

  /*static String generateRegularTypeTimes(
      Map<String, String> timesMap
      ){
    String result = '';

    if (timesMap.isNotEmpty){

      result = '{';

      for (int i = 1; i<8; i++){

        if (i != 7){
          result = '$result"startTime$i": "${timesMap["startTime$i"]}", "endTime$i": "${timesMap["endTime$i"]}", ';
        } else {

          result = '$result"startTime$i": "${timesMap["startTime$i"]}", "endTime$i": "${timesMap["endTime$i"]}"';

        }
      }

      result = '$result}';
    }

    return result;
  }*/

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

//Map<String, String> regularDays;

  /*static Map<String, String> generateRegularTimesForEvent(List<String> startTimes, List<String> endTimes){

    Map<String, String> tempMap = {};
    for (int i = 0; i<startTimes.length; i++){
      tempMap.putIfAbsent('startTime${i+1}', () => startTimes[i]);
      tempMap.putIfAbsent('endTime${i+1}', () => endTimes[i]);
    }

    return tempMap;

  }*/

}
import 'package:dvij_flutter/dates/date_mixin.dart';

mixin TimeMixin {

  /// Функция получения списка времени из Json-строки из FireBaseRealtimeDatabase
  ///
  /// <br>
  ///
  /// Функция вернет список значений по ключу.
  ///
  /// <br>
  ///
  /// Нужно передать:
  ///
  /// <br>
  ///
  /// [String] json - сама строка из БД
  ///
  /// [String] timeKey - ключ, по которому будем искать значение (startTime например)
  ///
  /// [String] defaultValue - значение по умолчанию, которым заполнятся списки
  ///
  /// <br>
  ///
  /// !!!ВАЖНО!!! - к ключу будет приплюсовываться индекс, см. формат строки
  ///
  ///
  /// <br>
  ///
  /// Формат строки - {"startTime1": "Не выбрано", "endTime1": "Не выбрано", "startTime2": "Не выбрано", "endTime2": "Не выбрано", "startTime3": "Не выбрано", "endTime3": "Не выбрано", "startTime4": "Не выбрано", "endTime4": "Не выбрано", "startTime5": "Не выбрано", "endTime5": "Не выбрано", "startTime6": "Не выбрано", "endTime6": "Не выбрано", "startTime7": "Не выбрано", "endTime7": "Не выбрано"}
  ///
  ///
  static List<String> getTimeListFromJson (String json, String timeKey, String defaultValue) {

    List<String> timeList = _fillTimeListWithDefaultValues(defaultValue, 7);

    for (int i = 0; i<timeList.length; i++){
      timeList[i] = DateMixin.extractDateOrTimeFromJson(json, '$timeKey${i+1}');
    }

    return timeList;

  }

  /// Функция заполнения списка времени значениями по умолчанию
  ///
  /// <br>
  ///
  /// Вернет список, заполненный значениями.
  ///
  /// <br>
  ///
  /// Нужно передать в функцию:
  ///
  /// [String] value - значение, которым будет заполняться список
  ///
  /// [int] count - количество этих элементов в списке
  static List<String> _fillTimeListWithDefaultValues(String value, int count){

    List<String> list = [];

    for (int i = 0; i < count; i++){

      list.add(value);

    }

    return list;

  }

}
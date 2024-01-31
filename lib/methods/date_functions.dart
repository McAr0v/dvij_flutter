
import 'dart:convert';

import '../classes/event_category_class.dart';
import '../classes/event_class.dart';
import '../classes/event_type_enum.dart';
import '../classes/pair.dart';
import '../screens/events/event_view_screen.dart';

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

String getHumanDate (String date, String symbol, {bool needYear = true})
{
  List<String> stringElements = date.split(symbol);
  String month = switchMonth(stringElements[1]);

  if (needYear) {
    return '${stringElements[2]} $month ${stringElements[0]}';
  } else {
    return '${stringElements[2]} $month';
  }


}

String getOurDateFormat (String date, String symbol)
{
  List<String> stringElements = date.split(symbol);
  String month = switchMonth(stringElements[1]);
  return '${stringElements[2]}.${stringElements[1]}.${stringElements[0]}';
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

String checkTimeAndDate(
    EventTypeEnum eventType,
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
  if (eventType == EventTypeEnum.once){
    return checkOnceDayOnErrors(selectedDayInOnceType, onceDayStartTime, onceDayFinishTime);
  } else if (eventType == EventTypeEnum.long) {
    if (selectedStartDayInLongType == DateTime(2100) || selectedEndDayInLongType == DateTime(2100)){
      return 'Не выбрана дата!';
    } else if (longDayStartTime == longDayFinishTime) {
      return 'Время начала и время завершения не могут быть одинаковы';
    } else if (longDayStartTime == 'Не выбрано' || longDayFinishTime == 'Не выбрано'){
      return 'Не выбрано время!';
    } else {
      return 'success';
    }
  } else if (eventType == EventTypeEnum.regular) {

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


  } else if (eventType == EventTypeEnum.irregular) {
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

String checkOnceDayOnErrors(
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
  List<Pair<DateTime, Pair<DateTime, DateTime>>> combinedList = [];

  for (int i = 0; i < dateTimeList.length; i++) {
    // Конвертируем время из строк в DateTime

    DateTime startDateTime = DateTime.parse("${dateTimeList[i].year}-${correctMonthOrDate(dateTimeList[i].month)}-${correctMonthOrDate(dateTimeList[i].day)} ${startTime[i]}");
    DateTime endDateTime = DateTime.parse("${dateTimeList[i].year}-${correctMonthOrDate(dateTimeList[i].month)}-${correctMonthOrDate(dateTimeList[i].day)} ${endTime[i]}");
    
    if (startDateTime.isAfter(endDateTime)){
      endDateTime = endDateTime.add(Duration(days: 1));
    }

    // Создаем пару DateTime и связанные данные
    combinedList.add(Pair(dateTimeList[i], Pair(startDateTime, endDateTime)));
  }

  // Сортируем список пар по DateTime
  combinedList.sort((a, b) => a.second.first.compareTo(b.second.first));

  // Обновляем исходные списки после сортировки
  for (int i = 0; i < dateTimeList.length; i++) {
    dateTimeList[i] = combinedList[i].first;
    startTime[i] = "${correctMonthOrDate(combinedList[i].second.first.hour)}:${correctMonthOrDate(combinedList[i].second.first.minute)}";
    endTime[i] = "${correctMonthOrDate(combinedList[i].second.second.hour)}:${correctMonthOrDate(combinedList[i].second.second.minute)}";
  }

  return generateIrregularTypeDate(dateTimeList, startTime, endTime);

}

bool todayEventOrNot(EventCustom event) {

  if (event.eventType == EventCustom.getNameEventTypeEnum(EventTypeEnum.once)){

    String onceDay = extractDateOrTimeFromJson(event.onceDay, 'date');
    String startTime = extractDateOrTimeFromJson(event.onceDay, 'startTime');
    String endTime = extractDateOrTimeFromJson(event.onceDay, 'endTime');

    if (startTime != 'Не выбрано' && endTime != 'Не выбрано'){
      // Разделяем часы и минуты для парсинга
      List<String> startHourAndMinutes = startTime.split(':');
      List<String> endHourAndMinutes = endTime.split(':');

      DateTime startDateOnlyDate = DateTime.parse(onceDay);
      DateTime startDateWithHours = DateTime.parse('$onceDay ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}');
      DateTime endDateWithHours = DateTime.parse('$onceDay ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}');

      return checkDateOnToday(startDateOnlyDate, startDateWithHours, endDateWithHours);
    } else {
      return false;
    }



  } else if (event.eventType == EventCustom.getNameEventTypeEnum(EventTypeEnum.long)){

    String longStartDay = extractDateOrTimeFromJson(event.longDays, 'startDate');
    String longEndDay = extractDateOrTimeFromJson(event.longDays, 'endDate');

    String startTime = extractDateOrTimeFromJson(event.longDays, 'startTime');
    String endTime = extractDateOrTimeFromJson(event.longDays, 'endTime');

    // Разделяем часы и минуты для парсинга
    List<String> startHourAndMinutes = startTime.split(':');
    List<String> endHourAndMinutes = endTime.split(':');

    DateTime startDayInLongTypeOnlyDate = DateTime.parse(longStartDay);
    DateTime endDayInLongTypeWithHoursStartTime = DateTime.parse('$longEndDay ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}');
    DateTime endDayInLongTypeWithHoursEndTime = DateTime.parse('$longEndDay ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}');

    return checkLongDatesOnToday(
        startDayInLongTypeOnlyDate,
        endDayInLongTypeWithHoursStartTime,
        endDayInLongTypeWithHoursEndTime
    );

  } else if (event.eventType == EventCustom.getNameEventTypeEnum(EventTypeEnum.regular)){

    return checkRegularDatesOnToday(event.regularDays);

  } else if (event.eventType == EventCustom.getNameEventTypeEnum(EventTypeEnum.irregular)){

    // Это списки для временного хранения дат и времени из стринга из БД при парсинге
    List<String> tempIrregularDaysString = [];
    List<String> tempStartTimeString = [];
    List<String> tempEndTimeString = [];

    // Парсим даты и время
    parseIrregularDatesString(event.irregularDays, tempIrregularDaysString, tempStartTimeString, tempEndTimeString);

    // Проходим по списку
    for (int i = 0; i<tempIrregularDaysString.length; i++){

      // Парсим в списки часы и минуты
      List<String> startHourAndMinutes = tempStartTimeString[i].split(':');
      List<String> endHourAndMinutes = tempEndTimeString[i].split(':');

      // По принципу работы с одиночной датой - парсим начальную дату без часов, а так же начальные и конечные даты с часами
      DateTime tempStartDateOnlyDate = DateTime.parse(tempIrregularDaysString[i]);
      DateTime tempStartDateWithHours = DateTime.parse(('${tempIrregularDaysString[i]} ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}'));
      DateTime tempEndDateWithHours = DateTime.parse(('${tempIrregularDaysString[i]} ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}'));

      // Как и в одиночной дате, сравниваем с текущим временем
      bool result = checkDateOnToday(tempStartDateOnlyDate, tempStartDateWithHours, tempEndDateWithHours);
      // Первый попавшийся элемент в списке вернет тру, значит сегодня
      if (result) return true;
    }
    // Если не попался ни один из списка нерегулярных дат, вернет фалс
    return false;
  }
  return false;
}

void parseIrregularDatesString(String inputString, List<String> datesList, List<String> startTimesList, List<String> endTimesList) {
  RegExp dateRegExp = RegExp(r'"date": "([^"]+)", "startTime": "([^"]+)", "endTime": "([^"]+)"');

  List<Match> matches = dateRegExp.allMatches(inputString).toList();
  for (Match match in matches) {
    datesList.add(match.group(1)!);
    startTimesList.add(match.group(2)!);
    endTimesList.add(match.group(3)!);
  }
}

bool checkRegularDatesOnToday (String regularTimes) {

  // Инициализируем сегодня

  // берем день недели для парсинга времени проведения
  int currentDay = DateTime.now().weekday;
  // Берем сегодня как DateTime для сравнивания
  DateTime currentDayDate = DateTime.now();

  // Получаем время начала и завершения из строки из БД
  String startTimeToday = extractDateOrTimeFromJson(regularTimes, 'startTime$currentDay');
  String endTimeToday = extractDateOrTimeFromJson(regularTimes, 'endTime$currentDay');

  // Если в этот день выбрано время

  if (startTimeToday != 'Не выбрано' && endTimeToday != 'Не выбрано'){
    // Разделяем часы и минуты для парсинга
    List<String> startHourAndMinutes = startTimeToday.split(':');
    List<String> endHourAndMinutes = endTimeToday.split(':');

    // Парсим начальную дату до минут для сравнения
    DateTime parsedStartTimeToMinutes = DateTime.parse('${currentDayDate.year}-${correctMonthOrDate(currentDayDate.month)}-${currentDayDate.day} ${startHourAndMinutes[0]}:${startHourAndMinutes[1]}');

    // Парсим начальную дату уже без точности до минут
    DateTime parsedStartTime = DateTime.parse('${currentDayDate.year}-${correctMonthOrDate(currentDayDate.month)}-${currentDayDate.day}');
    // Парсим конечную дату с точностью до минуты
    DateTime parsedEndTime = DateTime.parse('${currentDayDate.year}-${correctMonthOrDate(currentDayDate.month)}-${currentDayDate.day} ${endHourAndMinutes[0]}:${endHourAndMinutes[1]}');

    // Проверка - если время завершения раньше чем время начала
    // Именно для этого нужна переменная начального времени с точностью до минуты
    // Если как бы завершение будет проходить в следущий день, то добавляем к финишной дате 1 день
    if (parsedStartTimeToMinutes.isAfter(parsedEndTime)){
      parsedEndTime = parsedEndTime.add(const Duration(days: 1));
    }

    // Если текущая дата после начальной даты без точности до минут и раньше чем дата завершения
    // PS - Так сделано специально. Если мероприятие еще не началось, но будет сегодня, надпись должна отображаться
    // и в то же время если мы уже перешагнули через время завершения, то не нужно отображать уже надпись

    if (currentDayDate.isAfter(parsedStartTime) && currentDayDate.isBefore(parsedEndTime)) {
      return true;
    } else {
      // В любых других случаях
      return false;
    }
  } else {
    return false;
  }


}

bool checkLongDatesOnToday(
    DateTime startDateOnlyDate,
    DateTime endDateWithHoursStartTime,
    DateTime endDateWithHoursEndTime,
    ){
  // Берем текущее время
  DateTime today = DateTime.now();

  // Создаем переменную на случай если заканчивается после полуночи
  DateTime currentEndDateEndTime = endDateWithHoursEndTime;

  // Флаг - надо ли в проверке окончания мероприятия ИМЕННО СЕГОДНЯ добавлять еще один день
  bool needDuration = false;

  // Если в день завершения начальное время после конечного
  // Значит заканчивается после полуночи
  if (endDateWithHoursStartTime.isAfter(endDateWithHoursEndTime)){
    // Добавляем к времени завершения 1 день
    currentEndDateEndTime = endDateWithHoursEndTime.add(Duration(days: 1));
    // Ставим флаг, что в дальнейшем при сравнении НА СЕГОДНЯ нужно так же добавить 1 день
    needDuration = true;
  }

  // Если сегодня попадает в наш диапазон дат
  if (today.isAfter(startDateOnlyDate) && today.isBefore(currentEndDateEndTime)){

    // Делаем переменные, чтобы сравнить - конкретно сегодня еще проходит мероприятие
    // Или уже нент
    DateTime tempStartTime = DateTime(today.year, today.month, today.day);
    DateTime tempEndTime = DateTime(today.year, today.month, today.day, endDateWithHoursEndTime.hour, endDateWithHoursEndTime.minute);

    // Если заканчивается после полудня, то мы так же добавляем один день к конечному времени
    if (needDuration) {
      tempEndTime = tempEndTime.add(Duration(days: 1));
    }

    // Если сегодня мероприятие еще не началось, но и не завершилось
    if (today.isAfter(tempStartTime) && today.isBefore(tempEndTime)){
      // Возвращаем тру
      return true;
    } else {
      return false;
    }

  } else {
    return false;
  }
}

bool checkDateOnToday(DateTime startEventDateOnlyDate, DateTime startEventDateWithHours, DateTime endEventDateWithOurs) {
  // Получаем текущее время
  DateTime today = DateTime.now();

  // Переменная для учета, если мероприятие заканчивается после полуночи
  DateTime currentEndEventDate = endEventDateWithOurs;

  // Здесь специальная начальная дата с часами - для сравнения с конечной датой
  // Если она больше, значит мероприятие кончится после полуночи
  // И в переменную учета мы добавляем 1 день
  if (startEventDateWithHours.isAfter(endEventDateWithOurs)){
    currentEndEventDate = endEventDateWithOurs.add(Duration(days: 1));
  }

  // Вернет тру, если текущая дата будет после начальной даты
  // И до времени окончания мероприятия
  return today.isAfter(startEventDateOnlyDate) && today.isBefore(currentEndEventDate);
}

bool checkDatesForFilter (
    EventCustom event,
    DateTime selectedStartDatePeriod,
    DateTime selectedEndDatePeriod,
    ) {

  EventTypeEnum eventTypeEnum = EventCustom.getEventTypeEnum(event.eventType);

  switch (eventTypeEnum) {
    case EventTypeEnum.once: return checkOnceDayForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);
    case EventTypeEnum.long: return checkLongDayForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);
    case EventTypeEnum.regular: return checkRegularDayForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);
    case EventTypeEnum.irregular: return checkIrregularDayForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);
  }

}

bool checkOnceDayForFilter (
    EventCustom event,
    DateTime selectedStartDatePeriod,
    DateTime selectedEndDatePeriod,
    ) {

  // ФУНКЦИЯ ПРОВЕРКИ ОДИНОЧНОЙ ДАТЫ НА ПОПАДАНИЕ В ЗАДАННЫЙ ПЕРИОД

  DateTime eventDate = DateTime.parse(extractDateOrTimeFromJson(event.onceDay, 'date'));

  return (eventDate.isAtSameMomentAs(selectedStartDatePeriod) || eventDate.isAfter(selectedStartDatePeriod)) &&
      (eventDate.isBefore(selectedEndDatePeriod) || eventDate.isAtSameMomentAs(selectedEndDatePeriod));

}

bool checkLongDayForFilter (
    EventCustom event,
    DateTime selectedStartDatePeriod,
    DateTime selectedEndDatePeriod,
    ) {

  // ФУНКЦИЯ ПРОВЕРКИ ДАТЫ В ВИДЕ ПЕРИОДА НА ПОПАДАНИЕ В ЗАДАННЫЙ ПЕРИОД

  DateTime eventStartDate = DateTime.parse(extractDateOrTimeFromJson(event.longDays, 'startDate'));
  DateTime eventEndDate = DateTime.parse(extractDateOrTimeFromJson(event.longDays, 'endDate'));

  return (eventStartDate.isAtSameMomentAs(selectedEndDatePeriod) || eventStartDate.isBefore(selectedEndDatePeriod) &&
  eventEndDate.isAtSameMomentAs(selectedStartDatePeriod) || eventEndDate.isAfter(selectedStartDatePeriod));

}

bool checkRegularDayForFilter (
    EventCustom event,
    DateTime selectedStartDatePeriod,
    DateTime selectedEndDatePeriod,
    ) {

  // ФУНКЦИЯ ПРОВЕРКИ РЕГУЛЯРНОЙ ДАТЫ НА ПОПАДАНИЕ В ЗАДАННЫЙ ПЕРИОД

  bool result = false;

  List<int> eventWeekDays = [];
  List<int> filterWeekDays = [];

  // Считываем дни недели, в которые проводится мероприятие
  for (int i = 0; i<7; i++){

    String tempStartTime = extractDateOrTimeFromJson(event.regularDays, 'startTime${i+1}');

    if (tempStartTime != 'Не выбрано') eventWeekDays.add(i+1);

  }

  // Считываем дни недели периода из фильтра

  for (int i = 0; i<7; i++){

    DateTime tempDate = selectedStartDatePeriod.add(Duration(days: i));

    if (tempDate.isBefore(selectedEndDatePeriod) || tempDate.isAtSameMomentAs(selectedEndDatePeriod)){
      filterWeekDays.add(tempDate.weekday);
    }
  }

  for (int eventWeekDay in eventWeekDays){
    if (eventWeekDays.isNotEmpty && filterWeekDays.isNotEmpty && filterWeekDays.contains(eventWeekDay)) {
      result = true;
    }
  }

  return result;

}

bool checkIrregularDayForFilter(
    EventCustom event,
    DateTime selectedStartDatePeriod,
    DateTime selectedEndDatePeriod,
    ){

  List<String> tempIrregularDaysString = [];
  List<String> tempStartTimeString = [];
  List<String> tempEndTimeString = [];

  // Парсим даты и время
  parseIrregularDatesString(event.irregularDays, tempIrregularDaysString, tempStartTimeString, tempEndTimeString);

  // Проходим по списку
  for (int i = 0; i<tempIrregularDaysString.length; i++){

    // По принципу работы с одиночной датой - парсим начальную дату без часов, а так же начальные и конечные даты с часами
    DateTime tempOnlyDate = DateTime.parse(tempIrregularDaysString[i]);

    // Как и в одиночной дате, сравниваем с текущим временем

    if (
    (tempOnlyDate.isAfter(selectedStartDatePeriod) || tempOnlyDate.isAtSameMomentAs(selectedStartDatePeriod))
        && (tempOnlyDate.isBefore(selectedEndDatePeriod) || tempOnlyDate.isAtSameMomentAs(selectedEndDatePeriod))
    ){
      return true;
    }

  }

  return false;

}
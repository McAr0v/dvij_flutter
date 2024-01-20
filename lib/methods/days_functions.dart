import 'package:dvij_flutter/classes/place_class.dart';

bool currentDayOfWeek (int dayOfWeek)
{
  final currentDate = DateTime.now();
  final currentDayOfWeek = currentDate.weekday;

  if (dayOfWeek == currentDayOfWeek){
    return true;
  }

  return false;
}


bool isPlaceOpen(String startTime, String endTime, /*DateTime currentDate*/) {
  DateTime currentDate = DateTime.now().add(const Duration(hours: 6));
  DateTime start = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(startTime.split(':')[0]), int.parse(startTime.split(':')[1]));
  DateTime end = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(endTime.split(':')[0]), int.parse(endTime.split(':')[1]));

  if (end.isBefore(start)) {
    end = end.add(Duration(days: 1));
  }

  print("Current time: $currentDate");
  print("Start time: $start");
  print("End time: $end");


  return currentDate.isAfter(start) && currentDate.isBefore(end);
}

bool isEventToday(String startTime, String endTime, /*DateTime currentDate*/) {
  DateTime currentDate = DateTime.now().add(const Duration(hours: 6));
  DateTime start = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(startTime.split(':')[0]), int.parse(startTime.split(':')[1]));
  DateTime end = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(endTime.split(':')[0]), int.parse(endTime.split(':')[1]));

  if (end.isBefore(start)) {
    end = end.add(Duration(days: 1));
  }

  print("Current time: $currentDate");
  print("Start time: $start");
  print("End time: $end");


  return currentDate.isAfter(start) && currentDate.isBefore(end);
}

/*bool isPlaceOpen(String startTime, String endTime) {
  DateTime currentDate = DateTime.now();

  List<int> startComponents = startTime.split(':').map(int.parse).toList();
  List<int> endComponents = endTime.split(':').map(int.parse).toList();

  DateTime start = DateTime(currentDate.year, currentDate.month, currentDate.day, startComponents[0], startComponents[1]);
  DateTime end = DateTime(currentDate.year, currentDate.month, currentDate.day, endComponents[0], endComponents[1]);

  // Добавляем один день к конечной дате, если она меньше начальной, чтобы учесть случай перехода через полночь
  if (end.isBefore(start)) {
    end = end.add(Duration(days: 1));
  }

  print("Current time: $currentDate");
  print("Start time: $start");
  print("End time: $end");

  return currentDate.isAfter(start) && currentDate.isBefore(end);
}*/

List<String> fillTimeListWithDefaultValues(String value, int count){

  List<String> list = [];

  for (int i = 0; i < count; i++){

    list.add(value);

  }

  return list;

}

bool nowIsOpenPlace (Place place){

  DateTime currentDate = DateTime.now();

  final currentDayOfWeek = currentDate.weekday;

  String startTime = '';
  String finishTime = '';

  switch (currentDayOfWeek){

    case 1: {
      startTime = place.mondayStartTime;
      finishTime = place.mondayFinishTime;
    }
    case 2: {
      startTime = place.tuesdayStartTime;
      finishTime = place.tuesdayFinishTime;
    }
    case 3: {
      startTime = place.wednesdayStartTime;
      finishTime = place.wednesdayFinishTime;
    }
    case 4: {
      startTime = place.thursdayStartTime;
      finishTime = place.thursdayFinishTime;
    }
    case 5: {
      startTime = place.fridayStartTime;
      finishTime = place.fridayFinishTime;
    }
    case 6: {
      startTime = place.saturdayStartTime;
      finishTime = place.saturdayFinishTime;
    }
    default: {
      startTime = place.sundayStartTime;
      finishTime = place.sundayFinishTime;
    }

  }



  if (startTime != 'Выходной' && finishTime != 'Выходной' ) {
    return isPlaceOpen(startTime, finishTime, /*currentDate*/);
  } else {
    return false;
  }



}








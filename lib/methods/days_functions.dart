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

bool isPlaceOpen(String startTime, String endTime, DateTime currentDate) {
  DateTime start = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(startTime.split(':')[0]), int.parse(startTime.split(':')[1]));
  DateTime end = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(endTime.split(':')[0]), int.parse(endTime.split(':')[1]));

  return currentDate.isAfter(start) && currentDate.isBefore(end);
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

  return isPlaceOpen(startTime, finishTime, currentDate);

}








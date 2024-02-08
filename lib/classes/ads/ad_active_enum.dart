import 'package:dvij_flutter/classes/ads/enums_interface.dart';

enum AdActiveEnum {
  notActive,
  active,
  inFuture
}

class AdActiveEnumClass implements CustomEnums<AdActiveEnum>{

  @override
  AdActiveEnum getEnumFromString(String enumString) {
    switch (enumString){
      case 'notActive': return AdActiveEnum.notActive;
      case 'active': return AdActiveEnum.active;
      case 'inFuture': return AdActiveEnum.inFuture;
      default: return AdActiveEnum.notActive;
    }
  }

  @override
  String getNameEnum(AdActiveEnum enumItem, {bool translate = false}) {
    switch (enumItem) {
      case AdActiveEnum.notActive:
        return !translate ? 'notActive' : 'Не активно';
      case AdActiveEnum.active:
        return !translate ? 'active' : 'Активно';
      case AdActiveEnum.inFuture:
        return !translate ? 'inFuture' : 'Запланировано';
    }
  }

  static AdActiveEnum getEnumFromDate (String startDate, String endDate){

    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);
    DateTime today = DateTime.now();
    AdActiveEnum result = AdActiveEnum.notActive;

    if (
        (today.isAfter(start) || today.isAtSameMomentAs(start)) &&
        (today.isBefore(end) || today.isAtSameMomentAs(end))
    ){
      result = AdActiveEnum.active;
    } else if (today.isBefore(start)){
      result = AdActiveEnum.inFuture;
    }

    return result;

  }

}
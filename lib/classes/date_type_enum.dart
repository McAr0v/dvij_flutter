import '../ads/ads_enums/enums_interface.dart';

enum DateTypeEnum {
  once,
  long,
  regular,
  irregular
}

class DateTypeEnumClass implements CustomEnums<DateTypeEnum>{

  DateTypeEnumClass();

  @override
  DateTypeEnum getEnumFromString(String enumString) {
    switch (enumString){
      case 'once': return DateTypeEnum.once;
      case 'long': return DateTypeEnum.long;
      case 'regular': return DateTypeEnum.regular;
      case 'irregular': return DateTypeEnum.irregular;
      default: return DateTypeEnum.once;
    }
  }

  @override
  String getNameEnum(DateTypeEnum enumItem, {bool translate = false}) {
    switch (enumItem) {
      case DateTypeEnum.once:
        return !translate ? 'once' : 'В определенную дату';
      case DateTypeEnum.long:
        return !translate ? 'long' : 'В период дат';
      case DateTypeEnum.regular:
        return !translate ? 'regular' : 'Регулярное';
      case DateTypeEnum.irregular:
        return !translate ? 'irregular' : 'В разные даты';
    }
  }
}
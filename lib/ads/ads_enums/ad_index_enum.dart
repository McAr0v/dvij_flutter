import 'enums_interface.dart';

enum AdIndexEnum {
  first,
  second,
  third,
  all
}

class AdIndexEnumClass implements CustomEnums<AdIndexEnum> {

  @override
  AdIndexEnum getEnumFromString(String enumString) {
    switch (enumString){
      case 'first': return AdIndexEnum.first;
      case 'second': return AdIndexEnum.second;
      case 'third': return AdIndexEnum.third;
      case 'all': return AdIndexEnum.all;
      default: return AdIndexEnum.first;
    }
  }

  @override
  String getNameEnum(AdIndexEnum enumItem, {bool translate = false}) {
    switch (enumItem) {
      case AdIndexEnum.first:
        return !translate ? 'first' : 'Слот №1';
      case AdIndexEnum.second:
        return !translate ? 'second' : 'Слот №2';
      case AdIndexEnum.third:
        return !translate ? 'third' : 'Слот №3';
      case AdIndexEnum.all:
        return !translate ? 'all' : 'Везде';
    }
  }

}
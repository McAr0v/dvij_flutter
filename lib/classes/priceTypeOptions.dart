import '../ads/ads_enums/enums_interface.dart';

enum PriceTypeOption {
  free,
  fixed,
  range
}

class PriceTypeEnumClass implements CustomEnums<PriceTypeOption>{

  PriceTypeEnumClass();

  @override
  PriceTypeOption getEnumFromString(String enumString) {
    switch (enumString){
      case 'free': return PriceTypeOption.free;
      case 'fixed': return PriceTypeOption.fixed;
      case 'range': return PriceTypeOption.range;
      default: return PriceTypeOption.free;
    }
  }

  @override
  String getNameEnum(PriceTypeOption enumItem, {bool translate = false}) {
    switch (enumItem) {
      case PriceTypeOption.free:
        return !translate ? 'free' : 'Бесплатный вход';
      case PriceTypeOption.fixed:
        return !translate ? 'fixed' : 'Фиксированная цена';
      case PriceTypeOption.range:
        return !translate ? 'range' : 'Диапазон цен';
    }
  }
}
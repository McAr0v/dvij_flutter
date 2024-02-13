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

  static String getFormattedPriceString (PriceTypeOption priceType, String price){

    // Функция преобразования цены из БД в человеческий вид

    switch (priceType) {

      case PriceTypeOption.free: return 'Вход бесплатный';
      case PriceTypeOption.fixed: return '$price тенге';
      case PriceTypeOption.range: {
        List<String> temp = price.split('-');
        return 'от ${temp[0]} тенге - до ${temp[1]} тенге';
      }
    }
  }

  static String getPriceString(PriceTypeOption priceType, String fixedPrice, String startPrice, String endPrice){
    switch (priceType){
      case PriceTypeOption.free: return '';
      case PriceTypeOption.fixed: return fixedPrice;
      case PriceTypeOption.range: return '$startPrice-$endPrice';
    }
  }

}
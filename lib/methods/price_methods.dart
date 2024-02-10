import '../events/event_class.dart';
import '../classes/priceTypeOptions.dart';

class PriceMethods {

  static String getFormattedPriceString (String priceType, String price){

    // Функция преобразования цены из БД в человеческий вид

    PriceTypeOption priceTypeOption = EventCustom.getPriceTypeEnum(priceType);

    switch (priceTypeOption) {

      case PriceTypeOption.free: return 'Вход бесплатный';
      case PriceTypeOption.fixed: return '$price тенге';
      case PriceTypeOption.range: {
        List<String> temp = price.split('-');
        return 'от ${temp[0]} тенге - до ${temp[1]} тенге';
      }
    }
  }

}
import 'package:dvij_flutter/promos/promo_class.dart';

import '../dates/date_type_enum.dart';
import '../dates/date_mixin.dart';
import '../events/event_class.dart';

mixin FilterMixin {

  static bool checkEventDatesForFilter (
      EventCustom event,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    DateTypeEnum dateTypeEnum = event.dateType;

    switch (dateTypeEnum) {
      case DateTypeEnum.once: return event.onceDay.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.long: return event.longDays.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.regular: return event.regularDays.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.irregular: return event.irregularDays.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
    }

  }

  static bool checkPromoDatesForFilter (
      PromoCustom promo,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    DateTypeEnum dateTypeEnum = promo.dateType;

    switch (dateTypeEnum) {
      case DateTypeEnum.once: return promo.onceDay.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.long: return promo.longDays.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.regular: return promo.regularDays.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
      case DateTypeEnum.irregular: return promo.irregularDays.checkDateForFilter(selectedStartDatePeriod, selectedEndDatePeriod);
    }

  }

}
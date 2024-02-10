import 'package:dvij_flutter/promos/promo_category_class.dart';

extension SortPromoCategoryListExtension on List<PromoCategory> {
  void sortPromoCategories(bool order) {
    if (order) {
      sort((a, b) => a.name.compareTo(b.name));
    } else {
      sort((a, b) => b.name.compareTo(a.name));
    }
  }
}
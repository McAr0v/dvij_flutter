import 'package:dvij_flutter/places/place_category_class.dart';

extension SortPlaceCategoryListExtension on List<PlaceCategory> {
  void sortPlaceCategories(bool order) {
    if (order) {
      sort((a, b) => a.name.compareTo(b.name));
    } else {
      sort((a, b) => b.name.compareTo(a.name));
    }
  }
}
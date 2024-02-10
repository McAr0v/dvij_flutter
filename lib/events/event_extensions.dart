import 'package:dvij_flutter/events/event_category_class.dart';

extension SortEventCategoryListExtension on List<EventCategory> {
  void sortEventCategories(bool order) {
    if (order) {
      sort((a, b) => a.name.compareTo(b.name));
    } else {
      sort((a, b) => b.name.compareTo(a.name));
    }
  }
}
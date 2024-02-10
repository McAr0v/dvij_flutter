import 'city_class.dart';

extension SortCityListExtension on List<City> {
  void sortCities(bool order) {
    if (order) {
      sort((a, b) => a.name.compareTo(b.name));
    } else {
      sort((a, b) => b.name.compareTo(a.name));
    }
  }
}
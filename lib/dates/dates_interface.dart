abstract class IDates<T> {
  T getFromJson(String json);
  String generateDateStingForDb();
  bool dateIsNotEmpty();
  T generateDateForEntity(Map<String, dynamic> mapOfArguments);
  bool todayOrNot();
  bool checkDateForFilter(DateTime startPeriod, DateTime endPeriod);

}
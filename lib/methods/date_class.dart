class DateClass {

  static DateTime getDateFromString(String date){
    return DateTime.parse(date);
  }

  static String generateDateSting(DateTime date){
    return '${date.year}-${_getCorrectMonthOrDate(date.month)}-${_getCorrectMonthOrDate(date.day)}';
  }

  static String _getCorrectMonthOrDate(int number){
    if (number < 10) {
      return '0$number';
    } else {
      return '$number';
    }
  }

  static String getMonthName (String month)
  {
    switch (month)
    {
      case '1': return 'января';
      case '01': return 'января';
      case '2': return 'февраля';
      case '02': return 'февраля';
      case '3': return 'марта';
      case '03': return 'марта';
      case '4': return 'апреля';
      case '04': return 'апреля';
      case '5': return 'мая';
      case '05': return 'мая';
      case '6': return 'июня';
      case '06': return 'июня';
      case '7': return 'июля';
      case '07': return 'июля';
      case '8': return 'августа';
      case '08': return 'августа';
      case '9': return 'сентября';
      case '09': return 'сентября';
      case '10': return 'октября';
      case '11': return 'ноября';
      default: return 'декабря';
    }
  }

  static String getHumanDate (String date, String symbol, {bool needYear = true})
  {
    List<String> stringElements = date.split(symbol);
    String month = getMonthName(stringElements[1]);

    if (needYear) {
      return '${stringElements[2]} $month ${stringElements[0]}';
    } else {
      return '${stringElements[2]} $month';
    }

  }

  static bool nowIsInPeriod (DateTime startDate, DateTime endDate){
    return nowIsAfterStart(startDate) && nowIsBeforeEnd(endDate);
  }

  static bool nowIsAfterStart (DateTime checkedDate){
    return DateTime.now().isAfter(checkedDate);
  }

  static bool nowIsBeforeEnd (DateTime checkedDate){
    return DateTime.now().isBefore(checkedDate);
  }

}
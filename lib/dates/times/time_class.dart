class TimeCustom {
  String hour = '';
  String minutes = '';

  TimeCustom({String? time}) {
    // Parse the time string and set hour and minutes
    if (time != null && time != 'Не выбрано') {
      List<String> parts = time.split(':');
      hour = parts[0];
      minutes = parts[1];
    } else {
      hour;
      minutes;
    }
  }

  @override
  String toString() {
    if (hour == '' || minutes == ''){
      return 'Не выбрано';
    } else {
      return '$hour:$minutes';
    }
  }

}
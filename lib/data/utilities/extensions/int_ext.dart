extension IntExt on int {
  String get toWeekdayName {
    if (this >= 1 && this <= 7) {
      switch (this) {
        case 7:
          return 'Sunday';
        case 1:
          return 'Monday';
        case 2:
          return 'Tuesday';
        case 3:
          return 'Wednesday';
        case 4:
          return 'Thursday';
        case 5:
          return 'Friday';
        case 6:
          return 'Saturday';
      }
    }
    throw Exception('Invalid weekday number: $this');
  }
}

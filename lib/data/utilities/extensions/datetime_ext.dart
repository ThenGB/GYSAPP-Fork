import 'package:easy_localization/easy_localization.dart';

extension HumanDate on DateTime {
  String toHumanDate() {
    DateTime now = DateTime.now().toLocal();
    DateTime today = DateTime(now.year, now.month, now.day, now.hour);
    DateTime yesterday = today.subtract(Duration(days: 1));

    DateFormat timeFormat = DateFormat.Hm();
    DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd H:m');

    if (isSameDay(today)) {
      // Return HH:mm for today's date
      return timeFormat.format(this);
    } else if (isSameDay(yesterday)) {
      // Return "Yesterday" for yesterday's date
      return '${'Yesterday'.tr()} ${timeFormat.format(this)}';
    } else {
      // Return the full date for other dates
      return dateTimeFormat.format(this);
    }
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

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

extension SizeExtensions on int {
  String fromSizeToBytes() {
    if (this < 1024) {
      return '$this B';
    } else if (this < 1024 * 1024) {
      double kb = this / 1024;
      return '${kb.toStringAsFixed(2)} KB';
    } else if (this < 1024 * 1024 * 1024) {
      double mb = this / (1024 * 1024);
      return '${mb.toStringAsFixed(2)} MB';
    } else {
      double gb = this / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(2)} GB';
    }
  }
}

extension ListInt on List<int> {
  String joinToString() {
    if (isEmpty) {
      return '';
    }

    final sortedList = List<int>.from(this)..sort();
    final result = StringBuffer();

    int start = sortedList.first;
    int end = sortedList.first;

    for (int i = 1; i < sortedList.length; i++) {
      if (sortedList[i] == end + 1) {
        end = sortedList[i];
      } else {
        if (start == end) {
          result.write('$start, ');
        } else {
          result.write('$start-$end, ');
        }
        start = sortedList[i];
        end = sortedList[i];
      }
    }

    if (start == end) {
      result.write('$start');
    } else {
      result.write('$start-$end');
    }

    return result.toString();
  }
}

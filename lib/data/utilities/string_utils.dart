import 'dart:developer';

import 'package:intl/intl.dart';

class StringUtil {
  static bool isStringNullOrEmpty(String? strValue) {
    return (strValue?.isEmpty ?? true);
  }

  static int toInt(String strValue) {
    int intValue = 0;
    try {
      intValue = toDouble(strValue).truncate();
    } catch (e) {
      log('Exception method toInt : $e');
    }
    return intValue;
  }

  static double toDouble(String strValue) {
    strValue = removeDgtGroup(strValue);
    double doubleValue = 0;
    try {
      if (!isStringNullOrEmpty(strValue)) {
        doubleValue = double.parse(strValue);
      }
    } catch (e) {
      log('Exception method toDouble : $e');
    }
    return doubleValue;
  }

  static String? replacePipeLine(String? str) {
    return !isStringNullOrEmpty(str) ? str?.replaceAll('|', ' ') : '';
  }

  static String castToString(dynamic o) {
    return o == null ? '' : o.toString();
  }

  static String removeDgtGroup(String str) {
    return str.replaceAll(',', '');
  }

  static String formatDigitGroupDbl(double? val) {
    String mOut = '';
    if (val != null) {
      if (val == val.truncateToDouble()) {
        //. tidak punya koma
        if (val.floor() == 0) {
          mOut = '0';
        } else {
          mOut = NumberFormat('#,###').format(val);
        }
      } else {
        //. jika punya koma maka kasih 2 digit
        if (val.floor() == 0) {
          mOut = NumberFormat('0.00').format(val);
        } else {
          mOut = NumberFormat('#,###.00').format(val);
        }
      }
    }
    return mOut;
  }

  static String formatDigitGroupInt(int? val) {
    String mOut = '';
    if (val != null) {
      mOut = NumberFormat('#,###').format(val);
    }
    return mOut;
  }

  static String roundLongNumberInt(int? val) {
    return roundLongNumberDbl(val?.truncateToDouble());
  }

  static String roundLongNumberDbl(double? val) {
    String mOut = '';
    String vSign = '';
    if (val != null) {
      if (val < 0) {
        vSign = '-';
      }
      val = val.abs();
      double vResult = 0;
      String vSuffix = '';
      String vNumber = '';
      if (val >= 1000000000000) {
        vResult = (val / 1000000000000).toDouble();
        vSuffix = ' T';
      } else if (val >= 1000000000) {
        vResult = (val / 1000000000).toDouble();
        vSuffix = ' B';
      } else if (val >= 1000000) {
        vResult = (val / 1000000).toDouble();
        vSuffix = ' M';
      }
      if (vResult == 0) {
        vNumber = formatDigitGroupDbl(val);
      } else {
        vNumber = formatDigitGroupDbl(vResult) + vSuffix;
      }
      mOut = vSign + vNumber;
    }
    return mOut;
  }

  static String formatDblToString(double n, int dec) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : dec);
  }

  static String formatDate(DateTime? date, [String? format]) {
    //default sql date format
    String? stringdate;
    if (date != null) {
      if (format != null) {
        stringdate = DateFormat(format).format(date);
      } else {
        stringdate = DateFormat('YYYY-MM-DD').format(date);
      }
    }
    return stringdate ?? '';
  }

  static DateTime? formatToDateTime(dynamic date, [String? format]) {
    DateTime? val;
    val = DateTime.tryParse(date);
    return val;
  }
}


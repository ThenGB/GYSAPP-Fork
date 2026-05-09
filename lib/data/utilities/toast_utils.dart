import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'platform_utils.dart';

void safeToastCancel() {
  if (!isFluttertoastConfiguredForCurrentPlatform) return;
  try {
    Fluttertoast.cancel();
  } on MissingPluginException catch (_) {}
}

void safeShowToast({
  required String msg,
  Toast? toastLength,
  ToastGravity? gravity,
  int? timeInSecForIosWeb,
  double? fontSize,
  Color? backgroundColor,
  Color? textColor,
  bool webShowClose = false,
  String? webBgColor,
  String? webPosition,
}) {
  if (!isFluttertoastConfiguredForCurrentPlatform) return;
  try {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength ?? Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: timeInSecForIosWeb ?? 1,
      fontSize: fontSize ?? 16.0,
      backgroundColor: backgroundColor,
      textColor: textColor,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  } on MissingPluginException catch (_) {}
}

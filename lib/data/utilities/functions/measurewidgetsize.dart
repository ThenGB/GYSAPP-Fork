import 'dart:developer';

import 'package:flutter/material.dart';

import '../../data.dart';

Future<void> measureWidgetSize(BuildContext context,
    {required List<GlobalKey> keys,
    required Function(double result) callback}) async {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    log('Measuring sheet');
    double widgetSize = 0;
    for (var key in keys) {
      final renderWidget = key.currentContext?.findRenderObject() as RenderBox?;
      log(renderWidget?.size.height.toString() ?? '0', name: 'widget size');
      widgetSize += renderWidget?.size.height ?? 0;
    }

    final renderScreen = context.mediaQuery.size.height -
        context.mediaQuery.padding.vertical -
        context.mediaQuery.viewPadding.vertical;
    final result = widgetSize / renderScreen;
    log('$widgetSize / $renderScreen', name: 'total :    ');
    log('Measuring sheet completed with result $result');
    callback(result);
  });
}

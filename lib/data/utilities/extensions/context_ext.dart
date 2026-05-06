import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  Color? get textColor => theme.textTheme.titleSmall?.color;
  Color? get textDisplayColor => theme.textTheme.displaySmall?.color;
  TextTheme get primaryTextTheme => theme.primaryTextTheme;
  Brightness get brightness => theme.brightness;
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  double get shortestSide => mediaQuery.size.shortestSide;
  double get longestSide => mediaQuery.size.longestSide;
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  bool get isSmall => shortestSide < 600;
  bool get isMedium => shortestSide >= 600 && shortestSide < 960;
  bool get isLarge => shortestSide >= 960 && shortestSide < 1280;
  bool get isExtraLarge => shortestSide >= 1280;
  bool get isExtraSmall => shortestSide < 360;
  bool get isExtraExtraSmall => shortestSide < 320;
  bool get isExtraExtraExtraSmall => shortestSide < 280;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> showConfirmation(String question) async {
    return await showDialog(
          context: this,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AlertDialog(
                backgroundColor: colorScheme.surface,
                contentPadding: EdgeInsets.all(8),
                titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor),
                alignment: Alignment.center,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                titlePadding: EdgeInsets.symmetric(horizontal: 0),
                actionsPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                title: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Confirmation'.tr(),
                          textAlign: TextAlign.center),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: context.textColor?.withValues(alpha: .3),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      height: 4,
                      width: 40,
                    ),
                  ],
                ),
                content: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    question,
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: context.colorScheme.primary,
                                  strokeAlign: BorderSide.strokeAlignInside,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Yes'.tr()),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: context.colorScheme.primary,
                              foregroundColor: context.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('No'.tr()),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
  }
}


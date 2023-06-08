import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
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
  TextDirection get textDirection => Directionality.of(this);
  bool get isRTL => textDirection == TextDirection.rtl;
  bool get isLTR => textDirection == TextDirection.ltr;
  bool get isSmall => shortestSide < 600;
  bool get isMedium => shortestSide >= 600 && shortestSide < 960;
  bool get isLarge => shortestSide >= 960 && shortestSide < 1280;
  bool get isExtraLarge => shortestSide >= 1280;
  bool get isExtraSmall => shortestSide < 360;
  bool get isExtraExtraSmall => shortestSide < 320;
  bool get isExtraExtraExtraSmall => shortestSide < 280;

  showSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> showConfirmation(String question) async {
    return await showDialog(
          context: this,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text(question),
              actions: [
                TextButton(
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                  ),
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

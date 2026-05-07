import 'package:flutter/material.dart';

extension LocaleExt on Locale {
  String get languageName {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      case 'zh':
        return 'Chinese';
      default:
        return 'Unknown';
    }
  }
}


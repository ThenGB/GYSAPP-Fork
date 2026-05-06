import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';

import '../platform_utils.dart';

class Failure {
  final String message;
  Failure(this.message);
  factory Failure.fromError(Object e, [StackTrace? stackTrace]) {
    if (isFirebaseCrashlyticsConfiguredForCurrentPlatform &&
        Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
    String errorMessage = e.toString();

    if (e is FileSystemException) {
      errorMessage =
          '(${e.osError?.errorCode ?? '0mf'}) ${e.osError?.message ?? 'File not found'}';
    }

    if (e is TypeError) {
      errorMessage =
          '(Api Error) ' 'Error while parsing the response (${e.runtimeType})';
    }

    if (e is ApiException) {
      errorMessage = e.message ?? 'Unknown server error';
      // Catcher.reportCheckedError(e, stackTrace);
    } else {
      if (!(errorMessage.startsWith('Please relogin')) ||
          !(errorMessage == 'Login cancelled')) {}
    }
    if (e is MissingPluginException) {
      errorMessage =
          'Please try again. if problem persists, contact developer.';
    }
    return Failure(errorMessage.tr());
  }
  @override
  String toString() {
    return message;
  }
}

///make a class called ApiException
class ApiException implements Exception {
  final String? message;
  ApiException(this.message);
}

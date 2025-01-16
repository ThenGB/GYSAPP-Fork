import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseUtils {
  const FirebaseUtils._();
  static Completer<FirebaseRemoteConfig> initialization = Completer();
  static Future<Map<String, dynamic>> jsonConfig(String key) async {
    try {
      var config = await initialization.future;
      var jsonString = config.getString(key);
      Map<String, dynamic> json = jsonDecode(jsonString);
      log(json.toString(), name: 'Get $key from Remote Config');
      return json;
    } catch (e) {
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> listMapConfig(String key) async {
    try {
      var config = await initialization.future;
      var jsonString = config.getString(key);
      List<dynamic> json = jsonDecode(jsonString);
      log(json.toString(), name: 'Get $key from Remote Config');
      return json.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String> stringConfig(String key) async {
    var config = await initialization.future;
    var jsonString = config.getString(key);
    log(jsonString.toString(), name: 'Get $key from Remote Config');
    return jsonString;
  }

  static Future<bool> boolConfig(String key) async {
    var config = await initialization.future;
    var jsonString = config.getBool(key);
    log(jsonString.toString(), name: 'Get $key from Remote Config');
    return jsonString;
  }

  static Future<Map> getAllConfigs() async {
    var config = await initialization.future;
    return config.getAll();
  }
}

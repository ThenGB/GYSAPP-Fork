import 'dart:convert';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseUtils {
  const FirebaseUtils._();
  static Map<String, dynamic> jsonConfig(String key) {
    try {
      var jsonString = FirebaseRemoteConfig.instance.getString(key);
      Map<String, dynamic> json = jsonDecode(jsonString);
      log(json.toString(), name: 'Get $key from Remote Config');
      return json;
    } catch (e) {
      return {};
    }
  }

  static List<Map<String, dynamic>> listMapConfig(String key) {
    try {
      var jsonString = FirebaseRemoteConfig.instance.getString(key);
      List<dynamic> json = jsonDecode(jsonString);
      log(json.toString(), name: 'Get $key from Remote Config');
      return json.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  static String stringConfig(String key) {
    var jsonString = FirebaseRemoteConfig.instance.getString(key);
    log(jsonString.toString(), name: 'Get $key from Remote Config');
    return jsonString;
  }
}

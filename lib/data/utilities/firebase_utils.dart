import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseUtils {
  const FirebaseUtils._();
  static Completer<FirebaseRemoteConfig> initialization = Completer();
  static bool _useFallbackConfig = false;

  static final Map<String, Object> fallbackConfig = {
    'enable_memberarea': 'true',
    'notifikasi_bible':
        '{"title":{"en":"Its time to read the Bible..","id":"Waktunya membaca..","zh":"讀經時了.."},"body":{"en":"Have you read the Bible today?","id":"Sudahkah membaca Alkitab hari ini?","zh":"今日讀經了嗎?"},"imageUrl":"https://tjc.org/wp-content/uploads/2016/05/tjclogo_english_680x88.png"}',
    'primary_menu': '{"sauh_bagi_jiwa":true,"suara_sejati":true}',
    'footer_copied_text':
        '{\n  "en": "Download GYS App on\\n\\nPlaystore \\nhttps://play.store.com\\n\\nAppStore \\nhttps://app.store.com",\n    "id": "Download GYS App on\\n\\nPlaystore \\nhttps://play.store.com\\n\\nAppStore \\nhttps://app.store.com",\n      "zh": "Download GYS App on\\n\\nPlaystore \\nhttps://play.store.com\\n\\nAppStore \\nhttps://app.store.com"\n}',
    'testpath': 'asdasdasdasdasdasdasd',
    'app_menu':
        '[{"label":"eRhema","icon":"https://play-lh.googleusercontent.com/nxpU2jVSvYA4JnGWPHzw-l5j23DIgIqumkdR_aiOndyhjNB2fEkS9Tp296G-p6VX8E8","url":"https://Bible.tjc.org","enabled":true},{"label":"PelitaKecil","icon":"assets/icons/rhema.png","url":"https://pelitakecil.com/","enabled":true},{"label":"Literatur","icon":"assets/icons/literatur.png","url":"/literature","enabled":true},{"label":"Podcast","icon":"assets/icons/podcast.png","url":"https://www.youtube.com/channel/UCnKhYlQA5iJJvobPF4IYJFQ","enabled":true},{"label":"Khotbah","icon":"assets/icons/khotbah.png","url":"khotbah","enabled":true},{"label":"Facebook","icon":"assets/icons/facebook.png","url":"https://www.facebook.com/gerejayesussejati/","enabled":true},{"label":"Instagram","icon":"assets/icons/instagram.png","url":"https://www.instagram.com/gerejayesussejati/","enabled":true},{"label":"Youtube","icon":"assets/icons/youtube.png","url":"https://www.youtube.com/channel/UCAHSLvPBcg2M-_N1VQfhxrg","enabled":true},{"label":"Spotify","icon":"assets/icons/spotify.png","url":"https://open.spotify.com/show/4edDo52t3IlkgiWhBnk1GK","enabled":true}]',
    'biblepath': '/Project/Hatiku/v2/alkitab',
    'config_literature':
        '{"kesaksian":"#posts-table-1 > tbody > tr > td > a","wartasejati":"#posts-table-2 > tbody > tr > td > a","panduanalkitab":"article","renungan":"div.module.module-accordion.tb_1uum169 > ul > li > div > div > div > table > tbody > tr > td > a","pelitakecil":"#posts-table-3 > tbody > tr > td > a","notifikasi_sabat":{"title":"Notifikasi Sabat","body":"Ingat dan Kuduskanlah Hari Sabat ... ","image":"https://tjc.org/wp-content/uploads/2016/05/tjclogo_english_680x88.png"}}',
    'mailer_recipients':
        '[{"address":"harley@itmandiri.com","name":"Pak Harley"}]',
    'ftp_server':
        '{"host":"194.233.65.230","port":"821","username":"itm","password":"56983466"}',
    'bible_name':
        '{"Perjanjian lama":{"b_kjv":"Old Testament","b_tb":"Perjanjian Lama","b_cuv":"舊約聖經"},"Perjanjian baru":{"b_kjv":"New Testament","b_tb":"Perjanjian Baru","b_cuv":"新約聖經"}}',
    'literature_panduan_alkitab':
        '[{"title":"Panduan Kitab Roma","img":"https://tjc.org/id/wp-content/uploads/sites/43/2020/04/cover-PA-Roma.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2020/04/Roma.pdf"}]',
    'bible_codename':
        '{"KJV":"King James Version","CUV":"Chinese Union Version","TB":"Terjemahan Baru"}',
    'notifikasi_sabat':
        '{"title":"Notifikasi Sabat","body":"Ingat dan Kuduskanlah Hari Sabat  ...  ","imageUrl":"https://tjc.org/wp-content/uploads/2016/05/tjclogo_english_680x88.png"}',
    'mailer_credentials':
        '{"username":"hatiku.app@gmail.com","password":"rjnsfeygekniyfil"}',
    'firebase_remote_config': '{"fetch_timeout":10,"fetch_interval":3600}',
    'sauhconfig': '',
    'enabled_music_code': '',
  };

  static void useFallbackConfig() {
    _useFallbackConfig = true;
  }

  static void complete(FirebaseRemoteConfig config) {
    _useFallbackConfig = false;
    if (!initialization.isCompleted) {
      initialization.complete(config);
    }
  }

  static String _fallbackString(String key) =>
      fallbackConfig[key]?.toString() ?? '';

  static Future<Map<String, dynamic>> jsonConfig(String key) async {
    try {
      if (_useFallbackConfig) {
        Map<String, dynamic> json = jsonDecode(_fallbackString(key));
        log(json.toString(), name: 'Get $key from fallback Remote Config');
        return json;
      }
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
      if (_useFallbackConfig) {
        List<dynamic> json = jsonDecode(_fallbackString(key));
        log(json.toString(), name: 'Get $key from fallback Remote Config');
        return json.map((e) => e as Map<String, dynamic>).toList();
      }
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
    if (_useFallbackConfig) {
      var jsonString = _fallbackString(key);
      log(jsonString, name: 'Get $key from fallback Remote Config');
      return jsonString;
    }
    var config = await initialization.future;
    var jsonString = config.getString(key);
    log(jsonString.toString(), name: 'Get $key from Remote Config');
    return jsonString;
  }

  static Future<bool> boolConfig(String key) async {
    if (_useFallbackConfig) {
      var value = _fallbackString(key).toLowerCase() == 'true';
      log(value.toString(), name: 'Get $key from fallback Remote Config');
      return value;
    }
    var config = await initialization.future;
    var jsonString = config.getBool(key);
    log(jsonString.toString(), name: 'Get $key from Remote Config');
    return jsonString;
  }

  static Future<Map> getAllConfigs() async {
    if (_useFallbackConfig) {
      return fallbackConfig;
    }
    var config = await initialization.future;
    return config.getAll();
  }
}


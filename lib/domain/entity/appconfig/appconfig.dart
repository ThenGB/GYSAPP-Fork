import 'package:freezed_annotation/freezed_annotation.dart';

part 'appconfig.freezed.dart';
part 'appconfig.g.dart';

@freezed
abstract class AppConfig with _$AppConfig {
  const AppConfig._();
  const factory AppConfig({
    required String appName,
    required String baseUrlApi,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
}


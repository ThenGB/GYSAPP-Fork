import 'package:freezed_annotation/freezed_annotation.dart';

part 'panduan_entity.freezed.dart';
part 'panduan_entity.g.dart';

@freezed
class Panduan with _$Panduan {
  const Panduan._();
  const factory Panduan({
    required String title,
    required String description,
    required String url,
    required String imageUrl,
  }) = _Panduan;

  factory Panduan.fromJson(Map<String, dynamic> json) =>
      _$PanduanFromJson(json);
}

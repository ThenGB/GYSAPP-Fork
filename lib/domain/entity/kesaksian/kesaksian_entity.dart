import 'package:freezed_annotation/freezed_annotation.dart';

part 'kesaksian_entity.freezed.dart';
part 'kesaksian_entity.g.dart';

@freezed
class Kesaksian with _$Kesaksian {
  const Kesaksian._();
  const factory Kesaksian({
    required String title,
    required String description,
    required String url,
    required String imageUrl,
  }) = _Kesaksian;

  factory Kesaksian.fromJson(Map<String, dynamic> json) =>
      _$KesaksianFromJson(json);
}

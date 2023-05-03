import 'package:freezed_annotation/freezed_annotation.dart';

part 'sauh_entity.freezed.dart';
part 'sauh_entity.g.dart';

@freezed
class Sauh with _$Sauh {
  const Sauh._();
  const factory Sauh({
    required String title,
    required String description,
    required String url,
    required String imageUrl,
  }) = _Sauh;

  factory Sauh.fromJson(Map<String, dynamic> json) => _$SauhFromJson(json);
}

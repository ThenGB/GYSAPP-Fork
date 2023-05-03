import 'package:freezed_annotation/freezed_annotation.dart';

part 'renungan_entity.freezed.dart';
part 'renungan_entity.g.dart';

@freezed
class Renungan with _$Renungan {
  const Renungan._();
  const factory Renungan({
    required String title,
    required String description,
    required String url,
    required String imageUrl,
  }) = _Renungan;

  factory Renungan.fromJson(Map<String, dynamic> json) =>
      _$RenunganFromJson(json);
}

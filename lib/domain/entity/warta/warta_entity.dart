import 'package:freezed_annotation/freezed_annotation.dart';

part 'warta_entity.freezed.dart';
part 'warta_entity.g.dart';

@freezed
abstract class Warta with _$Warta {
  const Warta._();
  const factory Warta({
    required String title,
    required String description,
    required String url,
    required String imageUrl,
  }) = _Warta;

  factory Warta.fromJson(Map<String, dynamic> json) => _$WartaFromJson(json);
}


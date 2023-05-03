import 'package:freezed_annotation/freezed_annotation.dart';

part 'truevoice_entity.freezed.dart';
part 'truevoice_entity.g.dart';

@freezed
class TrueVoice with _$TrueVoice {
  const TrueVoice._();
  const factory TrueVoice({
    required String title,
    required String description,
    required String url,
    required String imageUrl,
  }) = _TrueVoice;

  factory TrueVoice.fromJson(Map<String, dynamic> json) =>
      _$TrueVoiceFromJson(json);
}

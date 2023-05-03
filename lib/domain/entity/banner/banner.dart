import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

@freezed
class ImageBanner with _$ImageBanner {
  const ImageBanner._();
  const factory ImageBanner({
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'imageUrl') String? imageUrl,
    @JsonKey(name: 'linkUrl') String? linkUrl,
    @JsonKey(name: 'order') int? order,
    @JsonKey(name: 'title') String? title,
  }) = _ImageBanner;

  factory ImageBanner.fromJson(Map<String, dynamic> json) =>
      _$ImageBannerFromJson(json);
}

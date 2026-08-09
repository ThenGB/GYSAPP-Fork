import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/utilities/variables/assets.dart';

part 'menulink_entity.freezed.dart';
part 'menulink_entity.g.dart';

@freezed
abstract class Menulink with _$Menulink {
  const Menulink._();
  const factory Menulink({
    required String label,
    required String icon,
    required String url,
    required bool enabled,
  }) = _Menulink;

  factory Menulink.fromJson(Map<String, dynamic> json) =>
      _$MenulinkFromJson(json);

  bool get isNetworkIcon => icon.startsWith('http');
  bool get isAssetIcon => icon.startsWith('assets');
  bool get isFileIcon => icon.startsWith('file');

  ImageProvider get iconImageProvider {
    if (isNetworkIcon) {
      return NetworkImage(icon);
    } else if (isAssetIcon) {
      return AssetImage(icon);
    } else if (isFileIcon && !kIsWeb) {
      // dart:io File is unavailable on web — fall back to the app icon.
      return FileImage(File(icon));
    } else {
      return const AssetImage(Assets.assetsImagesAppicon);
    }
  }
}


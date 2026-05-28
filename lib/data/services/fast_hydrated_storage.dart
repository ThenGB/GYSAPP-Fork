// Conditional import: native gets dart:io version, web gets dart:html version
export 'fast_hydrated_storage_native.dart'
    if (dart.library.html) 'fast_hydrated_storage_web.dart';

import 'dart:io';

import '../../../di/injection.dart';

class AssetCacheMaintenanceService {
  AssetCacheMaintenanceService({required this.appDirectory});

  final AppDirectory appDirectory;

  Future<void> clearFastAccessCache() async {
    await _deleteDirectoryIfExists(Directory(appDirectory.preparedPdfFolder));
    await _deleteDirectoryIfExists(Directory(appDirectory.pdfNoteCacheFolder));
    await _deleteDirectoryIfExists(Directory(appDirectory.songRenderCacheFolder));
    await _deleteDirectoryIfExists(Directory(appDirectory.assetTempFolder));
    await _deleteDirectoryIfExists(Directory(appDirectory.encryptFolder));
  }

  Future<void> _deleteDirectoryIfExists(Directory directory) async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
// ignore: unused_import
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../domain/entity/data_summary/data_summary.dart';
import '../../domain/repository/backupsync_repository.dart';
import '../utilities/google_auth_client.dart';
import '../utilities/variables/failure.dart';

class BackupSyncRepositoryImpl implements BackupSyncRepository {
  final Dio dio;

  BackupSyncRepositoryImpl(this.dio);
  @override
  Future<Either<Failure, DataSummary>> getDataSummary() async {
    late DataSummary data;
    late Failure failure;
    bool hasError = false;
    try {
      final response = await dio.get('/data-summary');
      data = DataSummary.fromJson(response.data);
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }

  @override
  Future<Either<Failure, drive.File>> backupToDrive({
    required GoogleSignInAccount googleUser,
    required File file,
    String? fileId,
  }) async {
    try {
      Map<String, String> headers = await googleUser.authHeaders;
      GoogleAuthClient client = GoogleAuthClient(headers);
      var driveApi = drive.DriveApi(client);
      drive.File fileMetaData = drive.File();
      fileMetaData.name = 'egysbackup${path.extension(file.path)}';
      late drive.File response;
      if (fileId != null) {
        response = await driveApi.files.update(
          fileMetaData,
          fileId,
          uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
        );
      } else {
        fileMetaData.parents = ['appDataFolder'];
        response = await driveApi.files.create(
          fileMetaData,
          uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
        );
      }
      return Right(response);
    } catch (e) {
      return Left(Failure.fromError(e));
    }
  }

  @override
  Future<Either<Failure, File?>> syncFromDrive(
      {required GoogleSignInAccount googleUser}) async {
    drive.Media? selectedDriveFile;
    File? downloadedFile;
    try {
      Map<String, String> headers = await googleUser.authHeaders;
      GoogleAuthClient client = GoogleAuthClient(headers);
      var driveApi = drive.DriveApi(client);
      drive.FileList fileList = await driveApi.files.list(
          spaces: 'appDataFolder',
          $fields: 'files(id, name, modifiedTime, exportLinks, size)');
      List<drive.File>? files = fileList.files;
      drive.File? driveFile =
          files?.firstWhere((element) => element.name == 'egysbackup.gysbk');
      if (driveFile != null) {
        selectedDriveFile = await driveApi.files.get(driveFile.id!,
            downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      }
      Completer downloadCompleter = Completer();
      if (selectedDriveFile != null) {
        List<int> dataStore = [];
        selectedDriveFile.stream.listen((data) {
          dataStore.insertAll(dataStore.length, data);
        }, onDone: () async {
          Directory tempDir =
              await getTemporaryDirectory(); //Get temp folder using Path Provider
          String tempPath = tempDir.path; //Get path to that location
          downloadedFile = File('$tempPath/temp.gysbk'); //Create a dummy file
          downloadedFile!.createSync(recursive: true);
          await downloadedFile!.writeAsBytes(dataStore);

          downloadCompleter.complete();
        }, onError: (error) {
          downloadCompleter.completeError(error);
        });
      }
      await downloadCompleter.future;
      return Right(downloadedFile);
    } catch (e) {
      return Left(Failure.fromError(e));
    }
  }
}

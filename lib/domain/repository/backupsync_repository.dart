import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../../data/data.dart';
import '../domain.dart';

abstract class BackupSyncRepository {
  Future<Either<Failure, DataSummary>> getDataSummary();

  Future<Either<Failure, drive.File>> backupToDrive({
    required GoogleSignInAccount googleUser,
    required File file,
    String? fileId,
  });

  Future<Either<Failure, File?>> syncFromDrive(
      {required GoogleSignInAccount googleUser});
}

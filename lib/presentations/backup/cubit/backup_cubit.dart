import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart';

import '../../../data/data.dart';
import '../../../data/utilities/encrypt.dart';
import '../../../di/injection.dart';
import '../../../domain/domain.dart';
import 'backup_state.dart';

export 'backup_state.dart';

class BackupCubit extends HydratedCubit<BackupState> {
  BackupCubit(this.appDirectory, this.encryptData) : super(BackupState());
  final AppDirectory appDirectory;
  final EncryptData encryptData;

  @override
  BackupState? fromJson(Map<String, dynamic> json) {
    return BackupState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(BackupState state) {
    return state.toJson();
  }

  Future<void> getDataSummary() async {
    // final response = await repository.getDataSummary();
  }

  Future<void> startBackup({
    required Future<bool> Function() promptSaveToLocal,
  }) async {
    Map<String, dynamic> data = state.appBackupData!.toJson();
    String folder = appDirectory.backupFolder;
    File backupJson = File(
      '$folder/${DateTime.now().millisecondsSinceEpoch ~/ 100}.gysbk',
    )..createSync(recursive: true);
    await backupJson.writeAsString(jsonEncode(data));
    var tempEncrypted = await encryptData.encryptFile(backupJson);
    await backupJson.writeAsBytes(await tempEncrypted.readAsBytes());
    if (await promptSaveToLocal()) {
      String? saveFolder = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select a folder to save the data',
      );
      if (saveFolder != null) {
        var savePath = '$saveFolder/${basename(backupJson.path)}';
        File saveFile = File(savePath)..createSync(recursive: true);
        await saveFile.writeAsBytes(await backupJson.readAsBytes());
        Fluttertoast.showToast(msg: 'Sukses');
      }
    }
  }

  Future<File?> backupToLocal() async {
    Map<String, dynamic> data = state.appBackupData!.toJson();
    String folder = appDirectory.backupFolder;
    File backupJson = File(
      '$folder/${DateTime.now().millisecondsSinceEpoch ~/ 100}.gysbk',
    )..createSync(recursive: true);
    await backupJson.writeAsString(jsonEncode(data));
    var tempEncrypted = await encryptData.encryptFile(backupJson);
    await backupJson.writeAsBytes(await tempEncrypted.readAsBytes());

    String? saveFolder = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select a folder to save the data',
    );
    if (saveFolder != null) {
      var savePath = '$saveFolder/${basename(backupJson.path)}';
      File saveFile = File(savePath)..createSync(recursive: true);
      await saveFile.writeAsBytes(await backupJson.readAsBytes());
      Fluttertoast.showToast(msg: 'Sukses');
      return saveFile;
    }
    return null;
  }

  Future<void> syncFromFile({
    required Function(AppBackupData data) onLoaded,
  }) async {
    try {
      FilePickerResult? pickedFile = (await FilePicker.pickFiles(
        allowMultiple: false,
      ));
      if (pickedFile == null) return;
      if (pickedFile.files.singleOrNull == null) return;
      File localFile = File(pickedFile.files.single.path!);
      File decryptedFile = await encryptData.decryptFile(localFile);
      var data = await decryptedFile.readAsString();
      AppBackupData backupData = AppBackupData.fromJson(jsonDecode(data));
      onLoaded(backupData);
    } catch (e) {
      Fluttertoast.showToast(msg: Failure.fromError(e).message);
    }
  }

  void initLocalData(AppBackupData data) {
    String bibleNotesSummary =
        '${data.bibleState?.notes.length ?? 0} notes on bible';
    String bibleBookmarks =
        '${data.bibleState?.bookmarks.length ?? 0} bookmarks on bible';
    emit(
      state.copyWith(
        localDataSummary: [bibleNotesSummary, bibleBookmarks],
        appBackupData: data,
      ),
    );
  }

  void resetToDefaults() {
    emit(BackupState());
  }
}

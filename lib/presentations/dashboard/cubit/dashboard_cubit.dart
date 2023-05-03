import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:church/di/injection.dart';
import 'package:church/domain/entity/config_literature/config_literature_entity.dart';
import 'package:church/presentations/dashboard/cubit/dashboard_state.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class DashboardCubit extends HydratedCubit<DashboardState> {
  DashboardCubit() : super(const DashboardState()) {
    initRemoteConfig().then((value) {
      if (state.ftpHost == null) {
        emit(state.copyWith(isError: true));
        return;
      }
      Future.delayed(const Duration(seconds: 1)).then((value) async {
        await syncBible();
      });
    });
  }

  FTPConnect? ftp;

  Future<List<String>> syncBible() async {
    List<String> files = [];
    emit(state.copyWith(isSyncing: true, message: null));
    AppDirectory localDir = di();
    try {
      var connection = ftp!;
      await connection.connect();
      await connection.changeDirectory(state.biblePath);
      await Future.delayed(const Duration(seconds: 1));
      var contents = await connection.listDirectoryContent();
      for (var content in contents) {
        var file = File('${localDir.bibleFolder}/${content.name}');
        var difference = content.modifyTime
                ?.difference(
                    state.lastSync ?? content.modifyTime ?? DateTime.now())
                .inDays ??
            0;
        if (difference.isNegative && file.existsSync()) {
          files.add(file.path);
          continue;
        }
        if (!file.existsSync()) {
          file.createSync(recursive: true);
        }
        var downloaded = await connection.downloadFile(
          content.name,
          file,
          onProgress: (progressInPercent, totalReceived, fileSize) {
            log('progress: $progressInPercent, total: $totalReceived, fileSize: $fileSize');
            emit(state.copyWith(
                message:
                    'Downloading ${content.name.split('.').first} $progressInPercent%'));
          },
        );
        log('Downloaded $downloaded ');
        files.add(file.path);
      }
      await connection.disconnect();
      emit(state.copyWith(lastSync: DateTime.now()));
    } catch (e) {
      log(e.toString());
    }
    emit(state.copyWith(isSyncing: false));
    return files;
  }

  setPaths() {
    var biblepath = FirebaseRemoteConfig.instance.getString('biblepath');
    emit(state.copyWith(
        biblePath:
            biblepath.isEmpty ? '/Project/Hatiku/v2/alkitab' : biblepath));
  }

  Future setFtpConnect() async {
    var jsonString = FirebaseRemoteConfig.instance.getString('ftp_server');

    var json = jsonDecode(jsonString);
    emit(state.copyWith(
      ftpHost: json['host'],
      ftpPort: json['port'],
      ftpUsername: json['username'],
      ftpPassword: json['password'],
    ));
    await ftp?.disconnect();
    ftp = FTPConnect(
      state.ftpHost!,
      port: int.parse(state.ftpPort!),
      user: state.ftpUsername!,
      pass: state.ftpPassword!,
    );
  }

  setConfigLiterature() {
    try {
      var jsonString =
          FirebaseRemoteConfig.instance.getString('config_literature');

      var json = jsonDecode(jsonString.isEmpty ? '{}' : jsonString);
      emit(state.copyWith(configLiterature: ConfigLiterature.fromJson(json)));
    } catch (e) {
      log(e.toString());
    }
  }

  Future initRemoteConfig() async {
    emit(state.copyWith(isLoading: true));
    try {
      FirebaseRemoteConfig.instance.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(seconds: 10),
        ),
      );
      log((await FirebaseRemoteConfig.instance.fetchAndActivate()).toString(),
          name: '[Firebase remote config]');
      log(FirebaseRemoteConfig.instance.getAll().toString(),
          name: 'Remote Config');
      await setFtpConnect();
      setPaths();
      setConfigLiterature();
    } catch (e) {
      log(e.toString());
    }
    emit(state.copyWith(isLoading: false));
  }

  @override
  DashboardState? fromJson(Map<String, dynamic> json) {
    return DashboardState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(DashboardState state) {
    return state.toJson();
  }
}

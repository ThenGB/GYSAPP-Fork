import 'dart:developer';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ftpconnect/ftpconnect.dart';
// ignore: implementation_imports
import 'package:ftpconnect/src/ftp_entry.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart';

import '../../../data/utilities/firebase_utils.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/config_literature/config_literature_entity.dart';
import '../../../domain/repository/account_repository.dart';
import 'dashboard_state.dart';

export 'dashboard_state.dart';

class DashboardCubit extends HydratedCubit<DashboardState> {
  final AccountRepository accountRepository;
  DashboardCubit(this.accountRepository) : super(const DashboardState()) {
    initRemoteConfig().then((value) {
      if (state.ftpHost == null) {
        emit(state.copyWith(isError: true));
        return;
      }
      // Future.delayed(const Duration(seconds: 1)).then((value) async {
      //   await syncBible();
      // });
    });
  }

  Future loginSuccessCallback(String? token) async {
    emit(state.copyWith(idToken: token));
    if (token != null) {
      await getProfile(token);
    } else {
      emit(state.copyWith(account: null));
    }
  }

  Future getProfile(String token) async {
    final response = await accountRepository.getProfile(token);
    response.fold(
      (failure) {
        emit(state.copyWith(idToken: null, account: null));
      },
      (res) {
        emit(state.copyWith(account: res));
      },
    );
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
        // _File (File: '/data/user/0/com.itmandiri.egys/cache/bible/b_tb.db')
        var difference = content.modifyTime
                ?.difference(
                  state.lastSync[content.name] ??
                      content.modifyTime ??
                      DateTime.now(),
                )
                .inDays ??
            0;
        if (difference.isNegative && file.existsSync()) {
          files.add(file.path);
          continue;
        }
        if (!file.existsSync()) {
          // continue;
          file.createSync(
              recursive: true); // diubah, karena tidak download otomatis lagi
        }
        var downloaded = await connection.downloadFile(
          content.name,
          file,
          onProgress: (progressInPercent, totalReceived, fileSize) {
            log('progress: $progressInPercent, total: $totalReceived, fileSize: $fileSize',
                name: 'Downloading bible');
            emit(state.copyWith(
                message:
                    'Downloading ${content.name.split('.').first} $progressInPercent%'));
          },
        );
        log('Downloaded $downloaded ');
        files.add(file.path);
      }
      await connection.disconnect();
    } catch (e) {
      log(e.toString());
    }
    emit(state.copyWith(isSyncing: false));
    return files;
  }

  bool isListing = false;
  List<FTPEntry> lastContent = [];

  Future<List<FTPEntry>> listNetworkBibles(bool reload) async {
    try {
      if (isListing || reload) {
        return lastContent;
      }
      isListing = true;
      await ftp!.connect();
      await Future.delayed(const Duration(seconds: 1));
      await ftp!.changeDirectory(state.biblePath);
      await Future.delayed(const Duration(seconds: 1));
      var contents = await ftp!.listDirectoryContent();
      await Future.delayed(const Duration(seconds: 1));
      await ftp!.disconnect();
      await Future.delayed(const Duration(seconds: 1));
      lastContent = List.from(contents);
      return contents;
    } catch (e) {
      ftp!.disconnect();
      if (e is FTPConnectException) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: e.message);
      }
      return Future.error("Can't connect to the network");
    } finally {
      isListing = false;
    }
  }

  Future<bool> downloadBible(
      String sRemoteName,
      File fFile,
      Function(double progressInPercent, int totalReceived, int fileSize)
          onProgress) async {
    try {
      await ftp!.connect();
      await ftp!.changeDirectory(state.biblePath);
      var downloaded =
          await ftp!.downloadFile(sRemoteName, fFile, onProgress: onProgress);
      await ftp!.disconnect();
      if (downloaded) {
        Map<String, DateTime> lastSync = Map.from(state.lastSync);
        lastSync[basename(sRemoteName)] = DateTime.now();
        emit(state.copyWith(lastSync: lastSync));
      }
      return downloaded;
    } catch (e) {
      await ftp!.disconnect();
      return false;
    }
  }

  setPaths() async {
    var biblepath = await FirebaseUtils.stringConfig('biblepath');
    emit(
      state.copyWith(
        biblePath: biblepath.isEmpty ? '/Project/Hatiku/v2/alkitab' : biblepath,
      ),
    );
  }

  Future setFtpConnect() async {
    var json = await FirebaseUtils.jsonConfig('ftp_server');
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

  setConfigLiterature() async {
    try {
      var json = await FirebaseUtils.jsonConfig('config_literature');
      emit(state.copyWith(configLiterature: ConfigLiterature.fromJson(json)));
    } catch (e) {
      log(e.toString());
    }
  }

  Future initRemoteConfig() async {
    emit(state.copyWith(isLoading: true));
    try {
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

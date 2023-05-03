import 'dart:convert';
import 'dart:developer';

import 'package:church/domain/entity/config_literature/config_literature_entity.dart';
import 'package:church/domain/repository/scrapper_repository.dart';
import 'package:church/presentations/literature/cubit/panduan/literature_panduan_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

export 'literature_panduan_state.dart';

class LiteraturePanduanCubit extends HydratedCubit<LiteraturePanduanState> {
  final ScrapperRepository repository;

  LiteraturePanduanCubit(this.repository)
      : super(const LiteraturePanduanState()) {
    var jsonString =
        FirebaseRemoteConfig.instance.getString('config_literature');
    var json = jsonDecode(jsonString.isEmpty ? '{}' : jsonString);
    selector = ConfigLiterature.fromJson(json).panduanAlkitab;
    getData();
  }

  late String selector;
  @override
  LiteraturePanduanState? fromJson(Map<String, dynamic> json) {
    return LiteraturePanduanState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(LiteraturePanduanState state) {
    return state.toJson();
  }

  getData() async {
    emit(state.copyWith(isLoading: true));
    var response = await repository.getPanduan(selector);
    emit(state.copyWith(isLoading: false));
    response.fold(
      (failure) {
        log(failure.message);
      },
      (res) {
        if (state.items.isNotEmpty) {
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: 'Refreshed'.tr(),
            gravity: ToastGravity.TOP,
          );
        }
        log(res.length.toString());
        if (res.isNotEmpty) {
          emit(state.copyWith(items: res));
        }
      },
    );
  }
}

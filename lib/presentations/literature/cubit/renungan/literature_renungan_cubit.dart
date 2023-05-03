import 'dart:convert';
import 'dart:developer';

import 'package:church/domain/entity/config_literature/config_literature_entity.dart';
import 'package:church/domain/repository/scrapper_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'literature_renungan_state.dart';

export 'literature_renungan_state.dart';

class LiteratureRenunganCubit extends HydratedCubit<LiteratureRenunganState> {
  final ScrapperRepository repository;

  LiteratureRenunganCubit(this.repository)
      : super(const LiteratureRenunganState()) {
    var jsonString =
        FirebaseRemoteConfig.instance.getString('config_literature');
    var json = jsonDecode(jsonString.isEmpty ? '{}' : jsonString);
    selector = ConfigLiterature.fromJson(json).pelitaKecil;
    getData();
  }

  late String selector;
  @override
  LiteratureRenunganState? fromJson(Map<String, dynamic> json) {
    return LiteratureRenunganState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(LiteratureRenunganState state) {
    return state.toJson();
  }

  getData() async {
    emit(state.copyWith(isLoading: true));
    var response = await repository.getRenungan(selector);
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

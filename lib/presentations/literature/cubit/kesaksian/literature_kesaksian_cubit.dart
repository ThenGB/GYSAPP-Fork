import 'dart:convert';
import 'dart:developer';

import 'package:church/domain/entity/config_literature/config_literature_entity.dart';
import 'package:church/domain/repository/scrapper_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'literature_kesaksian_state.dart';

export 'literature_kesaksian_state.dart';

class LiteratureKesaksianCubit extends HydratedCubit<LiteratureKesaksianState> {
  LiteratureKesaksianCubit(this.repository)
      : super(const LiteratureKesaksianState()) {
    var jsonString =
        FirebaseRemoteConfig.instance.getString('config_literature');
    var json = jsonDecode(jsonString.isEmpty ? '{}' : jsonString);
    selector = ConfigLiterature.fromJson(json).kesaksian;
    getData();
  }
  late String selector;
  final ScrapperRepository repository;

  @override
  LiteratureKesaksianState? fromJson(Map<String, dynamic> json) {
    return LiteratureKesaksianState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(LiteratureKesaksianState state) {
    return state.toJson();
  }

  getData() async {
    emit(state.copyWith(isLoading: true));
    var response = await repository.getKesaksian(selector);
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

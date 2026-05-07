import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../data/utilities/firebase_utils.dart';
import '../../../../domain/entity/config_literature/config_literature_entity.dart';
import '../../../../domain/repository/scrapper_repository.dart';
import 'literature_warta_state.dart';

export 'literature_warta_state.dart';

class LiteratureWartaCubit extends HydratedCubit<LiteratureWartaState> {
  final ScrapperRepository repository;

  LiteratureWartaCubit(this.repository) : super(const LiteratureWartaState()) {
    FirebaseUtils.jsonConfig('config_literature').then((json) {
      selector = ConfigLiterature.fromJson(json).kesaksian;
      getData();
    });
  }
  late String selector;
  @override
  LiteratureWartaState? fromJson(Map<String, dynamic> json) {
    return LiteratureWartaState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(LiteratureWartaState state) {
    return state.toJson();
  }

  Future<void> getData() async {
    emit(state.copyWith(isLoading: true));
    var response = await repository.getWarta(selector);
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


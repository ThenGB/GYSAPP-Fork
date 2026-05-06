import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../data/utilities/firebase_utils.dart';
import '../../../../domain/entity/config_literature/config_literature_entity.dart';
import '../../../../domain/repository/scrapper_repository.dart';
import 'literature_kesaksian_state.dart';

export 'literature_kesaksian_state.dart';

class LiteratureKesaksianCubit extends HydratedCubit<LiteratureKesaksianState> {
  LiteratureKesaksianCubit(this.repository)
      : super(const LiteratureKesaksianState()) {
    FirebaseUtils.jsonConfig('config_literature').then((json) {
      selector = ConfigLiterature.fromJson(json).kesaksian;
      getData();
    });
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

  Future<void> getData() async {
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

import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'report_state.dart';

export 'report_state.dart';

class ReportCubit extends HydratedCubit<ReportState> {
  ReportCubit() : super(ReportState());

  @override
  ReportState? fromJson(Map<String, dynamic> json) {
    return ReportState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(ReportState state) {
    return state.toJson();
  }

  Future<void> sendReport() async {}
}

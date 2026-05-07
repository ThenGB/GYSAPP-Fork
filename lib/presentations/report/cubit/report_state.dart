import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_state.freezed.dart';
part 'report_state.g.dart';

@freezed
abstract class ReportState with _$ReportState {
  const ReportState._();
  const factory ReportState({
    @Default(false) bool isLoading,
  }) = _ReportState;

  factory ReportState.fromJson(Map<String, dynamic> json) =>
      _$ReportStateFromJson(json);
}


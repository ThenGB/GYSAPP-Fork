import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_summary.freezed.dart';
part 'data_summary.g.dart';

@freezed
class DataSummary with _$DataSummary {
  const DataSummary._();
  const factory DataSummary({
    @JsonKey(name: 'values') @Default([]) List<String> values,
  }) = _DataSummary;

  factory DataSummary.fromJson(Map<String, dynamic> json) =>
      _$DataSummaryFromJson(json);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DataSummary _$DataSummaryFromJson(Map<String, dynamic> json) {
  return _DataSummary.fromJson(json);
}

/// @nodoc
mixin _$DataSummary {
  @JsonKey(name: 'values')
  List<String> get values => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DataSummaryCopyWith<DataSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataSummaryCopyWith<$Res> {
  factory $DataSummaryCopyWith(
          DataSummary value, $Res Function(DataSummary) then) =
      _$DataSummaryCopyWithImpl<$Res, DataSummary>;
  @useResult
  $Res call({@JsonKey(name: 'values') List<String> values});
}

/// @nodoc
class _$DataSummaryCopyWithImpl<$Res, $Val extends DataSummary>
    implements $DataSummaryCopyWith<$Res> {
  _$DataSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? values = null,
  }) {
    return _then(_value.copyWith(
      values: null == values
          ? _value.values
          : values // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DataSummaryCopyWith<$Res>
    implements $DataSummaryCopyWith<$Res> {
  factory _$$_DataSummaryCopyWith(
          _$_DataSummary value, $Res Function(_$_DataSummary) then) =
      __$$_DataSummaryCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'values') List<String> values});
}

/// @nodoc
class __$$_DataSummaryCopyWithImpl<$Res>
    extends _$DataSummaryCopyWithImpl<$Res, _$_DataSummary>
    implements _$$_DataSummaryCopyWith<$Res> {
  __$$_DataSummaryCopyWithImpl(
      _$_DataSummary _value, $Res Function(_$_DataSummary) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? values = null,
  }) {
    return _then(_$_DataSummary(
      values: null == values
          ? _value._values
          : values // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DataSummary extends _DataSummary {
  const _$_DataSummary(
      {@JsonKey(name: 'values') final List<String> values = const []})
      : _values = values,
        super._();

  factory _$_DataSummary.fromJson(Map<String, dynamic> json) =>
      _$$_DataSummaryFromJson(json);

  final List<String> _values;
  @override
  @JsonKey(name: 'values')
  List<String> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

  @override
  String toString() {
    return 'DataSummary(values: $values)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DataSummary &&
            const DeepCollectionEquality().equals(other._values, _values));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_values));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DataSummaryCopyWith<_$_DataSummary> get copyWith =>
      __$$_DataSummaryCopyWithImpl<_$_DataSummary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DataSummaryToJson(
      this,
    );
  }
}

abstract class _DataSummary extends DataSummary {
  const factory _DataSummary(
      {@JsonKey(name: 'values') final List<String> values}) = _$_DataSummary;
  const _DataSummary._() : super._();

  factory _DataSummary.fromJson(Map<String, dynamic> json) =
      _$_DataSummary.fromJson;

  @override
  @JsonKey(name: 'values')
  List<String> get values;
  @override
  @JsonKey(ignore: true)
  _$$_DataSummaryCopyWith<_$_DataSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

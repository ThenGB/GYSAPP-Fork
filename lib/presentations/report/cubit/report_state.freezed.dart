// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ReportState _$ReportStateFromJson(Map<String, dynamic> json) {
  return _ReportState.fromJson(json);
}

/// @nodoc
mixin _$ReportState {
  bool get isLoading => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReportStateCopyWith<ReportState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportStateCopyWith<$Res> {
  factory $ReportStateCopyWith(
          ReportState value, $Res Function(ReportState) then) =
      _$ReportStateCopyWithImpl<$Res, ReportState>;
  @useResult
  $Res call({bool isLoading});
}

/// @nodoc
class _$ReportStateCopyWithImpl<$Res, $Val extends ReportState>
    implements $ReportStateCopyWith<$Res> {
  _$ReportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportStateImplCopyWith<$Res>
    implements $ReportStateCopyWith<$Res> {
  factory _$$ReportStateImplCopyWith(
          _$ReportStateImpl value, $Res Function(_$ReportStateImpl) then) =
      __$$ReportStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading});
}

/// @nodoc
class __$$ReportStateImplCopyWithImpl<$Res>
    extends _$ReportStateCopyWithImpl<$Res, _$ReportStateImpl>
    implements _$$ReportStateImplCopyWith<$Res> {
  __$$ReportStateImplCopyWithImpl(
      _$ReportStateImpl _value, $Res Function(_$ReportStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
  }) {
    return _then(_$ReportStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportStateImpl extends _ReportState {
  const _$ReportStateImpl({this.isLoading = false}) : super._();

  factory _$ReportStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'ReportState(isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, isLoading);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportStateImplCopyWith<_$ReportStateImpl> get copyWith =>
      __$$ReportStateImplCopyWithImpl<_$ReportStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportStateImplToJson(
      this,
    );
  }
}

abstract class _ReportState extends ReportState {
  const factory _ReportState({final bool isLoading}) = _$ReportStateImpl;
  const _ReportState._() : super._();

  factory _ReportState.fromJson(Map<String, dynamic> json) =
      _$ReportStateImpl.fromJson;

  @override
  bool get isLoading;
  @override
  @JsonKey(ignore: true)
  _$$ReportStateImplCopyWith<_$ReportStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

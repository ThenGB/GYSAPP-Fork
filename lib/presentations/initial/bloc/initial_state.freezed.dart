// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'initial_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

InitialState _$InitialStateFromJson(Map<String, dynamic> json) {
  return _InitialState.fromJson(json);
}

/// @nodoc
mixin _$InitialState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoaded => throw _privateConstructorUsedError;
  bool get isFailed => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  bool get isFreshInstall => throw _privateConstructorUsedError;
  String get themeMode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InitialStateCopyWith<InitialState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InitialStateCopyWith<$Res> {
  factory $InitialStateCopyWith(
          InitialState value, $Res Function(InitialState) then) =
      _$InitialStateCopyWithImpl<$Res, InitialState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isLoaded,
      bool isFailed,
      String message,
      bool isFreshInstall,
      String themeMode});
}

/// @nodoc
class _$InitialStateCopyWithImpl<$Res, $Val extends InitialState>
    implements $InitialStateCopyWith<$Res> {
  _$InitialStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoaded = null,
    Object? isFailed = null,
    Object? message = null,
    Object? isFreshInstall = null,
    Object? themeMode = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoaded: null == isLoaded
          ? _value.isLoaded
          : isLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
      isFailed: null == isFailed
          ? _value.isFailed
          : isFailed // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isFreshInstall: null == isFreshInstall
          ? _value.isFreshInstall
          : isFreshInstall // ignore: cast_nullable_to_non_nullable
              as bool,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InitialStateCopyWith<$Res>
    implements $InitialStateCopyWith<$Res> {
  factory _$$_InitialStateCopyWith(
          _$_InitialState value, $Res Function(_$_InitialState) then) =
      __$$_InitialStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isLoaded,
      bool isFailed,
      String message,
      bool isFreshInstall,
      String themeMode});
}

/// @nodoc
class __$$_InitialStateCopyWithImpl<$Res>
    extends _$InitialStateCopyWithImpl<$Res, _$_InitialState>
    implements _$$_InitialStateCopyWith<$Res> {
  __$$_InitialStateCopyWithImpl(
      _$_InitialState _value, $Res Function(_$_InitialState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoaded = null,
    Object? isFailed = null,
    Object? message = null,
    Object? isFreshInstall = null,
    Object? themeMode = null,
  }) {
    return _then(_$_InitialState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoaded: null == isLoaded
          ? _value.isLoaded
          : isLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
      isFailed: null == isFailed
          ? _value.isFailed
          : isFailed // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isFreshInstall: null == isFreshInstall
          ? _value.isFreshInstall
          : isFreshInstall // ignore: cast_nullable_to_non_nullable
              as bool,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_InitialState extends _InitialState {
  const _$_InitialState(
      {this.isLoading = false,
      this.isLoaded = false,
      this.isFailed = false,
      this.message = '',
      this.isFreshInstall = true,
      this.themeMode = 'light'})
      : super._();

  factory _$_InitialState.fromJson(Map<String, dynamic> json) =>
      _$$_InitialStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoaded;
  @override
  @JsonKey()
  final bool isFailed;
  @override
  @JsonKey()
  final String message;
  @override
  @JsonKey()
  final bool isFreshInstall;
  @override
  @JsonKey()
  final String themeMode;

  @override
  String toString() {
    return 'InitialState(isLoading: $isLoading, isLoaded: $isLoaded, isFailed: $isFailed, message: $message, isFreshInstall: $isFreshInstall, themeMode: $themeMode)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InitialState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoaded, isLoaded) ||
                other.isLoaded == isLoaded) &&
            (identical(other.isFailed, isFailed) ||
                other.isFailed == isFailed) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isFreshInstall, isFreshInstall) ||
                other.isFreshInstall == isFreshInstall) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isLoaded, isFailed,
      message, isFreshInstall, themeMode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InitialStateCopyWith<_$_InitialState> get copyWith =>
      __$$_InitialStateCopyWithImpl<_$_InitialState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InitialStateToJson(
      this,
    );
  }
}

abstract class _InitialState extends InitialState {
  const factory _InitialState(
      {final bool isLoading,
      final bool isLoaded,
      final bool isFailed,
      final String message,
      final bool isFreshInstall,
      final String themeMode}) = _$_InitialState;
  const _InitialState._() : super._();

  factory _InitialState.fromJson(Map<String, dynamic> json) =
      _$_InitialState.fromJson;

  @override
  bool get isLoading;
  @override
  bool get isLoaded;
  @override
  bool get isFailed;
  @override
  String get message;
  @override
  bool get isFreshInstall;
  @override
  String get themeMode;
  @override
  @JsonKey(ignore: true)
  _$$_InitialStateCopyWith<_$_InitialState> get copyWith =>
      throw _privateConstructorUsedError;
}

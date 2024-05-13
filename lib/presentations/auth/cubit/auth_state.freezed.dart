// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AuthState _$AuthStateFromJson(Map<String, dynamic> json) {
  return _AuthState.fromJson(json);
}

/// @nodoc
mixin _$AuthState {
  String? get idToken => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  int get progress => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthStateCopyWith<AuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
  @useResult
  $Res call({String? idToken, bool isLoading, int progress});
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idToken = freezed,
    Object? isLoading = null,
    Object? progress = null,
  }) {
    return _then(_value.copyWith(
      idToken: freezed == idToken
          ? _value.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthStateImplCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$$AuthStateImplCopyWith(
          _$AuthStateImpl value, $Res Function(_$AuthStateImpl) then) =
      __$$AuthStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? idToken, bool isLoading, int progress});
}

/// @nodoc
class __$$AuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthStateImpl>
    implements _$$AuthStateImplCopyWith<$Res> {
  __$$AuthStateImplCopyWithImpl(
      _$AuthStateImpl _value, $Res Function(_$AuthStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idToken = freezed,
    Object? isLoading = null,
    Object? progress = null,
  }) {
    return _then(_$AuthStateImpl(
      idToken: freezed == idToken
          ? _value.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthStateImpl extends _AuthState {
  const _$AuthStateImpl(
      {this.idToken, this.isLoading = false, this.progress = 0})
      : super._();

  factory _$AuthStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthStateImplFromJson(json);

  @override
  final String? idToken;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final int progress;

  @override
  String toString() {
    return 'AuthState(idToken: $idToken, isLoading: $isLoading, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthStateImpl &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, idToken, isLoading, progress);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      __$$AuthStateImplCopyWithImpl<_$AuthStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthStateImplToJson(
      this,
    );
  }
}

abstract class _AuthState extends AuthState {
  const factory _AuthState(
      {final String? idToken,
      final bool isLoading,
      final int progress}) = _$AuthStateImpl;
  const _AuthState._() : super._();

  factory _AuthState.fromJson(Map<String, dynamic> json) =
      _$AuthStateImpl.fromJson;

  @override
  String? get idToken;
  @override
  bool get isLoading;
  @override
  int get progress;
  @override
  @JsonKey(ignore: true)
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

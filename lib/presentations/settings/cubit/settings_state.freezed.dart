// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) {
  return _SettingsState.fromJson(json);
}

/// @nodoc
mixin _$SettingsState {
  bool get isSabatNotificationActive => throw _privateConstructorUsedError;
  bool get isBibleReminderNotificationActive =>
      throw _privateConstructorUsedError;
  Map<int, DateTime> get bibleReminders => throw _privateConstructorUsedError;

  /// Serializes this SettingsState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) then) =
      _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call(
      {bool isSabatNotificationActive,
      bool isBibleReminderNotificationActive,
      Map<int, DateTime> bibleReminders});
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSabatNotificationActive = null,
    Object? isBibleReminderNotificationActive = null,
    Object? bibleReminders = null,
  }) {
    return _then(_value.copyWith(
      isSabatNotificationActive: null == isSabatNotificationActive
          ? _value.isSabatNotificationActive
          : isSabatNotificationActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isBibleReminderNotificationActive: null ==
              isBibleReminderNotificationActive
          ? _value.isBibleReminderNotificationActive
          : isBibleReminderNotificationActive // ignore: cast_nullable_to_non_nullable
              as bool,
      bibleReminders: null == bibleReminders
          ? _value.bibleReminders
          : bibleReminders // ignore: cast_nullable_to_non_nullable
              as Map<int, DateTime>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
          _$SettingsStateImpl value, $Res Function(_$SettingsStateImpl) then) =
      __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSabatNotificationActive,
      bool isBibleReminderNotificationActive,
      Map<int, DateTime> bibleReminders});
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
      _$SettingsStateImpl _value, $Res Function(_$SettingsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSabatNotificationActive = null,
    Object? isBibleReminderNotificationActive = null,
    Object? bibleReminders = null,
  }) {
    return _then(_$SettingsStateImpl(
      isSabatNotificationActive: null == isSabatNotificationActive
          ? _value.isSabatNotificationActive
          : isSabatNotificationActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isBibleReminderNotificationActive: null ==
              isBibleReminderNotificationActive
          ? _value.isBibleReminderNotificationActive
          : isBibleReminderNotificationActive // ignore: cast_nullable_to_non_nullable
              as bool,
      bibleReminders: null == bibleReminders
          ? _value._bibleReminders
          : bibleReminders // ignore: cast_nullable_to_non_nullable
              as Map<int, DateTime>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingsStateImpl extends _SettingsState {
  const _$SettingsStateImpl(
      {this.isSabatNotificationActive = false,
      this.isBibleReminderNotificationActive = false,
      final Map<int, DateTime> bibleReminders = const {}})
      : _bibleReminders = bibleReminders,
        super._();

  factory _$SettingsStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isSabatNotificationActive;
  @override
  @JsonKey()
  final bool isBibleReminderNotificationActive;
  final Map<int, DateTime> _bibleReminders;
  @override
  @JsonKey()
  Map<int, DateTime> get bibleReminders {
    if (_bibleReminders is EqualUnmodifiableMapView) return _bibleReminders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bibleReminders);
  }

  @override
  String toString() {
    return 'SettingsState(isSabatNotificationActive: $isSabatNotificationActive, isBibleReminderNotificationActive: $isBibleReminderNotificationActive, bibleReminders: $bibleReminders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.isSabatNotificationActive,
                    isSabatNotificationActive) ||
                other.isSabatNotificationActive == isSabatNotificationActive) &&
            (identical(other.isBibleReminderNotificationActive,
                    isBibleReminderNotificationActive) ||
                other.isBibleReminderNotificationActive ==
                    isBibleReminderNotificationActive) &&
            const DeepCollectionEquality()
                .equals(other._bibleReminders, _bibleReminders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSabatNotificationActive,
      isBibleReminderNotificationActive,
      const DeepCollectionEquality().hash(_bibleReminders));

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsStateImplToJson(
      this,
    );
  }
}

abstract class _SettingsState extends SettingsState {
  const factory _SettingsState(
      {final bool isSabatNotificationActive,
      final bool isBibleReminderNotificationActive,
      final Map<int, DateTime> bibleReminders}) = _$SettingsStateImpl;
  const _SettingsState._() : super._();

  factory _SettingsState.fromJson(Map<String, dynamic> json) =
      _$SettingsStateImpl.fromJson;

  @override
  bool get isSabatNotificationActive;
  @override
  bool get isBibleReminderNotificationActive;
  @override
  Map<int, DateTime> get bibleReminders;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

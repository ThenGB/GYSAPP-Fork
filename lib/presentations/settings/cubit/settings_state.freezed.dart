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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) {
  return _SettingsState.fromJson(json);
}

/// @nodoc
mixin _$SettingsState {
  bool get isSabatNotificationActive => throw _privateConstructorUsedError;
  bool get isBibleReminderNotificationActive =>
      throw _privateConstructorUsedError;
  Map<int, DateTime> get bibleReminders => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
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
abstract class _$$_SettingsStateCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$_SettingsStateCopyWith(
          _$_SettingsState value, $Res Function(_$_SettingsState) then) =
      __$$_SettingsStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSabatNotificationActive,
      bool isBibleReminderNotificationActive,
      Map<int, DateTime> bibleReminders});
}

/// @nodoc
class __$$_SettingsStateCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$_SettingsState>
    implements _$$_SettingsStateCopyWith<$Res> {
  __$$_SettingsStateCopyWithImpl(
      _$_SettingsState _value, $Res Function(_$_SettingsState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSabatNotificationActive = null,
    Object? isBibleReminderNotificationActive = null,
    Object? bibleReminders = null,
  }) {
    return _then(_$_SettingsState(
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
class _$_SettingsState extends _SettingsState {
  const _$_SettingsState(
      {this.isSabatNotificationActive = false,
      this.isBibleReminderNotificationActive = false,
      final Map<int, DateTime> bibleReminders = const {}})
      : _bibleReminders = bibleReminders,
        super._();

  factory _$_SettingsState.fromJson(Map<String, dynamic> json) =>
      _$$_SettingsStateFromJson(json);

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SettingsState &&
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

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSabatNotificationActive,
      isBibleReminderNotificationActive,
      const DeepCollectionEquality().hash(_bibleReminders));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SettingsStateCopyWith<_$_SettingsState> get copyWith =>
      __$$_SettingsStateCopyWithImpl<_$_SettingsState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SettingsStateToJson(
      this,
    );
  }
}

abstract class _SettingsState extends SettingsState {
  const factory _SettingsState(
      {final bool isSabatNotificationActive,
      final bool isBibleReminderNotificationActive,
      final Map<int, DateTime> bibleReminders}) = _$_SettingsState;
  const _SettingsState._() : super._();

  factory _SettingsState.fromJson(Map<String, dynamic> json) =
      _$_SettingsState.fromJson;

  @override
  bool get isSabatNotificationActive;
  @override
  bool get isBibleReminderNotificationActive;
  @override
  Map<int, DateTime> get bibleReminders;
  @override
  @JsonKey(ignore: true)
  _$$_SettingsStateCopyWith<_$_SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

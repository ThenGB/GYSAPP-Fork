// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_backup_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AppBackupData _$AppBackupDataFromJson(Map<String, dynamic> json) {
  return _AppBackupData.fromJson(json);
}

/// @nodoc
mixin _$AppBackupData {
  @JsonKey(name: 'bible_state')
  BibleState? get bibleState => throw _privateConstructorUsedError;
  @JsonKey(name: 'song_state')
  SongState? get songState => throw _privateConstructorUsedError;
  @JsonKey(name: 'faith_state')
  FaithState? get faithState => throw _privateConstructorUsedError;
  @JsonKey(name: 'settings_state')
  SettingsState? get settingsState => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppBackupDataCopyWith<AppBackupData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppBackupDataCopyWith<$Res> {
  factory $AppBackupDataCopyWith(
          AppBackupData value, $Res Function(AppBackupData) then) =
      _$AppBackupDataCopyWithImpl<$Res, AppBackupData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'bible_state') BibleState? bibleState,
      @JsonKey(name: 'song_state') SongState? songState,
      @JsonKey(name: 'faith_state') FaithState? faithState,
      @JsonKey(name: 'settings_state') SettingsState? settingsState});

  $BibleStateCopyWith<$Res>? get bibleState;
  $SongStateCopyWith<$Res>? get songState;
  $FaithStateCopyWith<$Res>? get faithState;
  $SettingsStateCopyWith<$Res>? get settingsState;
}

/// @nodoc
class _$AppBackupDataCopyWithImpl<$Res, $Val extends AppBackupData>
    implements $AppBackupDataCopyWith<$Res> {
  _$AppBackupDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bibleState = freezed,
    Object? songState = freezed,
    Object? faithState = freezed,
    Object? settingsState = freezed,
  }) {
    return _then(_value.copyWith(
      bibleState: freezed == bibleState
          ? _value.bibleState
          : bibleState // ignore: cast_nullable_to_non_nullable
              as BibleState?,
      songState: freezed == songState
          ? _value.songState
          : songState // ignore: cast_nullable_to_non_nullable
              as SongState?,
      faithState: freezed == faithState
          ? _value.faithState
          : faithState // ignore: cast_nullable_to_non_nullable
              as FaithState?,
      settingsState: freezed == settingsState
          ? _value.settingsState
          : settingsState // ignore: cast_nullable_to_non_nullable
              as SettingsState?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BibleStateCopyWith<$Res>? get bibleState {
    if (_value.bibleState == null) {
      return null;
    }

    return $BibleStateCopyWith<$Res>(_value.bibleState!, (value) {
      return _then(_value.copyWith(bibleState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SongStateCopyWith<$Res>? get songState {
    if (_value.songState == null) {
      return null;
    }

    return $SongStateCopyWith<$Res>(_value.songState!, (value) {
      return _then(_value.copyWith(songState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $FaithStateCopyWith<$Res>? get faithState {
    if (_value.faithState == null) {
      return null;
    }

    return $FaithStateCopyWith<$Res>(_value.faithState!, (value) {
      return _then(_value.copyWith(faithState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SettingsStateCopyWith<$Res>? get settingsState {
    if (_value.settingsState == null) {
      return null;
    }

    return $SettingsStateCopyWith<$Res>(_value.settingsState!, (value) {
      return _then(_value.copyWith(settingsState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppBackupDataImplCopyWith<$Res>
    implements $AppBackupDataCopyWith<$Res> {
  factory _$$AppBackupDataImplCopyWith(
          _$AppBackupDataImpl value, $Res Function(_$AppBackupDataImpl) then) =
      __$$AppBackupDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'bible_state') BibleState? bibleState,
      @JsonKey(name: 'song_state') SongState? songState,
      @JsonKey(name: 'faith_state') FaithState? faithState,
      @JsonKey(name: 'settings_state') SettingsState? settingsState});

  @override
  $BibleStateCopyWith<$Res>? get bibleState;
  @override
  $SongStateCopyWith<$Res>? get songState;
  @override
  $FaithStateCopyWith<$Res>? get faithState;
  @override
  $SettingsStateCopyWith<$Res>? get settingsState;
}

/// @nodoc
class __$$AppBackupDataImplCopyWithImpl<$Res>
    extends _$AppBackupDataCopyWithImpl<$Res, _$AppBackupDataImpl>
    implements _$$AppBackupDataImplCopyWith<$Res> {
  __$$AppBackupDataImplCopyWithImpl(
      _$AppBackupDataImpl _value, $Res Function(_$AppBackupDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bibleState = freezed,
    Object? songState = freezed,
    Object? faithState = freezed,
    Object? settingsState = freezed,
  }) {
    return _then(_$AppBackupDataImpl(
      bibleState: freezed == bibleState
          ? _value.bibleState
          : bibleState // ignore: cast_nullable_to_non_nullable
              as BibleState?,
      songState: freezed == songState
          ? _value.songState
          : songState // ignore: cast_nullable_to_non_nullable
              as SongState?,
      faithState: freezed == faithState
          ? _value.faithState
          : faithState // ignore: cast_nullable_to_non_nullable
              as FaithState?,
      settingsState: freezed == settingsState
          ? _value.settingsState
          : settingsState // ignore: cast_nullable_to_non_nullable
              as SettingsState?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppBackupDataImpl extends _AppBackupData {
  const _$AppBackupDataImpl(
      {@JsonKey(name: 'bible_state') this.bibleState,
      @JsonKey(name: 'song_state') this.songState,
      @JsonKey(name: 'faith_state') this.faithState,
      @JsonKey(name: 'settings_state') this.settingsState})
      : super._();

  factory _$AppBackupDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppBackupDataImplFromJson(json);

  @override
  @JsonKey(name: 'bible_state')
  final BibleState? bibleState;
  @override
  @JsonKey(name: 'song_state')
  final SongState? songState;
  @override
  @JsonKey(name: 'faith_state')
  final FaithState? faithState;
  @override
  @JsonKey(name: 'settings_state')
  final SettingsState? settingsState;

  @override
  String toString() {
    return 'AppBackupData(bibleState: $bibleState, songState: $songState, faithState: $faithState, settingsState: $settingsState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppBackupDataImpl &&
            (identical(other.bibleState, bibleState) ||
                other.bibleState == bibleState) &&
            (identical(other.songState, songState) ||
                other.songState == songState) &&
            (identical(other.faithState, faithState) ||
                other.faithState == faithState) &&
            (identical(other.settingsState, settingsState) ||
                other.settingsState == settingsState));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, bibleState, songState, faithState, settingsState);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppBackupDataImplCopyWith<_$AppBackupDataImpl> get copyWith =>
      __$$AppBackupDataImplCopyWithImpl<_$AppBackupDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppBackupDataImplToJson(
      this,
    );
  }
}

abstract class _AppBackupData extends AppBackupData {
  const factory _AppBackupData(
      {@JsonKey(name: 'bible_state') final BibleState? bibleState,
      @JsonKey(name: 'song_state') final SongState? songState,
      @JsonKey(name: 'faith_state') final FaithState? faithState,
      @JsonKey(name: 'settings_state')
      final SettingsState? settingsState}) = _$AppBackupDataImpl;
  const _AppBackupData._() : super._();

  factory _AppBackupData.fromJson(Map<String, dynamic> json) =
      _$AppBackupDataImpl.fromJson;

  @override
  @JsonKey(name: 'bible_state')
  BibleState? get bibleState;
  @override
  @JsonKey(name: 'song_state')
  SongState? get songState;
  @override
  @JsonKey(name: 'faith_state')
  FaithState? get faithState;
  @override
  @JsonKey(name: 'settings_state')
  SettingsState? get settingsState;
  @override
  @JsonKey(ignore: true)
  _$$AppBackupDataImplCopyWith<_$AppBackupDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

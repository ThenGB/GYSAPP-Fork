// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

HomeState _$HomeStateFromJson(Map<String, dynamic> json) {
  return _HomeState.fromJson(json);
}

/// @nodoc
mixin _$HomeState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Sauh> get sauhs => throw _privateConstructorUsedError;
  List<TrueVoice> get trueVoices => throw _privateConstructorUsedError;
  List<Menulink> get menuLinks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<Sauh> sauhs,
      List<TrueVoice> trueVoices,
      List<Menulink> menuLinks});
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? sauhs = null,
    Object? trueVoices = null,
    Object? menuLinks = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      sauhs: null == sauhs
          ? _value.sauhs
          : sauhs // ignore: cast_nullable_to_non_nullable
              as List<Sauh>,
      trueVoices: null == trueVoices
          ? _value.trueVoices
          : trueVoices // ignore: cast_nullable_to_non_nullable
              as List<TrueVoice>,
      menuLinks: null == menuLinks
          ? _value.menuLinks
          : menuLinks // ignore: cast_nullable_to_non_nullable
              as List<Menulink>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$$_HomeStateCopyWith(
          _$_HomeState value, $Res Function(_$_HomeState) then) =
      __$$_HomeStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<Sauh> sauhs,
      List<TrueVoice> trueVoices,
      List<Menulink> menuLinks});
}

/// @nodoc
class __$$_HomeStateCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$_HomeState>
    implements _$$_HomeStateCopyWith<$Res> {
  __$$_HomeStateCopyWithImpl(
      _$_HomeState _value, $Res Function(_$_HomeState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? sauhs = null,
    Object? trueVoices = null,
    Object? menuLinks = null,
  }) {
    return _then(_$_HomeState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      sauhs: null == sauhs
          ? _value._sauhs
          : sauhs // ignore: cast_nullable_to_non_nullable
              as List<Sauh>,
      trueVoices: null == trueVoices
          ? _value._trueVoices
          : trueVoices // ignore: cast_nullable_to_non_nullable
              as List<TrueVoice>,
      menuLinks: null == menuLinks
          ? _value._menuLinks
          : menuLinks // ignore: cast_nullable_to_non_nullable
              as List<Menulink>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_HomeState extends _HomeState {
  const _$_HomeState(
      {this.isLoading = false,
      final List<Sauh> sauhs = const [],
      final List<TrueVoice> trueVoices = const [],
      final List<Menulink> menuLinks = const []})
      : _sauhs = sauhs,
        _trueVoices = trueVoices,
        _menuLinks = menuLinks,
        super._();

  factory _$_HomeState.fromJson(Map<String, dynamic> json) =>
      _$$_HomeStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  final List<Sauh> _sauhs;
  @override
  @JsonKey()
  List<Sauh> get sauhs {
    if (_sauhs is EqualUnmodifiableListView) return _sauhs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sauhs);
  }

  final List<TrueVoice> _trueVoices;
  @override
  @JsonKey()
  List<TrueVoice> get trueVoices {
    if (_trueVoices is EqualUnmodifiableListView) return _trueVoices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trueVoices);
  }

  final List<Menulink> _menuLinks;
  @override
  @JsonKey()
  List<Menulink> get menuLinks {
    if (_menuLinks is EqualUnmodifiableListView) return _menuLinks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_menuLinks);
  }

  @override
  String toString() {
    return 'HomeState(isLoading: $isLoading, sauhs: $sauhs, trueVoices: $trueVoices, menuLinks: $menuLinks)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_HomeState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._sauhs, _sauhs) &&
            const DeepCollectionEquality()
                .equals(other._trueVoices, _trueVoices) &&
            const DeepCollectionEquality()
                .equals(other._menuLinks, _menuLinks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      const DeepCollectionEquality().hash(_sauhs),
      const DeepCollectionEquality().hash(_trueVoices),
      const DeepCollectionEquality().hash(_menuLinks));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_HomeStateCopyWith<_$_HomeState> get copyWith =>
      __$$_HomeStateCopyWithImpl<_$_HomeState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_HomeStateToJson(
      this,
    );
  }
}

abstract class _HomeState extends HomeState {
  const factory _HomeState(
      {final bool isLoading,
      final List<Sauh> sauhs,
      final List<TrueVoice> trueVoices,
      final List<Menulink> menuLinks}) = _$_HomeState;
  const _HomeState._() : super._();

  factory _HomeState.fromJson(Map<String, dynamic> json) =
      _$_HomeState.fromJson;

  @override
  bool get isLoading;
  @override
  List<Sauh> get sauhs;
  @override
  List<TrueVoice> get trueVoices;
  @override
  List<Menulink> get menuLinks;
  @override
  @JsonKey(ignore: true)
  _$$_HomeStateCopyWith<_$_HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

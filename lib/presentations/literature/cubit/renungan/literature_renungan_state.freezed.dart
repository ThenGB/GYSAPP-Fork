// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'literature_renungan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LiteratureRenunganState _$LiteratureRenunganStateFromJson(
    Map<String, dynamic> json) {
  return _LiteratureRenunganState.fromJson(json);
}

/// @nodoc
mixin _$LiteratureRenunganState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Renungan> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiteratureRenunganStateCopyWith<LiteratureRenunganState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiteratureRenunganStateCopyWith<$Res> {
  factory $LiteratureRenunganStateCopyWith(LiteratureRenunganState value,
          $Res Function(LiteratureRenunganState) then) =
      _$LiteratureRenunganStateCopyWithImpl<$Res, LiteratureRenunganState>;
  @useResult
  $Res call({bool isLoading, List<Renungan> items});
}

/// @nodoc
class _$LiteratureRenunganStateCopyWithImpl<$Res,
        $Val extends LiteratureRenunganState>
    implements $LiteratureRenunganStateCopyWith<$Res> {
  _$LiteratureRenunganStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Renungan>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LiteratureRenunganStateCopyWith<$Res>
    implements $LiteratureRenunganStateCopyWith<$Res> {
  factory _$$_LiteratureRenunganStateCopyWith(_$_LiteratureRenunganState value,
          $Res Function(_$_LiteratureRenunganState) then) =
      __$$_LiteratureRenunganStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, List<Renungan> items});
}

/// @nodoc
class __$$_LiteratureRenunganStateCopyWithImpl<$Res>
    extends _$LiteratureRenunganStateCopyWithImpl<$Res,
        _$_LiteratureRenunganState>
    implements _$$_LiteratureRenunganStateCopyWith<$Res> {
  __$$_LiteratureRenunganStateCopyWithImpl(_$_LiteratureRenunganState _value,
      $Res Function(_$_LiteratureRenunganState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_$_LiteratureRenunganState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Renungan>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LiteratureRenunganState extends _LiteratureRenunganState {
  const _$_LiteratureRenunganState(
      {this.isLoading = false, final List<Renungan> items = const []})
      : _items = items,
        super._();

  factory _$_LiteratureRenunganState.fromJson(Map<String, dynamic> json) =>
      _$$_LiteratureRenunganStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  final List<Renungan> _items;
  @override
  @JsonKey()
  List<Renungan> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'LiteratureRenunganState(isLoading: $isLoading, items: $items)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LiteratureRenunganState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, isLoading, const DeepCollectionEquality().hash(_items));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LiteratureRenunganStateCopyWith<_$_LiteratureRenunganState>
      get copyWith =>
          __$$_LiteratureRenunganStateCopyWithImpl<_$_LiteratureRenunganState>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LiteratureRenunganStateToJson(
      this,
    );
  }
}

abstract class _LiteratureRenunganState extends LiteratureRenunganState {
  const factory _LiteratureRenunganState(
      {final bool isLoading,
      final List<Renungan> items}) = _$_LiteratureRenunganState;
  const _LiteratureRenunganState._() : super._();

  factory _LiteratureRenunganState.fromJson(Map<String, dynamic> json) =
      _$_LiteratureRenunganState.fromJson;

  @override
  bool get isLoading;
  @override
  List<Renungan> get items;
  @override
  @JsonKey(ignore: true)
  _$$_LiteratureRenunganStateCopyWith<_$_LiteratureRenunganState>
      get copyWith => throw _privateConstructorUsedError;
}

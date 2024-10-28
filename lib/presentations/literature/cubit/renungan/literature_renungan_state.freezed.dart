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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LiteratureRenunganState _$LiteratureRenunganStateFromJson(
    Map<String, dynamic> json) {
  return _LiteratureRenunganState.fromJson(json);
}

/// @nodoc
mixin _$LiteratureRenunganState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Renungan> get items => throw _privateConstructorUsedError;

  /// Serializes this LiteratureRenunganState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiteratureRenunganState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of LiteratureRenunganState
  /// with the given fields replaced by the non-null parameter values.
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
abstract class _$$LiteratureRenunganStateImplCopyWith<$Res>
    implements $LiteratureRenunganStateCopyWith<$Res> {
  factory _$$LiteratureRenunganStateImplCopyWith(
          _$LiteratureRenunganStateImpl value,
          $Res Function(_$LiteratureRenunganStateImpl) then) =
      __$$LiteratureRenunganStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, List<Renungan> items});
}

/// @nodoc
class __$$LiteratureRenunganStateImplCopyWithImpl<$Res>
    extends _$LiteratureRenunganStateCopyWithImpl<$Res,
        _$LiteratureRenunganStateImpl>
    implements _$$LiteratureRenunganStateImplCopyWith<$Res> {
  __$$LiteratureRenunganStateImplCopyWithImpl(
      _$LiteratureRenunganStateImpl _value,
      $Res Function(_$LiteratureRenunganStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LiteratureRenunganState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_$LiteratureRenunganStateImpl(
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
class _$LiteratureRenunganStateImpl extends _LiteratureRenunganState {
  const _$LiteratureRenunganStateImpl(
      {this.isLoading = false, final List<Renungan> items = const []})
      : _items = items,
        super._();

  factory _$LiteratureRenunganStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiteratureRenunganStateImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiteratureRenunganStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, isLoading, const DeepCollectionEquality().hash(_items));

  /// Create a copy of LiteratureRenunganState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiteratureRenunganStateImplCopyWith<_$LiteratureRenunganStateImpl>
      get copyWith => __$$LiteratureRenunganStateImplCopyWithImpl<
          _$LiteratureRenunganStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiteratureRenunganStateImplToJson(
      this,
    );
  }
}

abstract class _LiteratureRenunganState extends LiteratureRenunganState {
  const factory _LiteratureRenunganState(
      {final bool isLoading,
      final List<Renungan> items}) = _$LiteratureRenunganStateImpl;
  const _LiteratureRenunganState._() : super._();

  factory _LiteratureRenunganState.fromJson(Map<String, dynamic> json) =
      _$LiteratureRenunganStateImpl.fromJson;

  @override
  bool get isLoading;
  @override
  List<Renungan> get items;

  /// Create a copy of LiteratureRenunganState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiteratureRenunganStateImplCopyWith<_$LiteratureRenunganStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

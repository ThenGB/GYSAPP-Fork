// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'literature_kesaksian_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LiteratureKesaksianState _$LiteratureKesaksianStateFromJson(
    Map<String, dynamic> json) {
  return _LiteratureKesaksianState.fromJson(json);
}

/// @nodoc
mixin _$LiteratureKesaksianState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Kesaksian> get items => throw _privateConstructorUsedError;

  /// Serializes this LiteratureKesaksianState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiteratureKesaksianState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiteratureKesaksianStateCopyWith<LiteratureKesaksianState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiteratureKesaksianStateCopyWith<$Res> {
  factory $LiteratureKesaksianStateCopyWith(LiteratureKesaksianState value,
          $Res Function(LiteratureKesaksianState) then) =
      _$LiteratureKesaksianStateCopyWithImpl<$Res, LiteratureKesaksianState>;
  @useResult
  $Res call({bool isLoading, List<Kesaksian> items});
}

/// @nodoc
class _$LiteratureKesaksianStateCopyWithImpl<$Res,
        $Val extends LiteratureKesaksianState>
    implements $LiteratureKesaksianStateCopyWith<$Res> {
  _$LiteratureKesaksianStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiteratureKesaksianState
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
              as List<Kesaksian>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LiteratureKesaksianStateImplCopyWith<$Res>
    implements $LiteratureKesaksianStateCopyWith<$Res> {
  factory _$$LiteratureKesaksianStateImplCopyWith(
          _$LiteratureKesaksianStateImpl value,
          $Res Function(_$LiteratureKesaksianStateImpl) then) =
      __$$LiteratureKesaksianStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, List<Kesaksian> items});
}

/// @nodoc
class __$$LiteratureKesaksianStateImplCopyWithImpl<$Res>
    extends _$LiteratureKesaksianStateCopyWithImpl<$Res,
        _$LiteratureKesaksianStateImpl>
    implements _$$LiteratureKesaksianStateImplCopyWith<$Res> {
  __$$LiteratureKesaksianStateImplCopyWithImpl(
      _$LiteratureKesaksianStateImpl _value,
      $Res Function(_$LiteratureKesaksianStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LiteratureKesaksianState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_$LiteratureKesaksianStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Kesaksian>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LiteratureKesaksianStateImpl extends _LiteratureKesaksianState {
  const _$LiteratureKesaksianStateImpl(
      {this.isLoading = false, final List<Kesaksian> items = const []})
      : _items = items,
        super._();

  factory _$LiteratureKesaksianStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiteratureKesaksianStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  final List<Kesaksian> _items;
  @override
  @JsonKey()
  List<Kesaksian> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'LiteratureKesaksianState(isLoading: $isLoading, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiteratureKesaksianStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, isLoading, const DeepCollectionEquality().hash(_items));

  /// Create a copy of LiteratureKesaksianState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiteratureKesaksianStateImplCopyWith<_$LiteratureKesaksianStateImpl>
      get copyWith => __$$LiteratureKesaksianStateImplCopyWithImpl<
          _$LiteratureKesaksianStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiteratureKesaksianStateImplToJson(
      this,
    );
  }
}

abstract class _LiteratureKesaksianState extends LiteratureKesaksianState {
  const factory _LiteratureKesaksianState(
      {final bool isLoading,
      final List<Kesaksian> items}) = _$LiteratureKesaksianStateImpl;
  const _LiteratureKesaksianState._() : super._();

  factory _LiteratureKesaksianState.fromJson(Map<String, dynamic> json) =
      _$LiteratureKesaksianStateImpl.fromJson;

  @override
  bool get isLoading;
  @override
  List<Kesaksian> get items;

  /// Create a copy of LiteratureKesaksianState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiteratureKesaksianStateImplCopyWith<_$LiteratureKesaksianStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

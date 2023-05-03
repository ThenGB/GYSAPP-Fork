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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LiteratureKesaksianState _$LiteratureKesaksianStateFromJson(
    Map<String, dynamic> json) {
  return _LiteratureKesaksianState.fromJson(json);
}

/// @nodoc
mixin _$LiteratureKesaksianState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Kesaksian> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
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
abstract class _$$_LiteratureKesaksianStateCopyWith<$Res>
    implements $LiteratureKesaksianStateCopyWith<$Res> {
  factory _$$_LiteratureKesaksianStateCopyWith(
          _$_LiteratureKesaksianState value,
          $Res Function(_$_LiteratureKesaksianState) then) =
      __$$_LiteratureKesaksianStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, List<Kesaksian> items});
}

/// @nodoc
class __$$_LiteratureKesaksianStateCopyWithImpl<$Res>
    extends _$LiteratureKesaksianStateCopyWithImpl<$Res,
        _$_LiteratureKesaksianState>
    implements _$$_LiteratureKesaksianStateCopyWith<$Res> {
  __$$_LiteratureKesaksianStateCopyWithImpl(_$_LiteratureKesaksianState _value,
      $Res Function(_$_LiteratureKesaksianState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_$_LiteratureKesaksianState(
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
class _$_LiteratureKesaksianState extends _LiteratureKesaksianState {
  const _$_LiteratureKesaksianState(
      {this.isLoading = false, final List<Kesaksian> items = const []})
      : _items = items,
        super._();

  factory _$_LiteratureKesaksianState.fromJson(Map<String, dynamic> json) =>
      _$$_LiteratureKesaksianStateFromJson(json);

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LiteratureKesaksianState &&
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
  _$$_LiteratureKesaksianStateCopyWith<_$_LiteratureKesaksianState>
      get copyWith => __$$_LiteratureKesaksianStateCopyWithImpl<
          _$_LiteratureKesaksianState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LiteratureKesaksianStateToJson(
      this,
    );
  }
}

abstract class _LiteratureKesaksianState extends LiteratureKesaksianState {
  const factory _LiteratureKesaksianState(
      {final bool isLoading,
      final List<Kesaksian> items}) = _$_LiteratureKesaksianState;
  const _LiteratureKesaksianState._() : super._();

  factory _LiteratureKesaksianState.fromJson(Map<String, dynamic> json) =
      _$_LiteratureKesaksianState.fromJson;

  @override
  bool get isLoading;
  @override
  List<Kesaksian> get items;
  @override
  @JsonKey(ignore: true)
  _$$_LiteratureKesaksianStateCopyWith<_$_LiteratureKesaksianState>
      get copyWith => throw _privateConstructorUsedError;
}

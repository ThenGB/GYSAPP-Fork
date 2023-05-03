// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'literature_panduan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LiteraturePanduanState _$LiteraturePanduanStateFromJson(
    Map<String, dynamic> json) {
  return _LiteraturePanduanState.fromJson(json);
}

/// @nodoc
mixin _$LiteraturePanduanState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Panduan> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiteraturePanduanStateCopyWith<LiteraturePanduanState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiteraturePanduanStateCopyWith<$Res> {
  factory $LiteraturePanduanStateCopyWith(LiteraturePanduanState value,
          $Res Function(LiteraturePanduanState) then) =
      _$LiteraturePanduanStateCopyWithImpl<$Res, LiteraturePanduanState>;
  @useResult
  $Res call({bool isLoading, List<Panduan> items});
}

/// @nodoc
class _$LiteraturePanduanStateCopyWithImpl<$Res,
        $Val extends LiteraturePanduanState>
    implements $LiteraturePanduanStateCopyWith<$Res> {
  _$LiteraturePanduanStateCopyWithImpl(this._value, this._then);

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
              as List<Panduan>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LiteraturePanduanStateCopyWith<$Res>
    implements $LiteraturePanduanStateCopyWith<$Res> {
  factory _$$_LiteraturePanduanStateCopyWith(_$_LiteraturePanduanState value,
          $Res Function(_$_LiteraturePanduanState) then) =
      __$$_LiteraturePanduanStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, List<Panduan> items});
}

/// @nodoc
class __$$_LiteraturePanduanStateCopyWithImpl<$Res>
    extends _$LiteraturePanduanStateCopyWithImpl<$Res,
        _$_LiteraturePanduanState>
    implements _$$_LiteraturePanduanStateCopyWith<$Res> {
  __$$_LiteraturePanduanStateCopyWithImpl(_$_LiteraturePanduanState _value,
      $Res Function(_$_LiteraturePanduanState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_$_LiteraturePanduanState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Panduan>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LiteraturePanduanState extends _LiteraturePanduanState {
  const _$_LiteraturePanduanState(
      {this.isLoading = false, final List<Panduan> items = const []})
      : _items = items,
        super._();

  factory _$_LiteraturePanduanState.fromJson(Map<String, dynamic> json) =>
      _$$_LiteraturePanduanStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  final List<Panduan> _items;
  @override
  @JsonKey()
  List<Panduan> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'LiteraturePanduanState(isLoading: $isLoading, items: $items)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LiteraturePanduanState &&
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
  _$$_LiteraturePanduanStateCopyWith<_$_LiteraturePanduanState> get copyWith =>
      __$$_LiteraturePanduanStateCopyWithImpl<_$_LiteraturePanduanState>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LiteraturePanduanStateToJson(
      this,
    );
  }
}

abstract class _LiteraturePanduanState extends LiteraturePanduanState {
  const factory _LiteraturePanduanState(
      {final bool isLoading,
      final List<Panduan> items}) = _$_LiteraturePanduanState;
  const _LiteraturePanduanState._() : super._();

  factory _LiteraturePanduanState.fromJson(Map<String, dynamic> json) =
      _$_LiteraturePanduanState.fromJson;

  @override
  bool get isLoading;
  @override
  List<Panduan> get items;
  @override
  @JsonKey(ignore: true)
  _$$_LiteraturePanduanStateCopyWith<_$_LiteraturePanduanState> get copyWith =>
      throw _privateConstructorUsedError;
}

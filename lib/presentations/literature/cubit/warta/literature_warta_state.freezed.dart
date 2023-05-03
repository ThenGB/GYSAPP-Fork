// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'literature_warta_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LiteratureWartaState _$LiteratureWartaStateFromJson(Map<String, dynamic> json) {
  return _LiteratureWartaState.fromJson(json);
}

/// @nodoc
mixin _$LiteratureWartaState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Warta> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiteratureWartaStateCopyWith<LiteratureWartaState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiteratureWartaStateCopyWith<$Res> {
  factory $LiteratureWartaStateCopyWith(LiteratureWartaState value,
          $Res Function(LiteratureWartaState) then) =
      _$LiteratureWartaStateCopyWithImpl<$Res, LiteratureWartaState>;
  @useResult
  $Res call({bool isLoading, List<Warta> items});
}

/// @nodoc
class _$LiteratureWartaStateCopyWithImpl<$Res,
        $Val extends LiteratureWartaState>
    implements $LiteratureWartaStateCopyWith<$Res> {
  _$LiteratureWartaStateCopyWithImpl(this._value, this._then);

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
              as List<Warta>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LiteratureWartaStateCopyWith<$Res>
    implements $LiteratureWartaStateCopyWith<$Res> {
  factory _$$_LiteratureWartaStateCopyWith(_$_LiteratureWartaState value,
          $Res Function(_$_LiteratureWartaState) then) =
      __$$_LiteratureWartaStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, List<Warta> items});
}

/// @nodoc
class __$$_LiteratureWartaStateCopyWithImpl<$Res>
    extends _$LiteratureWartaStateCopyWithImpl<$Res, _$_LiteratureWartaState>
    implements _$$_LiteratureWartaStateCopyWith<$Res> {
  __$$_LiteratureWartaStateCopyWithImpl(_$_LiteratureWartaState _value,
      $Res Function(_$_LiteratureWartaState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_$_LiteratureWartaState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Warta>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LiteratureWartaState extends _LiteratureWartaState {
  const _$_LiteratureWartaState(
      {this.isLoading = false, final List<Warta> items = const []})
      : _items = items,
        super._();

  factory _$_LiteratureWartaState.fromJson(Map<String, dynamic> json) =>
      _$$_LiteratureWartaStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  final List<Warta> _items;
  @override
  @JsonKey()
  List<Warta> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'LiteratureWartaState(isLoading: $isLoading, items: $items)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LiteratureWartaState &&
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
  _$$_LiteratureWartaStateCopyWith<_$_LiteratureWartaState> get copyWith =>
      __$$_LiteratureWartaStateCopyWithImpl<_$_LiteratureWartaState>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LiteratureWartaStateToJson(
      this,
    );
  }
}

abstract class _LiteratureWartaState extends LiteratureWartaState {
  const factory _LiteratureWartaState(
      {final bool isLoading,
      final List<Warta> items}) = _$_LiteratureWartaState;
  const _LiteratureWartaState._() : super._();

  factory _LiteratureWartaState.fromJson(Map<String, dynamic> json) =
      _$_LiteratureWartaState.fromJson;

  @override
  bool get isLoading;
  @override
  List<Warta> get items;
  @override
  @JsonKey(ignore: true)
  _$$_LiteratureWartaStateCopyWith<_$_LiteratureWartaState> get copyWith =>
      throw _privateConstructorUsedError;
}

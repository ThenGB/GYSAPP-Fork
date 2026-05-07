// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'literature_panduan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiteraturePanduanState {

 bool get isLoading; List<Panduan> get items;
/// Create a copy of LiteraturePanduanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiteraturePanduanStateCopyWith<LiteraturePanduanState> get copyWith => _$LiteraturePanduanStateCopyWithImpl<LiteraturePanduanState>(this as LiteraturePanduanState, _$identity);

  /// Serializes this LiteraturePanduanState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiteraturePanduanState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'LiteraturePanduanState(isLoading: $isLoading, items: $items)';
}


}

/// @nodoc
abstract mixin class $LiteraturePanduanStateCopyWith<$Res>  {
  factory $LiteraturePanduanStateCopyWith(LiteraturePanduanState value, $Res Function(LiteraturePanduanState) _then) = _$LiteraturePanduanStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<Panduan> items
});




}
/// @nodoc
class _$LiteraturePanduanStateCopyWithImpl<$Res>
    implements $LiteraturePanduanStateCopyWith<$Res> {
  _$LiteraturePanduanStateCopyWithImpl(this._self, this._then);

  final LiteraturePanduanState _self;
  final $Res Function(LiteraturePanduanState) _then;

/// Create a copy of LiteraturePanduanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? items = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Panduan>,
  ));
}

}


/// Adds pattern-matching-related methods to [LiteraturePanduanState].
extension LiteraturePanduanStatePatterns on LiteraturePanduanState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiteraturePanduanState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiteraturePanduanState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiteraturePanduanState value)  $default,){
final _that = this;
switch (_that) {
case _LiteraturePanduanState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiteraturePanduanState value)?  $default,){
final _that = this;
switch (_that) {
case _LiteraturePanduanState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<Panduan> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiteraturePanduanState() when $default != null:
return $default(_that.isLoading,_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<Panduan> items)  $default,) {final _that = this;
switch (_that) {
case _LiteraturePanduanState():
return $default(_that.isLoading,_that.items);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<Panduan> items)?  $default,) {final _that = this;
switch (_that) {
case _LiteraturePanduanState() when $default != null:
return $default(_that.isLoading,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiteraturePanduanState extends LiteraturePanduanState {
  const _LiteraturePanduanState({this.isLoading = false, final  List<Panduan> items = const []}): _items = items,super._();
  factory _LiteraturePanduanState.fromJson(Map<String, dynamic> json) => _$LiteraturePanduanStateFromJson(json);

@override@JsonKey() final  bool isLoading;
 final  List<Panduan> _items;
@override@JsonKey() List<Panduan> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of LiteraturePanduanState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiteraturePanduanStateCopyWith<_LiteraturePanduanState> get copyWith => __$LiteraturePanduanStateCopyWithImpl<_LiteraturePanduanState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiteraturePanduanStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiteraturePanduanState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'LiteraturePanduanState(isLoading: $isLoading, items: $items)';
}


}

/// @nodoc
abstract mixin class _$LiteraturePanduanStateCopyWith<$Res> implements $LiteraturePanduanStateCopyWith<$Res> {
  factory _$LiteraturePanduanStateCopyWith(_LiteraturePanduanState value, $Res Function(_LiteraturePanduanState) _then) = __$LiteraturePanduanStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<Panduan> items
});




}
/// @nodoc
class __$LiteraturePanduanStateCopyWithImpl<$Res>
    implements _$LiteraturePanduanStateCopyWith<$Res> {
  __$LiteraturePanduanStateCopyWithImpl(this._self, this._then);

  final _LiteraturePanduanState _self;
  final $Res Function(_LiteraturePanduanState) _then;

/// Create a copy of LiteraturePanduanState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? items = null,}) {
  return _then(_LiteraturePanduanState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Panduan>,
  ));
}


}

// dart format on

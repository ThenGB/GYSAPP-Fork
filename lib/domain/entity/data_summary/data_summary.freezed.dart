// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DataSummary {

@JsonKey(name: 'values') List<String> get values;
/// Create a copy of DataSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataSummaryCopyWith<DataSummary> get copyWith => _$DataSummaryCopyWithImpl<DataSummary>(this as DataSummary, _$identity);

  /// Serializes this DataSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DataSummary&&const DeepCollectionEquality().equals(other.values, values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(values));

@override
String toString() {
  return 'DataSummary(values: $values)';
}


}

/// @nodoc
abstract mixin class $DataSummaryCopyWith<$Res>  {
  factory $DataSummaryCopyWith(DataSummary value, $Res Function(DataSummary) _then) = _$DataSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'values') List<String> values
});




}
/// @nodoc
class _$DataSummaryCopyWithImpl<$Res>
    implements $DataSummaryCopyWith<$Res> {
  _$DataSummaryCopyWithImpl(this._self, this._then);

  final DataSummary _self;
  final $Res Function(DataSummary) _then;

/// Create a copy of DataSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? values = null,}) {
  return _then(_self.copyWith(
values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DataSummary].
extension DataSummaryPatterns on DataSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DataSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DataSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DataSummary value)  $default,){
final _that = this;
switch (_that) {
case _DataSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DataSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DataSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'values')  List<String> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DataSummary() when $default != null:
return $default(_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'values')  List<String> values)  $default,) {final _that = this;
switch (_that) {
case _DataSummary():
return $default(_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'values')  List<String> values)?  $default,) {final _that = this;
switch (_that) {
case _DataSummary() when $default != null:
return $default(_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DataSummary extends DataSummary {
  const _DataSummary({@JsonKey(name: 'values') final  List<String> values = const []}): _values = values,super._();
  factory _DataSummary.fromJson(Map<String, dynamic> json) => _$DataSummaryFromJson(json);

 final  List<String> _values;
@override@JsonKey(name: 'values') List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of DataSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DataSummaryCopyWith<_DataSummary> get copyWith => __$DataSummaryCopyWithImpl<_DataSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DataSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DataSummary&&const DeepCollectionEquality().equals(other._values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'DataSummary(values: $values)';
}


}

/// @nodoc
abstract mixin class _$DataSummaryCopyWith<$Res> implements $DataSummaryCopyWith<$Res> {
  factory _$DataSummaryCopyWith(_DataSummary value, $Res Function(_DataSummary) _then) = __$DataSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'values') List<String> values
});




}
/// @nodoc
class __$DataSummaryCopyWithImpl<$Res>
    implements _$DataSummaryCopyWith<$Res> {
  __$DataSummaryCopyWithImpl(this._self, this._then);

  final _DataSummary _self;
  final $Res Function(_DataSummary) _then;

/// Create a copy of DataSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? values = null,}) {
  return _then(_DataSummary(
values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pastel_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PastelPreset {

 String get key; String get label;@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color get primary;@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color get container;@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color get surface; bool get isDark;
/// Create a copy of PastelPreset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PastelPresetCopyWith<PastelPreset> get copyWith => _$PastelPresetCopyWithImpl<PastelPreset>(this as PastelPreset, _$identity);

  /// Serializes this PastelPreset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PastelPreset&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.container, container) || other.container == container)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.isDark, isDark) || other.isDark == isDark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,primary,container,surface,isDark);

@override
String toString() {
  return 'PastelPreset(key: $key, label: $label, primary: $primary, container: $container, surface: $surface, isDark: $isDark)';
}


}

/// @nodoc
abstract mixin class $PastelPresetCopyWith<$Res>  {
  factory $PastelPresetCopyWith(PastelPreset value, $Res Function(PastelPreset) _then) = _$PastelPresetCopyWithImpl;
@useResult
$Res call({
 String key, String label,@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color primary,@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color container,@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color surface, bool isDark
});




}
/// @nodoc
class _$PastelPresetCopyWithImpl<$Res>
    implements $PastelPresetCopyWith<$Res> {
  _$PastelPresetCopyWithImpl(this._self, this._then);

  final PastelPreset _self;
  final $Res Function(PastelPreset) _then;

/// Create a copy of PastelPreset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? primary = null,Object? container = null,Object? surface = null,Object? isDark = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as Color,container: null == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as Color,surface: null == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as Color,isDark: null == isDark ? _self.isDark : isDark // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PastelPreset].
extension PastelPresetPatterns on PastelPreset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PastelPreset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PastelPreset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PastelPreset value)  $default,){
final _that = this;
switch (_that) {
case _PastelPreset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PastelPreset value)?  $default,){
final _that = this;
switch (_that) {
case _PastelPreset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)  Color primary, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)  Color container, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)  Color surface,  bool isDark)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PastelPreset() when $default != null:
return $default(_that.key,_that.label,_that.primary,_that.container,_that.surface,_that.isDark);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)  Color primary, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)  Color container, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)  Color surface,  bool isDark)  $default,) {final _that = this;
switch (_that) {
case _PastelPreset():
return $default(_that.key,_that.label,_that.primary,_that.container,_that.surface,_that.isDark);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)  Color primary, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)  Color container, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)  Color surface,  bool isDark)?  $default,) {final _that = this;
switch (_that) {
case _PastelPreset() when $default != null:
return $default(_that.key,_that.label,_that.primary,_that.container,_that.surface,_that.isDark);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PastelPreset extends PastelPreset {
  const _PastelPreset({required this.key, required this.label, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) required this.primary, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) required this.container, @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) required this.surface, this.isDark = false}): super._();
  factory _PastelPreset.fromJson(Map<String, dynamic> json) => _$PastelPresetFromJson(json);

@override final  String key;
@override final  String label;
@override@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) final  Color primary;
@override@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) final  Color container;
@override@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) final  Color surface;
@override@JsonKey() final  bool isDark;

/// Create a copy of PastelPreset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PastelPresetCopyWith<_PastelPreset> get copyWith => __$PastelPresetCopyWithImpl<_PastelPreset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PastelPresetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PastelPreset&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.container, container) || other.container == container)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.isDark, isDark) || other.isDark == isDark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,primary,container,surface,isDark);

@override
String toString() {
  return 'PastelPreset(key: $key, label: $label, primary: $primary, container: $container, surface: $surface, isDark: $isDark)';
}


}

/// @nodoc
abstract mixin class _$PastelPresetCopyWith<$Res> implements $PastelPresetCopyWith<$Res> {
  factory _$PastelPresetCopyWith(_PastelPreset value, $Res Function(_PastelPreset) _then) = __$PastelPresetCopyWithImpl;
@override @useResult
$Res call({
 String key, String label,@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color primary,@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color container,@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color surface, bool isDark
});




}
/// @nodoc
class __$PastelPresetCopyWithImpl<$Res>
    implements _$PastelPresetCopyWith<$Res> {
  __$PastelPresetCopyWithImpl(this._self, this._then);

  final _PastelPreset _self;
  final $Res Function(_PastelPreset) _then;

/// Create a copy of PastelPreset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? primary = null,Object? container = null,Object? surface = null,Object? isDark = null,}) {
  return _then(_PastelPreset(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as Color,container: null == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as Color,surface: null == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as Color,isDark: null == isDark ? _self.isDark : isDark // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menulink_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Menulink {

 String get label; String get icon; String get url; bool get enabled;
/// Create a copy of Menulink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenulinkCopyWith<Menulink> get copyWith => _$MenulinkCopyWithImpl<Menulink>(this as Menulink, _$identity);

  /// Serializes this Menulink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Menulink&&(identical(other.label, label) || other.label == label)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.url, url) || other.url == url)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,icon,url,enabled);

@override
String toString() {
  return 'Menulink(label: $label, icon: $icon, url: $url, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $MenulinkCopyWith<$Res>  {
  factory $MenulinkCopyWith(Menulink value, $Res Function(Menulink) _then) = _$MenulinkCopyWithImpl;
@useResult
$Res call({
 String label, String icon, String url, bool enabled
});




}
/// @nodoc
class _$MenulinkCopyWithImpl<$Res>
    implements $MenulinkCopyWith<$Res> {
  _$MenulinkCopyWithImpl(this._self, this._then);

  final Menulink _self;
  final $Res Function(Menulink) _then;

/// Create a copy of Menulink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? icon = null,Object? url = null,Object? enabled = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Menulink].
extension MenulinkPatterns on Menulink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Menulink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Menulink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Menulink value)  $default,){
final _that = this;
switch (_that) {
case _Menulink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Menulink value)?  $default,){
final _that = this;
switch (_that) {
case _Menulink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String icon,  String url,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Menulink() when $default != null:
return $default(_that.label,_that.icon,_that.url,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String icon,  String url,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _Menulink():
return $default(_that.label,_that.icon,_that.url,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String icon,  String url,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _Menulink() when $default != null:
return $default(_that.label,_that.icon,_that.url,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Menulink extends Menulink {
  const _Menulink({required this.label, required this.icon, required this.url, required this.enabled}): super._();
  factory _Menulink.fromJson(Map<String, dynamic> json) => _$MenulinkFromJson(json);

@override final  String label;
@override final  String icon;
@override final  String url;
@override final  bool enabled;

/// Create a copy of Menulink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenulinkCopyWith<_Menulink> get copyWith => __$MenulinkCopyWithImpl<_Menulink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenulinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Menulink&&(identical(other.label, label) || other.label == label)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.url, url) || other.url == url)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,icon,url,enabled);

@override
String toString() {
  return 'Menulink(label: $label, icon: $icon, url: $url, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$MenulinkCopyWith<$Res> implements $MenulinkCopyWith<$Res> {
  factory _$MenulinkCopyWith(_Menulink value, $Res Function(_Menulink) _then) = __$MenulinkCopyWithImpl;
@override @useResult
$Res call({
 String label, String icon, String url, bool enabled
});




}
/// @nodoc
class __$MenulinkCopyWithImpl<$Res>
    implements _$MenulinkCopyWith<$Res> {
  __$MenulinkCopyWithImpl(this._self, this._then);

  final _Menulink _self;
  final $Res Function(_Menulink) _then;

/// Create a copy of Menulink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? icon = null,Object? url = null,Object? enabled = null,}) {
  return _then(_Menulink(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

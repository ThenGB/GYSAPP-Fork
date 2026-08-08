// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThemePreferences {

 String get accentKey;/// ARGB value of the user-picked custom accent colour; 0 = unset.
 int get customAccentSeed; SurfaceTone get surfaceTone; CornerRadiusStyle get cornerRadius; DisplayDensity get density; TypographyScale get typographyScale; bool get compactMode;
/// Create a copy of ThemePreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemePreferencesCopyWith<ThemePreferences> get copyWith => _$ThemePreferencesCopyWithImpl<ThemePreferences>(this as ThemePreferences, _$identity);

  /// Serializes this ThemePreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemePreferences&&(identical(other.accentKey, accentKey) || other.accentKey == accentKey)&&(identical(other.customAccentSeed, customAccentSeed) || other.customAccentSeed == customAccentSeed)&&(identical(other.surfaceTone, surfaceTone) || other.surfaceTone == surfaceTone)&&(identical(other.cornerRadius, cornerRadius) || other.cornerRadius == cornerRadius)&&(identical(other.density, density) || other.density == density)&&(identical(other.typographyScale, typographyScale) || other.typographyScale == typographyScale)&&(identical(other.compactMode, compactMode) || other.compactMode == compactMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accentKey,customAccentSeed,surfaceTone,cornerRadius,density,typographyScale,compactMode);

@override
String toString() {
  return 'ThemePreferences(accentKey: $accentKey, customAccentSeed: $customAccentSeed, surfaceTone: $surfaceTone, cornerRadius: $cornerRadius, density: $density, typographyScale: $typographyScale, compactMode: $compactMode)';
}


}

/// @nodoc
abstract mixin class $ThemePreferencesCopyWith<$Res>  {
  factory $ThemePreferencesCopyWith(ThemePreferences value, $Res Function(ThemePreferences) _then) = _$ThemePreferencesCopyWithImpl;
@useResult
$Res call({
 String accentKey, int customAccentSeed, SurfaceTone surfaceTone, CornerRadiusStyle cornerRadius, DisplayDensity density, TypographyScale typographyScale, bool compactMode
});




}
/// @nodoc
class _$ThemePreferencesCopyWithImpl<$Res>
    implements $ThemePreferencesCopyWith<$Res> {
  _$ThemePreferencesCopyWithImpl(this._self, this._then);

  final ThemePreferences _self;
  final $Res Function(ThemePreferences) _then;

/// Create a copy of ThemePreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accentKey = null,Object? customAccentSeed = null,Object? surfaceTone = null,Object? cornerRadius = null,Object? density = null,Object? typographyScale = null,Object? compactMode = null,}) {
  return _then(_self.copyWith(
accentKey: null == accentKey ? _self.accentKey : accentKey // ignore: cast_nullable_to_non_nullable
as String,customAccentSeed: null == customAccentSeed ? _self.customAccentSeed : customAccentSeed // ignore: cast_nullable_to_non_nullable
as int,surfaceTone: null == surfaceTone ? _self.surfaceTone : surfaceTone // ignore: cast_nullable_to_non_nullable
as SurfaceTone,cornerRadius: null == cornerRadius ? _self.cornerRadius : cornerRadius // ignore: cast_nullable_to_non_nullable
as CornerRadiusStyle,density: null == density ? _self.density : density // ignore: cast_nullable_to_non_nullable
as DisplayDensity,typographyScale: null == typographyScale ? _self.typographyScale : typographyScale // ignore: cast_nullable_to_non_nullable
as TypographyScale,compactMode: null == compactMode ? _self.compactMode : compactMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemePreferences].
extension ThemePreferencesPatterns on ThemePreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemePreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemePreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemePreferences value)  $default,){
final _that = this;
switch (_that) {
case _ThemePreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemePreferences value)?  $default,){
final _that = this;
switch (_that) {
case _ThemePreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accentKey,  int customAccentSeed,  SurfaceTone surfaceTone,  CornerRadiusStyle cornerRadius,  DisplayDensity density,  TypographyScale typographyScale,  bool compactMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemePreferences() when $default != null:
return $default(_that.accentKey,_that.customAccentSeed,_that.surfaceTone,_that.cornerRadius,_that.density,_that.typographyScale,_that.compactMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accentKey,  int customAccentSeed,  SurfaceTone surfaceTone,  CornerRadiusStyle cornerRadius,  DisplayDensity density,  TypographyScale typographyScale,  bool compactMode)  $default,) {final _that = this;
switch (_that) {
case _ThemePreferences():
return $default(_that.accentKey,_that.customAccentSeed,_that.surfaceTone,_that.cornerRadius,_that.density,_that.typographyScale,_that.compactMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accentKey,  int customAccentSeed,  SurfaceTone surfaceTone,  CornerRadiusStyle cornerRadius,  DisplayDensity density,  TypographyScale typographyScale,  bool compactMode)?  $default,) {final _that = this;
switch (_that) {
case _ThemePreferences() when $default != null:
return $default(_that.accentKey,_that.customAccentSeed,_that.surfaceTone,_that.cornerRadius,_that.density,_that.typographyScale,_that.compactMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemePreferences extends ThemePreferences {
  const _ThemePreferences({this.accentKey = 'skyBlue', this.customAccentSeed = 0, this.surfaceTone = SurfaceTone.light, this.cornerRadius = CornerRadiusStyle.soft, this.density = DisplayDensity.standard, this.typographyScale = TypographyScale.normal, this.compactMode = false}): super._();
  factory _ThemePreferences.fromJson(Map<String, dynamic> json) => _$ThemePreferencesFromJson(json);

@override@JsonKey() final  String accentKey;
/// ARGB value of the user-picked custom accent colour; 0 = unset.
@override@JsonKey() final  int customAccentSeed;
@override@JsonKey() final  SurfaceTone surfaceTone;
@override@JsonKey() final  CornerRadiusStyle cornerRadius;
@override@JsonKey() final  DisplayDensity density;
@override@JsonKey() final  TypographyScale typographyScale;
@override@JsonKey() final  bool compactMode;

/// Create a copy of ThemePreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemePreferencesCopyWith<_ThemePreferences> get copyWith => __$ThemePreferencesCopyWithImpl<_ThemePreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemePreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemePreferences&&(identical(other.accentKey, accentKey) || other.accentKey == accentKey)&&(identical(other.customAccentSeed, customAccentSeed) || other.customAccentSeed == customAccentSeed)&&(identical(other.surfaceTone, surfaceTone) || other.surfaceTone == surfaceTone)&&(identical(other.cornerRadius, cornerRadius) || other.cornerRadius == cornerRadius)&&(identical(other.density, density) || other.density == density)&&(identical(other.typographyScale, typographyScale) || other.typographyScale == typographyScale)&&(identical(other.compactMode, compactMode) || other.compactMode == compactMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accentKey,customAccentSeed,surfaceTone,cornerRadius,density,typographyScale,compactMode);

@override
String toString() {
  return 'ThemePreferences(accentKey: $accentKey, customAccentSeed: $customAccentSeed, surfaceTone: $surfaceTone, cornerRadius: $cornerRadius, density: $density, typographyScale: $typographyScale, compactMode: $compactMode)';
}


}

/// @nodoc
abstract mixin class _$ThemePreferencesCopyWith<$Res> implements $ThemePreferencesCopyWith<$Res> {
  factory _$ThemePreferencesCopyWith(_ThemePreferences value, $Res Function(_ThemePreferences) _then) = __$ThemePreferencesCopyWithImpl;
@override @useResult
$Res call({
 String accentKey, int customAccentSeed, SurfaceTone surfaceTone, CornerRadiusStyle cornerRadius, DisplayDensity density, TypographyScale typographyScale, bool compactMode
});




}
/// @nodoc
class __$ThemePreferencesCopyWithImpl<$Res>
    implements _$ThemePreferencesCopyWith<$Res> {
  __$ThemePreferencesCopyWithImpl(this._self, this._then);

  final _ThemePreferences _self;
  final $Res Function(_ThemePreferences) _then;

/// Create a copy of ThemePreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accentKey = null,Object? customAccentSeed = null,Object? surfaceTone = null,Object? cornerRadius = null,Object? density = null,Object? typographyScale = null,Object? compactMode = null,}) {
  return _then(_ThemePreferences(
accentKey: null == accentKey ? _self.accentKey : accentKey // ignore: cast_nullable_to_non_nullable
as String,customAccentSeed: null == customAccentSeed ? _self.customAccentSeed : customAccentSeed // ignore: cast_nullable_to_non_nullable
as int,surfaceTone: null == surfaceTone ? _self.surfaceTone : surfaceTone // ignore: cast_nullable_to_non_nullable
as SurfaceTone,cornerRadius: null == cornerRadius ? _self.cornerRadius : cornerRadius // ignore: cast_nullable_to_non_nullable
as CornerRadiusStyle,density: null == density ? _self.density : density // ignore: cast_nullable_to_non_nullable
as DisplayDensity,typographyScale: null == typographyScale ? _self.typographyScale : typographyScale // ignore: cast_nullable_to_non_nullable
as TypographyScale,compactMode: null == compactMode ? _self.compactMode : compactMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

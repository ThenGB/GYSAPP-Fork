// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'initial_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InitialState {

 bool get isLoading; bool get isLoaded; bool get isFailed; String get message; bool get isFreshInstall; String get themeMode; int get configFetchTimeoutSeconds; int get configFetchIntervalSeconds; double get defaultTextScale; String get defaultFont; String get accentKey; ThemePreferences get themePreferences;
/// Create a copy of InitialState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitialStateCopyWith<InitialState> get copyWith => _$InitialStateCopyWithImpl<InitialState>(this as InitialState, _$identity);

  /// Serializes this InitialState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitialState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoaded, isLoaded) || other.isLoaded == isLoaded)&&(identical(other.isFailed, isFailed) || other.isFailed == isFailed)&&(identical(other.message, message) || other.message == message)&&(identical(other.isFreshInstall, isFreshInstall) || other.isFreshInstall == isFreshInstall)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.configFetchTimeoutSeconds, configFetchTimeoutSeconds) || other.configFetchTimeoutSeconds == configFetchTimeoutSeconds)&&(identical(other.configFetchIntervalSeconds, configFetchIntervalSeconds) || other.configFetchIntervalSeconds == configFetchIntervalSeconds)&&(identical(other.defaultTextScale, defaultTextScale) || other.defaultTextScale == defaultTextScale)&&(identical(other.defaultFont, defaultFont) || other.defaultFont == defaultFont)&&(identical(other.accentKey, accentKey) || other.accentKey == accentKey)&&(identical(other.themePreferences, themePreferences) || other.themePreferences == themePreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isLoading,isLoaded,isFailed,message,isFreshInstall,themeMode,configFetchTimeoutSeconds,configFetchIntervalSeconds,defaultTextScale,defaultFont,accentKey,themePreferences);

@override
String toString() {
  return 'InitialState(isLoading: $isLoading, isLoaded: $isLoaded, isFailed: $isFailed, message: $message, isFreshInstall: $isFreshInstall, themeMode: $themeMode, configFetchTimeoutSeconds: $configFetchTimeoutSeconds, configFetchIntervalSeconds: $configFetchIntervalSeconds, defaultTextScale: $defaultTextScale, defaultFont: $defaultFont, accentKey: $accentKey, themePreferences: $themePreferences)';
}


}

/// @nodoc
abstract mixin class $InitialStateCopyWith<$Res>  {
  factory $InitialStateCopyWith(InitialState value, $Res Function(InitialState) _then) = _$InitialStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isLoaded, bool isFailed, String message, bool isFreshInstall, String themeMode, int configFetchTimeoutSeconds, int configFetchIntervalSeconds, double defaultTextScale, String defaultFont, String accentKey, ThemePreferences themePreferences
});


$ThemePreferencesCopyWith<$Res> get themePreferences;

}
/// @nodoc
class _$InitialStateCopyWithImpl<$Res>
    implements $InitialStateCopyWith<$Res> {
  _$InitialStateCopyWithImpl(this._self, this._then);

  final InitialState _self;
  final $Res Function(InitialState) _then;

/// Create a copy of InitialState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isLoaded = null,Object? isFailed = null,Object? message = null,Object? isFreshInstall = null,Object? themeMode = null,Object? configFetchTimeoutSeconds = null,Object? configFetchIntervalSeconds = null,Object? defaultTextScale = null,Object? defaultFont = null,Object? accentKey = null,Object? themePreferences = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoaded: null == isLoaded ? _self.isLoaded : isLoaded // ignore: cast_nullable_to_non_nullable
as bool,isFailed: null == isFailed ? _self.isFailed : isFailed // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isFreshInstall: null == isFreshInstall ? _self.isFreshInstall : isFreshInstall // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,configFetchTimeoutSeconds: null == configFetchTimeoutSeconds ? _self.configFetchTimeoutSeconds : configFetchTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,configFetchIntervalSeconds: null == configFetchIntervalSeconds ? _self.configFetchIntervalSeconds : configFetchIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,defaultTextScale: null == defaultTextScale ? _self.defaultTextScale : defaultTextScale // ignore: cast_nullable_to_non_nullable
as double,defaultFont: null == defaultFont ? _self.defaultFont : defaultFont // ignore: cast_nullable_to_non_nullable
as String,accentKey: null == accentKey ? _self.accentKey : accentKey // ignore: cast_nullable_to_non_nullable
as String,themePreferences: null == themePreferences ? _self.themePreferences : themePreferences // ignore: cast_nullable_to_non_nullable
as ThemePreferences,
  ));
}
/// Create a copy of InitialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePreferencesCopyWith<$Res> get themePreferences {
  
  return $ThemePreferencesCopyWith<$Res>(_self.themePreferences, (value) {
    return _then(_self.copyWith(themePreferences: value));
  });
}
}


/// Adds pattern-matching-related methods to [InitialState].
extension InitialStatePatterns on InitialState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitialState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitialState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitialState value)  $default,){
final _that = this;
switch (_that) {
case _InitialState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitialState value)?  $default,){
final _that = this;
switch (_that) {
case _InitialState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isLoaded,  bool isFailed,  String message,  bool isFreshInstall,  String themeMode,  int configFetchTimeoutSeconds,  int configFetchIntervalSeconds,  double defaultTextScale,  String defaultFont,  String accentKey,  ThemePreferences themePreferences)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitialState() when $default != null:
return $default(_that.isLoading,_that.isLoaded,_that.isFailed,_that.message,_that.isFreshInstall,_that.themeMode,_that.configFetchTimeoutSeconds,_that.configFetchIntervalSeconds,_that.defaultTextScale,_that.defaultFont,_that.accentKey,_that.themePreferences);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isLoaded,  bool isFailed,  String message,  bool isFreshInstall,  String themeMode,  int configFetchTimeoutSeconds,  int configFetchIntervalSeconds,  double defaultTextScale,  String defaultFont,  String accentKey,  ThemePreferences themePreferences)  $default,) {final _that = this;
switch (_that) {
case _InitialState():
return $default(_that.isLoading,_that.isLoaded,_that.isFailed,_that.message,_that.isFreshInstall,_that.themeMode,_that.configFetchTimeoutSeconds,_that.configFetchIntervalSeconds,_that.defaultTextScale,_that.defaultFont,_that.accentKey,_that.themePreferences);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isLoaded,  bool isFailed,  String message,  bool isFreshInstall,  String themeMode,  int configFetchTimeoutSeconds,  int configFetchIntervalSeconds,  double defaultTextScale,  String defaultFont,  String accentKey,  ThemePreferences themePreferences)?  $default,) {final _that = this;
switch (_that) {
case _InitialState() when $default != null:
return $default(_that.isLoading,_that.isLoaded,_that.isFailed,_that.message,_that.isFreshInstall,_that.themeMode,_that.configFetchTimeoutSeconds,_that.configFetchIntervalSeconds,_that.defaultTextScale,_that.defaultFont,_that.accentKey,_that.themePreferences);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InitialState extends InitialState {
  const _InitialState({this.isLoading = false, this.isLoaded = false, this.isFailed = false, this.message = '', this.isFreshInstall = true, this.themeMode = 'light', this.configFetchTimeoutSeconds = 5, this.configFetchIntervalSeconds = 10, this.defaultTextScale = 1.0, this.defaultFont = 'Roboto', this.accentKey = 'skyBlue', this.themePreferences = const ThemePreferences()}): super._();
  factory _InitialState.fromJson(Map<String, dynamic> json) => _$InitialStateFromJson(json);

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoaded;
@override@JsonKey() final  bool isFailed;
@override@JsonKey() final  String message;
@override@JsonKey() final  bool isFreshInstall;
@override@JsonKey() final  String themeMode;
@override@JsonKey() final  int configFetchTimeoutSeconds;
@override@JsonKey() final  int configFetchIntervalSeconds;
@override@JsonKey() final  double defaultTextScale;
@override@JsonKey() final  String defaultFont;
@override@JsonKey() final  String accentKey;
@override@JsonKey() final  ThemePreferences themePreferences;

/// Create a copy of InitialState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitialStateCopyWith<_InitialState> get copyWith => __$InitialStateCopyWithImpl<_InitialState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InitialStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitialState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoaded, isLoaded) || other.isLoaded == isLoaded)&&(identical(other.isFailed, isFailed) || other.isFailed == isFailed)&&(identical(other.message, message) || other.message == message)&&(identical(other.isFreshInstall, isFreshInstall) || other.isFreshInstall == isFreshInstall)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.configFetchTimeoutSeconds, configFetchTimeoutSeconds) || other.configFetchTimeoutSeconds == configFetchTimeoutSeconds)&&(identical(other.configFetchIntervalSeconds, configFetchIntervalSeconds) || other.configFetchIntervalSeconds == configFetchIntervalSeconds)&&(identical(other.defaultTextScale, defaultTextScale) || other.defaultTextScale == defaultTextScale)&&(identical(other.defaultFont, defaultFont) || other.defaultFont == defaultFont)&&(identical(other.accentKey, accentKey) || other.accentKey == accentKey)&&(identical(other.themePreferences, themePreferences) || other.themePreferences == themePreferences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isLoading,isLoaded,isFailed,message,isFreshInstall,themeMode,configFetchTimeoutSeconds,configFetchIntervalSeconds,defaultTextScale,defaultFont,accentKey,themePreferences);

@override
String toString() {
  return 'InitialState(isLoading: $isLoading, isLoaded: $isLoaded, isFailed: $isFailed, message: $message, isFreshInstall: $isFreshInstall, themeMode: $themeMode, configFetchTimeoutSeconds: $configFetchTimeoutSeconds, configFetchIntervalSeconds: $configFetchIntervalSeconds, defaultTextScale: $defaultTextScale, defaultFont: $defaultFont, accentKey: $accentKey, themePreferences: $themePreferences)';
}


}

/// @nodoc
abstract mixin class _$InitialStateCopyWith<$Res> implements $InitialStateCopyWith<$Res> {
  factory _$InitialStateCopyWith(_InitialState value, $Res Function(_InitialState) _then) = __$InitialStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isLoaded, bool isFailed, String message, bool isFreshInstall, String themeMode, int configFetchTimeoutSeconds, int configFetchIntervalSeconds, double defaultTextScale, String defaultFont, String accentKey, ThemePreferences themePreferences
});


@override $ThemePreferencesCopyWith<$Res> get themePreferences;

}
/// @nodoc
class __$InitialStateCopyWithImpl<$Res>
    implements _$InitialStateCopyWith<$Res> {
  __$InitialStateCopyWithImpl(this._self, this._then);

  final _InitialState _self;
  final $Res Function(_InitialState) _then;

/// Create a copy of InitialState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isLoaded = null,Object? isFailed = null,Object? message = null,Object? isFreshInstall = null,Object? themeMode = null,Object? configFetchTimeoutSeconds = null,Object? configFetchIntervalSeconds = null,Object? defaultTextScale = null,Object? defaultFont = null,Object? accentKey = null,Object? themePreferences = null,}) {
  return _then(_InitialState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoaded: null == isLoaded ? _self.isLoaded : isLoaded // ignore: cast_nullable_to_non_nullable
as bool,isFailed: null == isFailed ? _self.isFailed : isFailed // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isFreshInstall: null == isFreshInstall ? _self.isFreshInstall : isFreshInstall // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,configFetchTimeoutSeconds: null == configFetchTimeoutSeconds ? _self.configFetchTimeoutSeconds : configFetchTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,configFetchIntervalSeconds: null == configFetchIntervalSeconds ? _self.configFetchIntervalSeconds : configFetchIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,defaultTextScale: null == defaultTextScale ? _self.defaultTextScale : defaultTextScale // ignore: cast_nullable_to_non_nullable
as double,defaultFont: null == defaultFont ? _self.defaultFont : defaultFont // ignore: cast_nullable_to_non_nullable
as String,accentKey: null == accentKey ? _self.accentKey : accentKey // ignore: cast_nullable_to_non_nullable
as String,themePreferences: null == themePreferences ? _self.themePreferences : themePreferences // ignore: cast_nullable_to_non_nullable
as ThemePreferences,
  ));
}

/// Create a copy of InitialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePreferencesCopyWith<$Res> get themePreferences {
  
  return $ThemePreferencesCopyWith<$Res>(_self.themePreferences, (value) {
    return _then(_self.copyWith(themePreferences: value));
  });
}
}

// dart format on

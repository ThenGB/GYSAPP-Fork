// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeState {

 bool get isLoading; List<Sauh> get sauhs; List<TrueVoice> get trueVoices; List<Menulink> get menuLinks; bool get isSuaraSejatiEnabled; bool get isSauhEnabled;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);

  /// Serializes this HomeState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.sauhs, sauhs)&&const DeepCollectionEquality().equals(other.trueVoices, trueVoices)&&const DeepCollectionEquality().equals(other.menuLinks, menuLinks)&&(identical(other.isSuaraSejatiEnabled, isSuaraSejatiEnabled) || other.isSuaraSejatiEnabled == isSuaraSejatiEnabled)&&(identical(other.isSauhEnabled, isSauhEnabled) || other.isSauhEnabled == isSauhEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(sauhs),const DeepCollectionEquality().hash(trueVoices),const DeepCollectionEquality().hash(menuLinks),isSuaraSejatiEnabled,isSauhEnabled);

@override
String toString() {
  return 'HomeState(isLoading: $isLoading, sauhs: $sauhs, trueVoices: $trueVoices, menuLinks: $menuLinks, isSuaraSejatiEnabled: $isSuaraSejatiEnabled, isSauhEnabled: $isSauhEnabled)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<Sauh> sauhs, List<TrueVoice> trueVoices, List<Menulink> menuLinks, bool isSuaraSejatiEnabled, bool isSauhEnabled
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? sauhs = null,Object? trueVoices = null,Object? menuLinks = null,Object? isSuaraSejatiEnabled = null,Object? isSauhEnabled = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,sauhs: null == sauhs ? _self.sauhs : sauhs // ignore: cast_nullable_to_non_nullable
as List<Sauh>,trueVoices: null == trueVoices ? _self.trueVoices : trueVoices // ignore: cast_nullable_to_non_nullable
as List<TrueVoice>,menuLinks: null == menuLinks ? _self.menuLinks : menuLinks // ignore: cast_nullable_to_non_nullable
as List<Menulink>,isSuaraSejatiEnabled: null == isSuaraSejatiEnabled ? _self.isSuaraSejatiEnabled : isSuaraSejatiEnabled // ignore: cast_nullable_to_non_nullable
as bool,isSauhEnabled: null == isSauhEnabled ? _self.isSauhEnabled : isSauhEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<Sauh> sauhs,  List<TrueVoice> trueVoices,  List<Menulink> menuLinks,  bool isSuaraSejatiEnabled,  bool isSauhEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.isLoading,_that.sauhs,_that.trueVoices,_that.menuLinks,_that.isSuaraSejatiEnabled,_that.isSauhEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<Sauh> sauhs,  List<TrueVoice> trueVoices,  List<Menulink> menuLinks,  bool isSuaraSejatiEnabled,  bool isSauhEnabled)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.isLoading,_that.sauhs,_that.trueVoices,_that.menuLinks,_that.isSuaraSejatiEnabled,_that.isSauhEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<Sauh> sauhs,  List<TrueVoice> trueVoices,  List<Menulink> menuLinks,  bool isSuaraSejatiEnabled,  bool isSauhEnabled)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.isLoading,_that.sauhs,_that.trueVoices,_that.menuLinks,_that.isSuaraSejatiEnabled,_that.isSauhEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeState extends HomeState {
  const _HomeState({this.isLoading = false, final  List<Sauh> sauhs = const [], final  List<TrueVoice> trueVoices = const [], final  List<Menulink> menuLinks = const [], this.isSuaraSejatiEnabled = false, this.isSauhEnabled = false}): _sauhs = sauhs,_trueVoices = trueVoices,_menuLinks = menuLinks,super._();
  factory _HomeState.fromJson(Map<String, dynamic> json) => _$HomeStateFromJson(json);

@override@JsonKey() final  bool isLoading;
 final  List<Sauh> _sauhs;
@override@JsonKey() List<Sauh> get sauhs {
  if (_sauhs is EqualUnmodifiableListView) return _sauhs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sauhs);
}

 final  List<TrueVoice> _trueVoices;
@override@JsonKey() List<TrueVoice> get trueVoices {
  if (_trueVoices is EqualUnmodifiableListView) return _trueVoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trueVoices);
}

 final  List<Menulink> _menuLinks;
@override@JsonKey() List<Menulink> get menuLinks {
  if (_menuLinks is EqualUnmodifiableListView) return _menuLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_menuLinks);
}

@override@JsonKey() final  bool isSuaraSejatiEnabled;
@override@JsonKey() final  bool isSauhEnabled;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._sauhs, _sauhs)&&const DeepCollectionEquality().equals(other._trueVoices, _trueVoices)&&const DeepCollectionEquality().equals(other._menuLinks, _menuLinks)&&(identical(other.isSuaraSejatiEnabled, isSuaraSejatiEnabled) || other.isSuaraSejatiEnabled == isSuaraSejatiEnabled)&&(identical(other.isSauhEnabled, isSauhEnabled) || other.isSauhEnabled == isSauhEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_sauhs),const DeepCollectionEquality().hash(_trueVoices),const DeepCollectionEquality().hash(_menuLinks),isSuaraSejatiEnabled,isSauhEnabled);

@override
String toString() {
  return 'HomeState(isLoading: $isLoading, sauhs: $sauhs, trueVoices: $trueVoices, menuLinks: $menuLinks, isSuaraSejatiEnabled: $isSuaraSejatiEnabled, isSauhEnabled: $isSauhEnabled)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<Sauh> sauhs, List<TrueVoice> trueVoices, List<Menulink> menuLinks, bool isSuaraSejatiEnabled, bool isSauhEnabled
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? sauhs = null,Object? trueVoices = null,Object? menuLinks = null,Object? isSuaraSejatiEnabled = null,Object? isSauhEnabled = null,}) {
  return _then(_HomeState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,sauhs: null == sauhs ? _self._sauhs : sauhs // ignore: cast_nullable_to_non_nullable
as List<Sauh>,trueVoices: null == trueVoices ? _self._trueVoices : trueVoices // ignore: cast_nullable_to_non_nullable
as List<TrueVoice>,menuLinks: null == menuLinks ? _self._menuLinks : menuLinks // ignore: cast_nullable_to_non_nullable
as List<Menulink>,isSuaraSejatiEnabled: null == isSuaraSejatiEnabled ? _self.isSuaraSejatiEnabled : isSuaraSejatiEnabled // ignore: cast_nullable_to_non_nullable
as bool,isSauhEnabled: null == isSauhEnabled ? _self.isSauhEnabled : isSauhEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

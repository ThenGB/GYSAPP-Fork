// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config_literature_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConfigLiterature {

@JsonKey(name: 'kesaksian') String get kesaksian;@JsonKey(name: 'wartasejati') String get wartaSejati;@JsonKey(name: 'panduanalkitab') String get panduanAlkitab;@JsonKey(name: 'renungan') String get renungan;@JsonKey(name: 'pelitakecil') String get pelitaKecil;
/// Create a copy of ConfigLiterature
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigLiteratureCopyWith<ConfigLiterature> get copyWith => _$ConfigLiteratureCopyWithImpl<ConfigLiterature>(this as ConfigLiterature, _$identity);

  /// Serializes this ConfigLiterature to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfigLiterature&&(identical(other.kesaksian, kesaksian) || other.kesaksian == kesaksian)&&(identical(other.wartaSejati, wartaSejati) || other.wartaSejati == wartaSejati)&&(identical(other.panduanAlkitab, panduanAlkitab) || other.panduanAlkitab == panduanAlkitab)&&(identical(other.renungan, renungan) || other.renungan == renungan)&&(identical(other.pelitaKecil, pelitaKecil) || other.pelitaKecil == pelitaKecil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kesaksian,wartaSejati,panduanAlkitab,renungan,pelitaKecil);

@override
String toString() {
  return 'ConfigLiterature(kesaksian: $kesaksian, wartaSejati: $wartaSejati, panduanAlkitab: $panduanAlkitab, renungan: $renungan, pelitaKecil: $pelitaKecil)';
}


}

/// @nodoc
abstract mixin class $ConfigLiteratureCopyWith<$Res>  {
  factory $ConfigLiteratureCopyWith(ConfigLiterature value, $Res Function(ConfigLiterature) _then) = _$ConfigLiteratureCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'kesaksian') String kesaksian,@JsonKey(name: 'wartasejati') String wartaSejati,@JsonKey(name: 'panduanalkitab') String panduanAlkitab,@JsonKey(name: 'renungan') String renungan,@JsonKey(name: 'pelitakecil') String pelitaKecil
});




}
/// @nodoc
class _$ConfigLiteratureCopyWithImpl<$Res>
    implements $ConfigLiteratureCopyWith<$Res> {
  _$ConfigLiteratureCopyWithImpl(this._self, this._then);

  final ConfigLiterature _self;
  final $Res Function(ConfigLiterature) _then;

/// Create a copy of ConfigLiterature
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kesaksian = null,Object? wartaSejati = null,Object? panduanAlkitab = null,Object? renungan = null,Object? pelitaKecil = null,}) {
  return _then(_self.copyWith(
kesaksian: null == kesaksian ? _self.kesaksian : kesaksian // ignore: cast_nullable_to_non_nullable
as String,wartaSejati: null == wartaSejati ? _self.wartaSejati : wartaSejati // ignore: cast_nullable_to_non_nullable
as String,panduanAlkitab: null == panduanAlkitab ? _self.panduanAlkitab : panduanAlkitab // ignore: cast_nullable_to_non_nullable
as String,renungan: null == renungan ? _self.renungan : renungan // ignore: cast_nullable_to_non_nullable
as String,pelitaKecil: null == pelitaKecil ? _self.pelitaKecil : pelitaKecil // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfigLiterature].
extension ConfigLiteraturePatterns on ConfigLiterature {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfigLiterature value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfigLiterature() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfigLiterature value)  $default,){
final _that = this;
switch (_that) {
case _ConfigLiterature():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfigLiterature value)?  $default,){
final _that = this;
switch (_that) {
case _ConfigLiterature() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'kesaksian')  String kesaksian, @JsonKey(name: 'wartasejati')  String wartaSejati, @JsonKey(name: 'panduanalkitab')  String panduanAlkitab, @JsonKey(name: 'renungan')  String renungan, @JsonKey(name: 'pelitakecil')  String pelitaKecil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfigLiterature() when $default != null:
return $default(_that.kesaksian,_that.wartaSejati,_that.panduanAlkitab,_that.renungan,_that.pelitaKecil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'kesaksian')  String kesaksian, @JsonKey(name: 'wartasejati')  String wartaSejati, @JsonKey(name: 'panduanalkitab')  String panduanAlkitab, @JsonKey(name: 'renungan')  String renungan, @JsonKey(name: 'pelitakecil')  String pelitaKecil)  $default,) {final _that = this;
switch (_that) {
case _ConfigLiterature():
return $default(_that.kesaksian,_that.wartaSejati,_that.panduanAlkitab,_that.renungan,_that.pelitaKecil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'kesaksian')  String kesaksian, @JsonKey(name: 'wartasejati')  String wartaSejati, @JsonKey(name: 'panduanalkitab')  String panduanAlkitab, @JsonKey(name: 'renungan')  String renungan, @JsonKey(name: 'pelitakecil')  String pelitaKecil)?  $default,) {final _that = this;
switch (_that) {
case _ConfigLiterature() when $default != null:
return $default(_that.kesaksian,_that.wartaSejati,_that.panduanAlkitab,_that.renungan,_that.pelitaKecil);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfigLiterature extends ConfigLiterature {
  const _ConfigLiterature({@JsonKey(name: 'kesaksian') this.kesaksian = '#posts-table-1 > tbody > tr > td > a', @JsonKey(name: 'wartasejati') this.wartaSejati = '#posts-table-2 > tbody > tr > td > a', @JsonKey(name: 'panduanalkitab') this.panduanAlkitab = 'div.module.module-accordion.tb_9pdq304 > ul > li > div > div > div > table > tbody > tr > td > a', @JsonKey(name: 'renungan') this.renungan = 'div.module.module-accordion.tb_1uum169 > ul > li > div > div > div > table > tbody > tr > td > a', @JsonKey(name: 'pelitakecil') this.pelitaKecil = '#posts-table-3 > tbody > tr > td > a'}): super._();
  factory _ConfigLiterature.fromJson(Map<String, dynamic> json) => _$ConfigLiteratureFromJson(json);

@override@JsonKey(name: 'kesaksian') final  String kesaksian;
@override@JsonKey(name: 'wartasejati') final  String wartaSejati;
@override@JsonKey(name: 'panduanalkitab') final  String panduanAlkitab;
@override@JsonKey(name: 'renungan') final  String renungan;
@override@JsonKey(name: 'pelitakecil') final  String pelitaKecil;

/// Create a copy of ConfigLiterature
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigLiteratureCopyWith<_ConfigLiterature> get copyWith => __$ConfigLiteratureCopyWithImpl<_ConfigLiterature>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigLiteratureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfigLiterature&&(identical(other.kesaksian, kesaksian) || other.kesaksian == kesaksian)&&(identical(other.wartaSejati, wartaSejati) || other.wartaSejati == wartaSejati)&&(identical(other.panduanAlkitab, panduanAlkitab) || other.panduanAlkitab == panduanAlkitab)&&(identical(other.renungan, renungan) || other.renungan == renungan)&&(identical(other.pelitaKecil, pelitaKecil) || other.pelitaKecil == pelitaKecil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kesaksian,wartaSejati,panduanAlkitab,renungan,pelitaKecil);

@override
String toString() {
  return 'ConfigLiterature(kesaksian: $kesaksian, wartaSejati: $wartaSejati, panduanAlkitab: $panduanAlkitab, renungan: $renungan, pelitaKecil: $pelitaKecil)';
}


}

/// @nodoc
abstract mixin class _$ConfigLiteratureCopyWith<$Res> implements $ConfigLiteratureCopyWith<$Res> {
  factory _$ConfigLiteratureCopyWith(_ConfigLiterature value, $Res Function(_ConfigLiterature) _then) = __$ConfigLiteratureCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'kesaksian') String kesaksian,@JsonKey(name: 'wartasejati') String wartaSejati,@JsonKey(name: 'panduanalkitab') String panduanAlkitab,@JsonKey(name: 'renungan') String renungan,@JsonKey(name: 'pelitakecil') String pelitaKecil
});




}
/// @nodoc
class __$ConfigLiteratureCopyWithImpl<$Res>
    implements _$ConfigLiteratureCopyWith<$Res> {
  __$ConfigLiteratureCopyWithImpl(this._self, this._then);

  final _ConfigLiterature _self;
  final $Res Function(_ConfigLiterature) _then;

/// Create a copy of ConfigLiterature
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kesaksian = null,Object? wartaSejati = null,Object? panduanAlkitab = null,Object? renungan = null,Object? pelitaKecil = null,}) {
  return _then(_ConfigLiterature(
kesaksian: null == kesaksian ? _self.kesaksian : kesaksian // ignore: cast_nullable_to_non_nullable
as String,wartaSejati: null == wartaSejati ? _self.wartaSejati : wartaSejati // ignore: cast_nullable_to_non_nullable
as String,panduanAlkitab: null == panduanAlkitab ? _self.panduanAlkitab : panduanAlkitab // ignore: cast_nullable_to_non_nullable
as String,renungan: null == renungan ? _self.renungan : renungan // ignore: cast_nullable_to_non_nullable
as String,pelitaKecil: null == pelitaKecil ? _self.pelitaKecil : pelitaKecil // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

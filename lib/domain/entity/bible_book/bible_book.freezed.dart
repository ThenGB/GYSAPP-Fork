// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BibleBook {

 int get id;@JsonKey(name: 'bs') String? get shortName;@JsonKey(name: 'bl') String? get longName;@JsonKey(name: 'c') int? get chapterCount;
/// Create a copy of BibleBook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BibleBookCopyWith<BibleBook> get copyWith => _$BibleBookCopyWithImpl<BibleBook>(this as BibleBook, _$identity);

  /// Serializes this BibleBook to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BibleBook&&(identical(other.id, id) || other.id == id)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.longName, longName) || other.longName == longName)&&(identical(other.chapterCount, chapterCount) || other.chapterCount == chapterCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shortName,longName,chapterCount);

@override
String toString() {
  return 'BibleBook(id: $id, shortName: $shortName, longName: $longName, chapterCount: $chapterCount)';
}


}

/// @nodoc
abstract mixin class $BibleBookCopyWith<$Res>  {
  factory $BibleBookCopyWith(BibleBook value, $Res Function(BibleBook) _then) = _$BibleBookCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'bs') String? shortName,@JsonKey(name: 'bl') String? longName,@JsonKey(name: 'c') int? chapterCount
});




}
/// @nodoc
class _$BibleBookCopyWithImpl<$Res>
    implements $BibleBookCopyWith<$Res> {
  _$BibleBookCopyWithImpl(this._self, this._then);

  final BibleBook _self;
  final $Res Function(BibleBook) _then;

/// Create a copy of BibleBook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shortName = freezed,Object? longName = freezed,Object? chapterCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,longName: freezed == longName ? _self.longName : longName // ignore: cast_nullable_to_non_nullable
as String?,chapterCount: freezed == chapterCount ? _self.chapterCount : chapterCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BibleBook].
extension BibleBookPatterns on BibleBook {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BibleBook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BibleBook() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BibleBook value)  $default,){
final _that = this;
switch (_that) {
case _BibleBook():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BibleBook value)?  $default,){
final _that = this;
switch (_that) {
case _BibleBook() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'bs')  String? shortName, @JsonKey(name: 'bl')  String? longName, @JsonKey(name: 'c')  int? chapterCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BibleBook() when $default != null:
return $default(_that.id,_that.shortName,_that.longName,_that.chapterCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'bs')  String? shortName, @JsonKey(name: 'bl')  String? longName, @JsonKey(name: 'c')  int? chapterCount)  $default,) {final _that = this;
switch (_that) {
case _BibleBook():
return $default(_that.id,_that.shortName,_that.longName,_that.chapterCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'bs')  String? shortName, @JsonKey(name: 'bl')  String? longName, @JsonKey(name: 'c')  int? chapterCount)?  $default,) {final _that = this;
switch (_that) {
case _BibleBook() when $default != null:
return $default(_that.id,_that.shortName,_that.longName,_that.chapterCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BibleBook extends BibleBook {
  const _BibleBook({required this.id, @JsonKey(name: 'bs') this.shortName, @JsonKey(name: 'bl') this.longName, @JsonKey(name: 'c') this.chapterCount}): super._();
  factory _BibleBook.fromJson(Map<String, dynamic> json) => _$BibleBookFromJson(json);

@override final  int id;
@override@JsonKey(name: 'bs') final  String? shortName;
@override@JsonKey(name: 'bl') final  String? longName;
@override@JsonKey(name: 'c') final  int? chapterCount;

/// Create a copy of BibleBook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BibleBookCopyWith<_BibleBook> get copyWith => __$BibleBookCopyWithImpl<_BibleBook>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BibleBookToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BibleBook&&(identical(other.id, id) || other.id == id)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.longName, longName) || other.longName == longName)&&(identical(other.chapterCount, chapterCount) || other.chapterCount == chapterCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shortName,longName,chapterCount);

@override
String toString() {
  return 'BibleBook(id: $id, shortName: $shortName, longName: $longName, chapterCount: $chapterCount)';
}


}

/// @nodoc
abstract mixin class _$BibleBookCopyWith<$Res> implements $BibleBookCopyWith<$Res> {
  factory _$BibleBookCopyWith(_BibleBook value, $Res Function(_BibleBook) _then) = __$BibleBookCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'bs') String? shortName,@JsonKey(name: 'bl') String? longName,@JsonKey(name: 'c') int? chapterCount
});




}
/// @nodoc
class __$BibleBookCopyWithImpl<$Res>
    implements _$BibleBookCopyWith<$Res> {
  __$BibleBookCopyWithImpl(this._self, this._then);

  final _BibleBook _self;
  final $Res Function(_BibleBook) _then;

/// Create a copy of BibleBook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shortName = freezed,Object? longName = freezed,Object? chapterCount = freezed,}) {
  return _then(_BibleBook(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,longName: freezed == longName ? _self.longName : longName // ignore: cast_nullable_to_non_nullable
as String?,chapterCount: freezed == chapterCount ? _self.chapterCount : chapterCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faith_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FaithNote {

 int get id; List<int> get verses; String? get text; DateTime get createdDate; DateTime get updatedDate;
/// Create a copy of FaithNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FaithNoteCopyWith<FaithNote> get copyWith => _$FaithNoteCopyWithImpl<FaithNote>(this as FaithNote, _$identity);

  /// Serializes this FaithNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FaithNote&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.verses, verses)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.updatedDate, updatedDate) || other.updatedDate == updatedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(verses),text,createdDate,updatedDate);

@override
String toString() {
  return 'FaithNote(id: $id, verses: $verses, text: $text, createdDate: $createdDate, updatedDate: $updatedDate)';
}


}

/// @nodoc
abstract mixin class $FaithNoteCopyWith<$Res>  {
  factory $FaithNoteCopyWith(FaithNote value, $Res Function(FaithNote) _then) = _$FaithNoteCopyWithImpl;
@useResult
$Res call({
 int id, List<int> verses, String? text, DateTime createdDate, DateTime updatedDate
});




}
/// @nodoc
class _$FaithNoteCopyWithImpl<$Res>
    implements $FaithNoteCopyWith<$Res> {
  _$FaithNoteCopyWithImpl(this._self, this._then);

  final FaithNote _self;
  final $Res Function(FaithNote) _then;

/// Create a copy of FaithNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? verses = null,Object? text = freezed,Object? createdDate = null,Object? updatedDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,verses: null == verses ? _self.verses : verses // ignore: cast_nullable_to_non_nullable
as List<int>,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,createdDate: null == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime,updatedDate: null == updatedDate ? _self.updatedDate : updatedDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FaithNote].
extension FaithNotePatterns on FaithNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FaithNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FaithNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FaithNote value)  $default,){
final _that = this;
switch (_that) {
case _FaithNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FaithNote value)?  $default,){
final _that = this;
switch (_that) {
case _FaithNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  List<int> verses,  String? text,  DateTime createdDate,  DateTime updatedDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FaithNote() when $default != null:
return $default(_that.id,_that.verses,_that.text,_that.createdDate,_that.updatedDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  List<int> verses,  String? text,  DateTime createdDate,  DateTime updatedDate)  $default,) {final _that = this;
switch (_that) {
case _FaithNote():
return $default(_that.id,_that.verses,_that.text,_that.createdDate,_that.updatedDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  List<int> verses,  String? text,  DateTime createdDate,  DateTime updatedDate)?  $default,) {final _that = this;
switch (_that) {
case _FaithNote() when $default != null:
return $default(_that.id,_that.verses,_that.text,_that.createdDate,_that.updatedDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FaithNote extends FaithNote {
  const _FaithNote({required this.id, required final  List<int> verses, this.text, required this.createdDate, required this.updatedDate}): _verses = verses,super._();
  factory _FaithNote.fromJson(Map<String, dynamic> json) => _$FaithNoteFromJson(json);

@override final  int id;
 final  List<int> _verses;
@override List<int> get verses {
  if (_verses is EqualUnmodifiableListView) return _verses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_verses);
}

@override final  String? text;
@override final  DateTime createdDate;
@override final  DateTime updatedDate;

/// Create a copy of FaithNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FaithNoteCopyWith<_FaithNote> get copyWith => __$FaithNoteCopyWithImpl<_FaithNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FaithNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FaithNote&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._verses, _verses)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.updatedDate, updatedDate) || other.updatedDate == updatedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_verses),text,createdDate,updatedDate);

@override
String toString() {
  return 'FaithNote(id: $id, verses: $verses, text: $text, createdDate: $createdDate, updatedDate: $updatedDate)';
}


}

/// @nodoc
abstract mixin class _$FaithNoteCopyWith<$Res> implements $FaithNoteCopyWith<$Res> {
  factory _$FaithNoteCopyWith(_FaithNote value, $Res Function(_FaithNote) _then) = __$FaithNoteCopyWithImpl;
@override @useResult
$Res call({
 int id, List<int> verses, String? text, DateTime createdDate, DateTime updatedDate
});




}
/// @nodoc
class __$FaithNoteCopyWithImpl<$Res>
    implements _$FaithNoteCopyWith<$Res> {
  __$FaithNoteCopyWithImpl(this._self, this._then);

  final _FaithNote _self;
  final $Res Function(_FaithNote) _then;

/// Create a copy of FaithNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? verses = null,Object? text = freezed,Object? createdDate = null,Object? updatedDate = null,}) {
  return _then(_FaithNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,verses: null == verses ? _self._verses : verses // ignore: cast_nullable_to_non_nullable
as List<int>,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,createdDate: null == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime,updatedDate: null == updatedDate ? _self.updatedDate : updatedDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

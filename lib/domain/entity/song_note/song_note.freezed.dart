// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SongNote {

 int get id; Song get song; String? get text; DateTime get createdDate; DateTime get updatedDate;
/// Create a copy of SongNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongNoteCopyWith<SongNote> get copyWith => _$SongNoteCopyWithImpl<SongNote>(this as SongNote, _$identity);

  /// Serializes this SongNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SongNote&&(identical(other.id, id) || other.id == id)&&(identical(other.song, song) || other.song == song)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.updatedDate, updatedDate) || other.updatedDate == updatedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,song,text,createdDate,updatedDate);

@override
String toString() {
  return 'SongNote(id: $id, song: $song, text: $text, createdDate: $createdDate, updatedDate: $updatedDate)';
}


}

/// @nodoc
abstract mixin class $SongNoteCopyWith<$Res>  {
  factory $SongNoteCopyWith(SongNote value, $Res Function(SongNote) _then) = _$SongNoteCopyWithImpl;
@useResult
$Res call({
 int id, Song song, String? text, DateTime createdDate, DateTime updatedDate
});


$SongCopyWith<$Res> get song;

}
/// @nodoc
class _$SongNoteCopyWithImpl<$Res>
    implements $SongNoteCopyWith<$Res> {
  _$SongNoteCopyWithImpl(this._self, this._then);

  final SongNote _self;
  final $Res Function(SongNote) _then;

/// Create a copy of SongNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? song = null,Object? text = freezed,Object? createdDate = null,Object? updatedDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,song: null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as Song,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,createdDate: null == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime,updatedDate: null == updatedDate ? _self.updatedDate : updatedDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of SongNote
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res> get song {
  
  return $SongCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}


/// Adds pattern-matching-related methods to [SongNote].
extension SongNotePatterns on SongNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SongNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SongNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SongNote value)  $default,){
final _that = this;
switch (_that) {
case _SongNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SongNote value)?  $default,){
final _that = this;
switch (_that) {
case _SongNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  Song song,  String? text,  DateTime createdDate,  DateTime updatedDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SongNote() when $default != null:
return $default(_that.id,_that.song,_that.text,_that.createdDate,_that.updatedDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  Song song,  String? text,  DateTime createdDate,  DateTime updatedDate)  $default,) {final _that = this;
switch (_that) {
case _SongNote():
return $default(_that.id,_that.song,_that.text,_that.createdDate,_that.updatedDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  Song song,  String? text,  DateTime createdDate,  DateTime updatedDate)?  $default,) {final _that = this;
switch (_that) {
case _SongNote() when $default != null:
return $default(_that.id,_that.song,_that.text,_that.createdDate,_that.updatedDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SongNote extends SongNote {
  const _SongNote({required this.id, required this.song, this.text, required this.createdDate, required this.updatedDate}): super._();
  factory _SongNote.fromJson(Map<String, dynamic> json) => _$SongNoteFromJson(json);

@override final  int id;
@override final  Song song;
@override final  String? text;
@override final  DateTime createdDate;
@override final  DateTime updatedDate;

/// Create a copy of SongNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongNoteCopyWith<_SongNote> get copyWith => __$SongNoteCopyWithImpl<_SongNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SongNote&&(identical(other.id, id) || other.id == id)&&(identical(other.song, song) || other.song == song)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.updatedDate, updatedDate) || other.updatedDate == updatedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,song,text,createdDate,updatedDate);

@override
String toString() {
  return 'SongNote(id: $id, song: $song, text: $text, createdDate: $createdDate, updatedDate: $updatedDate)';
}


}

/// @nodoc
abstract mixin class _$SongNoteCopyWith<$Res> implements $SongNoteCopyWith<$Res> {
  factory _$SongNoteCopyWith(_SongNote value, $Res Function(_SongNote) _then) = __$SongNoteCopyWithImpl;
@override @useResult
$Res call({
 int id, Song song, String? text, DateTime createdDate, DateTime updatedDate
});


@override $SongCopyWith<$Res> get song;

}
/// @nodoc
class __$SongNoteCopyWithImpl<$Res>
    implements _$SongNoteCopyWith<$Res> {
  __$SongNoteCopyWithImpl(this._self, this._then);

  final _SongNote _self;
  final $Res Function(_SongNote) _then;

/// Create a copy of SongNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? song = null,Object? text = freezed,Object? createdDate = null,Object? updatedDate = null,}) {
  return _then(_SongNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,song: null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as Song,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,createdDate: null == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime,updatedDate: null == updatedDate ? _self.updatedDate : updatedDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of SongNote
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res> get song {
  
  return $SongCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}

// dart format on

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SongNote _$SongNoteFromJson(Map<String, dynamic> json) {
  return _SongNote.fromJson(json);
}

/// @nodoc
mixin _$SongNote {
  int get id => throw _privateConstructorUsedError;
  Song get song => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  DateTime get createdDate => throw _privateConstructorUsedError;
  DateTime get updatedDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SongNoteCopyWith<SongNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongNoteCopyWith<$Res> {
  factory $SongNoteCopyWith(SongNote value, $Res Function(SongNote) then) =
      _$SongNoteCopyWithImpl<$Res, SongNote>;
  @useResult
  $Res call(
      {int id,
      Song song,
      String? text,
      DateTime createdDate,
      DateTime updatedDate});

  $SongCopyWith<$Res> get song;
}

/// @nodoc
class _$SongNoteCopyWithImpl<$Res, $Val extends SongNote>
    implements $SongNoteCopyWith<$Res> {
  _$SongNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? song = null,
    Object? text = freezed,
    Object? createdDate = null,
    Object? updatedDate = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      song: null == song
          ? _value.song
          : song // ignore: cast_nullable_to_non_nullable
              as Song,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: null == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedDate: null == updatedDate
          ? _value.updatedDate
          : updatedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SongCopyWith<$Res> get song {
    return $SongCopyWith<$Res>(_value.song, (value) {
      return _then(_value.copyWith(song: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SongNoteImplCopyWith<$Res>
    implements $SongNoteCopyWith<$Res> {
  factory _$$SongNoteImplCopyWith(
          _$SongNoteImpl value, $Res Function(_$SongNoteImpl) then) =
      __$$SongNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      Song song,
      String? text,
      DateTime createdDate,
      DateTime updatedDate});

  @override
  $SongCopyWith<$Res> get song;
}

/// @nodoc
class __$$SongNoteImplCopyWithImpl<$Res>
    extends _$SongNoteCopyWithImpl<$Res, _$SongNoteImpl>
    implements _$$SongNoteImplCopyWith<$Res> {
  __$$SongNoteImplCopyWithImpl(
      _$SongNoteImpl _value, $Res Function(_$SongNoteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? song = null,
    Object? text = freezed,
    Object? createdDate = null,
    Object? updatedDate = null,
  }) {
    return _then(_$SongNoteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      song: null == song
          ? _value.song
          : song // ignore: cast_nullable_to_non_nullable
              as Song,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: null == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedDate: null == updatedDate
          ? _value.updatedDate
          : updatedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SongNoteImpl extends _SongNote {
  const _$SongNoteImpl(
      {required this.id,
      required this.song,
      this.text,
      required this.createdDate,
      required this.updatedDate})
      : super._();

  factory _$SongNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongNoteImplFromJson(json);

  @override
  final int id;
  @override
  final Song song;
  @override
  final String? text;
  @override
  final DateTime createdDate;
  @override
  final DateTime updatedDate;

  @override
  String toString() {
    return 'SongNote(id: $id, song: $song, text: $text, createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongNoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.song, song) || other.song == song) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.updatedDate, updatedDate) ||
                other.updatedDate == updatedDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, song, text, createdDate, updatedDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SongNoteImplCopyWith<_$SongNoteImpl> get copyWith =>
      __$$SongNoteImplCopyWithImpl<_$SongNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongNoteImplToJson(
      this,
    );
  }
}

abstract class _SongNote extends SongNote {
  const factory _SongNote(
      {required final int id,
      required final Song song,
      final String? text,
      required final DateTime createdDate,
      required final DateTime updatedDate}) = _$SongNoteImpl;
  const _SongNote._() : super._();

  factory _SongNote.fromJson(Map<String, dynamic> json) =
      _$SongNoteImpl.fromJson;

  @override
  int get id;
  @override
  Song get song;
  @override
  String? get text;
  @override
  DateTime get createdDate;
  @override
  DateTime get updatedDate;
  @override
  @JsonKey(ignore: true)
  _$$SongNoteImplCopyWith<_$SongNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

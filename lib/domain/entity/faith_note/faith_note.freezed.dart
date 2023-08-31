// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faith_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

FaithNote _$FaithNoteFromJson(Map<String, dynamic> json) {
  return _FaithNote.fromJson(json);
}

/// @nodoc
mixin _$FaithNote {
  int get id => throw _privateConstructorUsedError;
  List<int> get verses => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  DateTime get createdDate => throw _privateConstructorUsedError;
  DateTime get updatedDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FaithNoteCopyWith<FaithNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaithNoteCopyWith<$Res> {
  factory $FaithNoteCopyWith(FaithNote value, $Res Function(FaithNote) then) =
      _$FaithNoteCopyWithImpl<$Res, FaithNote>;
  @useResult
  $Res call(
      {int id,
      List<int> verses,
      String? text,
      DateTime createdDate,
      DateTime updatedDate});
}

/// @nodoc
class _$FaithNoteCopyWithImpl<$Res, $Val extends FaithNote>
    implements $FaithNoteCopyWith<$Res> {
  _$FaithNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? verses = null,
    Object? text = freezed,
    Object? createdDate = null,
    Object? updatedDate = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<int>,
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
}

/// @nodoc
abstract class _$$_FaithNoteCopyWith<$Res> implements $FaithNoteCopyWith<$Res> {
  factory _$$_FaithNoteCopyWith(
          _$_FaithNote value, $Res Function(_$_FaithNote) then) =
      __$$_FaithNoteCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      List<int> verses,
      String? text,
      DateTime createdDate,
      DateTime updatedDate});
}

/// @nodoc
class __$$_FaithNoteCopyWithImpl<$Res>
    extends _$FaithNoteCopyWithImpl<$Res, _$_FaithNote>
    implements _$$_FaithNoteCopyWith<$Res> {
  __$$_FaithNoteCopyWithImpl(
      _$_FaithNote _value, $Res Function(_$_FaithNote) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? verses = null,
    Object? text = freezed,
    Object? createdDate = null,
    Object? updatedDate = null,
  }) {
    return _then(_$_FaithNote(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<int>,
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
class _$_FaithNote extends _FaithNote {
  const _$_FaithNote(
      {required this.id,
      required final List<int> verses,
      this.text,
      required this.createdDate,
      required this.updatedDate})
      : _verses = verses,
        super._();

  factory _$_FaithNote.fromJson(Map<String, dynamic> json) =>
      _$$_FaithNoteFromJson(json);

  @override
  final int id;
  final List<int> _verses;
  @override
  List<int> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

  @override
  final String? text;
  @override
  final DateTime createdDate;
  @override
  final DateTime updatedDate;

  @override
  String toString() {
    return 'FaithNote(id: $id, verses: $verses, text: $text, createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_FaithNote &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.updatedDate, updatedDate) ||
                other.updatedDate == updatedDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_verses),
      text,
      createdDate,
      updatedDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_FaithNoteCopyWith<_$_FaithNote> get copyWith =>
      __$$_FaithNoteCopyWithImpl<_$_FaithNote>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FaithNoteToJson(
      this,
    );
  }
}

abstract class _FaithNote extends FaithNote {
  const factory _FaithNote(
      {required final int id,
      required final List<int> verses,
      final String? text,
      required final DateTime createdDate,
      required final DateTime updatedDate}) = _$_FaithNote;
  const _FaithNote._() : super._();

  factory _FaithNote.fromJson(Map<String, dynamic> json) =
      _$_FaithNote.fromJson;

  @override
  int get id;
  @override
  List<int> get verses;
  @override
  String? get text;
  @override
  DateTime get createdDate;
  @override
  DateTime get updatedDate;
  @override
  @JsonKey(ignore: true)
  _$$_FaithNoteCopyWith<_$_FaithNote> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BibleNote _$BibleNoteFromJson(Map<String, dynamic> json) {
  return _BibleNote.fromJson(json);
}

/// @nodoc
mixin _$BibleNote {
  int get id => throw _privateConstructorUsedError;
  List<Verse> get verses => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  DateTime get createdDate => throw _privateConstructorUsedError;
  DateTime get updatedDate => throw _privateConstructorUsedError;

  /// Serializes this BibleNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BibleNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BibleNoteCopyWith<BibleNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BibleNoteCopyWith<$Res> {
  factory $BibleNoteCopyWith(BibleNote value, $Res Function(BibleNote) then) =
      _$BibleNoteCopyWithImpl<$Res, BibleNote>;
  @useResult
  $Res call(
      {int id,
      List<Verse> verses,
      String? text,
      DateTime createdDate,
      DateTime updatedDate});
}

/// @nodoc
class _$BibleNoteCopyWithImpl<$Res, $Val extends BibleNote>
    implements $BibleNoteCopyWith<$Res> {
  _$BibleNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BibleNote
  /// with the given fields replaced by the non-null parameter values.
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
              as List<Verse>,
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
abstract class _$$BibleNoteImplCopyWith<$Res>
    implements $BibleNoteCopyWith<$Res> {
  factory _$$BibleNoteImplCopyWith(
          _$BibleNoteImpl value, $Res Function(_$BibleNoteImpl) then) =
      __$$BibleNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      List<Verse> verses,
      String? text,
      DateTime createdDate,
      DateTime updatedDate});
}

/// @nodoc
class __$$BibleNoteImplCopyWithImpl<$Res>
    extends _$BibleNoteCopyWithImpl<$Res, _$BibleNoteImpl>
    implements _$$BibleNoteImplCopyWith<$Res> {
  __$$BibleNoteImplCopyWithImpl(
      _$BibleNoteImpl _value, $Res Function(_$BibleNoteImpl) _then)
      : super(_value, _then);

  /// Create a copy of BibleNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? verses = null,
    Object? text = freezed,
    Object? createdDate = null,
    Object? updatedDate = null,
  }) {
    return _then(_$BibleNoteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
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
class _$BibleNoteImpl extends _BibleNote {
  const _$BibleNoteImpl(
      {required this.id,
      required final List<Verse> verses,
      this.text,
      required this.createdDate,
      required this.updatedDate})
      : _verses = verses,
        super._();

  factory _$BibleNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$BibleNoteImplFromJson(json);

  @override
  final int id;
  final List<Verse> _verses;
  @override
  List<Verse> get verses {
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
    return 'BibleNote(id: $id, verses: $verses, text: $text, createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BibleNoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.updatedDate, updatedDate) ||
                other.updatedDate == updatedDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_verses),
      text,
      createdDate,
      updatedDate);

  /// Create a copy of BibleNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BibleNoteImplCopyWith<_$BibleNoteImpl> get copyWith =>
      __$$BibleNoteImplCopyWithImpl<_$BibleNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BibleNoteImplToJson(
      this,
    );
  }
}

abstract class _BibleNote extends BibleNote {
  const factory _BibleNote(
      {required final int id,
      required final List<Verse> verses,
      final String? text,
      required final DateTime createdDate,
      required final DateTime updatedDate}) = _$BibleNoteImpl;
  const _BibleNote._() : super._();

  factory _BibleNote.fromJson(Map<String, dynamic> json) =
      _$BibleNoteImpl.fromJson;

  @override
  int get id;
  @override
  List<Verse> get verses;
  @override
  String? get text;
  @override
  DateTime get createdDate;
  @override
  DateTime get updatedDate;

  /// Create a copy of BibleNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BibleNoteImplCopyWith<_$BibleNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

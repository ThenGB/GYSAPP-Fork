// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pericope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Pericope _$PericopeFromJson(Map<String, dynamic> json) {
  return _Pericope.fromJson(json);
}

/// @nodoc
mixin _$Pericope {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 's')
  int? get s => throw _privateConstructorUsedError;
  @JsonKey(name: 'b')
  int? get bookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'c')
  int? get chapterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'v')
  int? get verseId => throw _privateConstructorUsedError;
  @JsonKey(name: 't')
  String? get title => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PericopeCopyWith<Pericope> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PericopeCopyWith<$Res> {
  factory $PericopeCopyWith(Pericope value, $Res Function(Pericope) then) =
      _$PericopeCopyWithImpl<$Res, Pericope>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 's') int? s,
      @JsonKey(name: 'b') int? bookId,
      @JsonKey(name: 'c') int? chapterId,
      @JsonKey(name: 'v') int? verseId,
      @JsonKey(name: 't') String? title});
}

/// @nodoc
class _$PericopeCopyWithImpl<$Res, $Val extends Pericope>
    implements $PericopeCopyWith<$Res> {
  _$PericopeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? s = freezed,
    Object? bookId = freezed,
    Object? chapterId = freezed,
    Object? verseId = freezed,
    Object? title = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      s: freezed == s
          ? _value.s
          : s // ignore: cast_nullable_to_non_nullable
              as int?,
      bookId: freezed == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int?,
      chapterId: freezed == chapterId
          ? _value.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int?,
      verseId: freezed == verseId
          ? _value.verseId
          : verseId // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PericopeImplCopyWith<$Res>
    implements $PericopeCopyWith<$Res> {
  factory _$$PericopeImplCopyWith(
          _$PericopeImpl value, $Res Function(_$PericopeImpl) then) =
      __$$PericopeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 's') int? s,
      @JsonKey(name: 'b') int? bookId,
      @JsonKey(name: 'c') int? chapterId,
      @JsonKey(name: 'v') int? verseId,
      @JsonKey(name: 't') String? title});
}

/// @nodoc
class __$$PericopeImplCopyWithImpl<$Res>
    extends _$PericopeCopyWithImpl<$Res, _$PericopeImpl>
    implements _$$PericopeImplCopyWith<$Res> {
  __$$PericopeImplCopyWithImpl(
      _$PericopeImpl _value, $Res Function(_$PericopeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? s = freezed,
    Object? bookId = freezed,
    Object? chapterId = freezed,
    Object? verseId = freezed,
    Object? title = freezed,
  }) {
    return _then(_$PericopeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      s: freezed == s
          ? _value.s
          : s // ignore: cast_nullable_to_non_nullable
              as int?,
      bookId: freezed == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int?,
      chapterId: freezed == chapterId
          ? _value.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int?,
      verseId: freezed == verseId
          ? _value.verseId
          : verseId // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PericopeImpl extends _Pericope {
  const _$PericopeImpl(
      {required this.id,
      @JsonKey(name: 's') this.s,
      @JsonKey(name: 'b') this.bookId,
      @JsonKey(name: 'c') this.chapterId,
      @JsonKey(name: 'v') this.verseId,
      @JsonKey(name: 't') this.title})
      : super._();

  factory _$PericopeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PericopeImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 's')
  final int? s;
  @override
  @JsonKey(name: 'b')
  final int? bookId;
  @override
  @JsonKey(name: 'c')
  final int? chapterId;
  @override
  @JsonKey(name: 'v')
  final int? verseId;
  @override
  @JsonKey(name: 't')
  final String? title;

  @override
  String toString() {
    return 'Pericope(id: $id, s: $s, bookId: $bookId, chapterId: $chapterId, verseId: $verseId, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PericopeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.s, s) || other.s == s) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.verseId, verseId) || other.verseId == verseId) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, s, bookId, chapterId, verseId, title);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PericopeImplCopyWith<_$PericopeImpl> get copyWith =>
      __$$PericopeImplCopyWithImpl<_$PericopeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PericopeImplToJson(
      this,
    );
  }
}

abstract class _Pericope extends Pericope {
  const factory _Pericope(
      {required final int id,
      @JsonKey(name: 's') final int? s,
      @JsonKey(name: 'b') final int? bookId,
      @JsonKey(name: 'c') final int? chapterId,
      @JsonKey(name: 'v') final int? verseId,
      @JsonKey(name: 't') final String? title}) = _$PericopeImpl;
  const _Pericope._() : super._();

  factory _Pericope.fromJson(Map<String, dynamic> json) =
      _$PericopeImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 's')
  int? get s;
  @override
  @JsonKey(name: 'b')
  int? get bookId;
  @override
  @JsonKey(name: 'c')
  int? get chapterId;
  @override
  @JsonKey(name: 'v')
  int? get verseId;
  @override
  @JsonKey(name: 't')
  String? get title;
  @override
  @JsonKey(ignore: true)
  _$$PericopeImplCopyWith<_$PericopeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

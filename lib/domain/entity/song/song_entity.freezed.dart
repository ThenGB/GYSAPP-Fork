// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SongBook _$SongBookFromJson(Map<String, dynamic> json) {
  return _SongBook.fromJson(json);
}

/// @nodoc
mixin _$SongBook {
  @JsonKey(name: 'code')
  String? get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'songs')
  List<Song> get songs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SongBookCopyWith<SongBook> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongBookCopyWith<$Res> {
  factory $SongBookCopyWith(SongBook value, $Res Function(SongBook) then) =
      _$SongBookCopyWithImpl<$Res, SongBook>;
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String? code,
      @JsonKey(name: 'songs') List<Song> songs});
}

/// @nodoc
class _$SongBookCopyWithImpl<$Res, $Val extends SongBook>
    implements $SongBookCopyWith<$Res> {
  _$SongBookCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = freezed,
    Object? songs = null,
  }) {
    return _then(_value.copyWith(
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      songs: null == songs
          ? _value.songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SongBookImplCopyWith<$Res>
    implements $SongBookCopyWith<$Res> {
  factory _$$SongBookImplCopyWith(
          _$SongBookImpl value, $Res Function(_$SongBookImpl) then) =
      __$$SongBookImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String? code,
      @JsonKey(name: 'songs') List<Song> songs});
}

/// @nodoc
class __$$SongBookImplCopyWithImpl<$Res>
    extends _$SongBookCopyWithImpl<$Res, _$SongBookImpl>
    implements _$$SongBookImplCopyWith<$Res> {
  __$$SongBookImplCopyWithImpl(
      _$SongBookImpl _value, $Res Function(_$SongBookImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = freezed,
    Object? songs = null,
  }) {
    return _then(_$SongBookImpl(
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      songs: null == songs
          ? _value._songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SongBookImpl extends _SongBook {
  const _$SongBookImpl(
      {@JsonKey(name: 'code') this.code,
      @JsonKey(name: 'songs') final List<Song> songs = const []})
      : _songs = songs,
        super._();

  factory _$SongBookImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongBookImplFromJson(json);

  @override
  @JsonKey(name: 'code')
  final String? code;
  final List<Song> _songs;
  @override
  @JsonKey(name: 'songs')
  List<Song> get songs {
    if (_songs is EqualUnmodifiableListView) return _songs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_songs);
  }

  @override
  String toString() {
    return 'SongBook(code: $code, songs: $songs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongBookImpl &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._songs, _songs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, code, const DeepCollectionEquality().hash(_songs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SongBookImplCopyWith<_$SongBookImpl> get copyWith =>
      __$$SongBookImplCopyWithImpl<_$SongBookImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongBookImplToJson(
      this,
    );
  }
}

abstract class _SongBook extends SongBook {
  const factory _SongBook(
      {@JsonKey(name: 'code') final String? code,
      @JsonKey(name: 'songs') final List<Song> songs}) = _$SongBookImpl;
  const _SongBook._() : super._();

  factory _SongBook.fromJson(Map<String, dynamic> json) =
      _$SongBookImpl.fromJson;

  @override
  @JsonKey(name: 'code')
  String? get code;
  @override
  @JsonKey(name: 'songs')
  List<Song> get songs;
  @override
  @JsonKey(ignore: true)
  _$$SongBookImplCopyWith<_$SongBookImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Song _$SongFromJson(Map<String, dynamic> json) {
  return _Song.fromJson(json);
}

/// @nodoc
mixin _$Song {
  @JsonKey(name: 'code')
  String? get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'number')
  String? get number => throw _privateConstructorUsedError;
  @JsonKey(name: 'number2')
  String? get number2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'lyric')
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'song')
  String? get soundfilePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'pages')
  int? get pageLength => throw _privateConstructorUsedError;
  @JsonKey(name: 'page')
  int? get pageStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'verses')
  List<String> get verses => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SongCopyWith<Song> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongCopyWith<$Res> {
  factory $SongCopyWith(Song value, $Res Function(Song) then) =
      _$SongCopyWithImpl<$Res, Song>;
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String? code,
      @JsonKey(name: 'number') String? number,
      @JsonKey(name: 'number2') String? number2,
      @JsonKey(name: 'lyric') String? title,
      @JsonKey(name: 'song') String? soundfilePath,
      @JsonKey(name: 'pages') int? pageLength,
      @JsonKey(name: 'page') int? pageStart,
      @JsonKey(name: 'verses') List<String> verses});
}

/// @nodoc
class _$SongCopyWithImpl<$Res, $Val extends Song>
    implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = freezed,
    Object? number = freezed,
    Object? number2 = freezed,
    Object? title = freezed,
    Object? soundfilePath = freezed,
    Object? pageLength = freezed,
    Object? pageStart = freezed,
    Object? verses = null,
  }) {
    return _then(_value.copyWith(
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String?,
      number2: freezed == number2
          ? _value.number2
          : number2 // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      soundfilePath: freezed == soundfilePath
          ? _value.soundfilePath
          : soundfilePath // ignore: cast_nullable_to_non_nullable
              as String?,
      pageLength: freezed == pageLength
          ? _value.pageLength
          : pageLength // ignore: cast_nullable_to_non_nullable
              as int?,
      pageStart: freezed == pageStart
          ? _value.pageStart
          : pageStart // ignore: cast_nullable_to_non_nullable
              as int?,
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SongImplCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$$SongImplCopyWith(
          _$SongImpl value, $Res Function(_$SongImpl) then) =
      __$$SongImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String? code,
      @JsonKey(name: 'number') String? number,
      @JsonKey(name: 'number2') String? number2,
      @JsonKey(name: 'lyric') String? title,
      @JsonKey(name: 'song') String? soundfilePath,
      @JsonKey(name: 'pages') int? pageLength,
      @JsonKey(name: 'page') int? pageStart,
      @JsonKey(name: 'verses') List<String> verses});
}

/// @nodoc
class __$$SongImplCopyWithImpl<$Res>
    extends _$SongCopyWithImpl<$Res, _$SongImpl>
    implements _$$SongImplCopyWith<$Res> {
  __$$SongImplCopyWithImpl(_$SongImpl _value, $Res Function(_$SongImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = freezed,
    Object? number = freezed,
    Object? number2 = freezed,
    Object? title = freezed,
    Object? soundfilePath = freezed,
    Object? pageLength = freezed,
    Object? pageStart = freezed,
    Object? verses = null,
  }) {
    return _then(_$SongImpl(
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String?,
      number2: freezed == number2
          ? _value.number2
          : number2 // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      soundfilePath: freezed == soundfilePath
          ? _value.soundfilePath
          : soundfilePath // ignore: cast_nullable_to_non_nullable
              as String?,
      pageLength: freezed == pageLength
          ? _value.pageLength
          : pageLength // ignore: cast_nullable_to_non_nullable
              as int?,
      pageStart: freezed == pageStart
          ? _value.pageStart
          : pageStart // ignore: cast_nullable_to_non_nullable
              as int?,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SongImpl extends _Song {
  const _$SongImpl(
      {@JsonKey(name: 'code') this.code,
      @JsonKey(name: 'number') this.number,
      @JsonKey(name: 'number2') this.number2,
      @JsonKey(name: 'lyric') this.title,
      @JsonKey(name: 'song') this.soundfilePath,
      @JsonKey(name: 'pages') this.pageLength,
      @JsonKey(name: 'page') this.pageStart,
      @JsonKey(name: 'verses') final List<String> verses = const []})
      : _verses = verses,
        super._();

  factory _$SongImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongImplFromJson(json);

  @override
  @JsonKey(name: 'code')
  final String? code;
  @override
  @JsonKey(name: 'number')
  final String? number;
  @override
  @JsonKey(name: 'number2')
  final String? number2;
  @override
  @JsonKey(name: 'lyric')
  final String? title;
  @override
  @JsonKey(name: 'song')
  final String? soundfilePath;
  @override
  @JsonKey(name: 'pages')
  final int? pageLength;
  @override
  @JsonKey(name: 'page')
  final int? pageStart;
  final List<String> _verses;
  @override
  @JsonKey(name: 'verses')
  List<String> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

  @override
  String toString() {
    return 'Song(code: $code, number: $number, number2: $number2, title: $title, soundfilePath: $soundfilePath, pageLength: $pageLength, pageStart: $pageStart, verses: $verses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.number2, number2) || other.number2 == number2) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.soundfilePath, soundfilePath) ||
                other.soundfilePath == soundfilePath) &&
            (identical(other.pageLength, pageLength) ||
                other.pageLength == pageLength) &&
            (identical(other.pageStart, pageStart) ||
                other.pageStart == pageStart) &&
            const DeepCollectionEquality().equals(other._verses, _verses));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      code,
      number,
      number2,
      title,
      soundfilePath,
      pageLength,
      pageStart,
      const DeepCollectionEquality().hash(_verses));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SongImplCopyWith<_$SongImpl> get copyWith =>
      __$$SongImplCopyWithImpl<_$SongImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongImplToJson(
      this,
    );
  }
}

abstract class _Song extends Song {
  const factory _Song(
      {@JsonKey(name: 'code') final String? code,
      @JsonKey(name: 'number') final String? number,
      @JsonKey(name: 'number2') final String? number2,
      @JsonKey(name: 'lyric') final String? title,
      @JsonKey(name: 'song') final String? soundfilePath,
      @JsonKey(name: 'pages') final int? pageLength,
      @JsonKey(name: 'page') final int? pageStart,
      @JsonKey(name: 'verses') final List<String> verses}) = _$SongImpl;
  const _Song._() : super._();

  factory _Song.fromJson(Map<String, dynamic> json) = _$SongImpl.fromJson;

  @override
  @JsonKey(name: 'code')
  String? get code;
  @override
  @JsonKey(name: 'number')
  String? get number;
  @override
  @JsonKey(name: 'number2')
  String? get number2;
  @override
  @JsonKey(name: 'lyric')
  String? get title;
  @override
  @JsonKey(name: 'song')
  String? get soundfilePath;
  @override
  @JsonKey(name: 'pages')
  int? get pageLength;
  @override
  @JsonKey(name: 'page')
  int? get pageStart;
  @override
  @JsonKey(name: 'verses')
  List<String> get verses;
  @override
  @JsonKey(ignore: true)
  _$$SongImplCopyWith<_$SongImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

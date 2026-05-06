// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SongBook {
  @JsonKey(name: 'code')
  String? get code;
  @JsonKey(name: 'songs')
  List<Song> get songs;

  /// Create a copy of SongBook
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SongBookCopyWith<SongBook> get copyWith =>
      _$SongBookCopyWithImpl<SongBook>(this as SongBook, _$identity);

  /// Serializes this SongBook to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SongBook &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.songs, songs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, code, const DeepCollectionEquality().hash(songs));

  @override
  String toString() {
    return 'SongBook(code: $code, songs: $songs)';
  }
}

/// @nodoc
abstract mixin class $SongBookCopyWith<$Res> {
  factory $SongBookCopyWith(SongBook value, $Res Function(SongBook) _then) =
      _$SongBookCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String? code,
      @JsonKey(name: 'songs') List<Song> songs});
}

/// @nodoc
class _$SongBookCopyWithImpl<$Res> implements $SongBookCopyWith<$Res> {
  _$SongBookCopyWithImpl(this._self, this._then);

  final SongBook _self;
  final $Res Function(SongBook) _then;

  /// Create a copy of SongBook
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = freezed,
    Object? songs = null,
  }) {
    return _then(_self.copyWith(
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      songs: null == songs
          ? _self.songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
    ));
  }
}

/// Adds pattern-matching-related methods to [SongBook].
extension SongBookPatterns on SongBook {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SongBook value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SongBook() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SongBook value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongBook():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SongBook value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongBook() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(@JsonKey(name: 'code') String? code,
            @JsonKey(name: 'songs') List<Song> songs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SongBook() when $default != null:
        return $default(_that.code, _that.songs);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(@JsonKey(name: 'code') String? code,
            @JsonKey(name: 'songs') List<Song> songs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongBook():
        return $default(_that.code, _that.songs);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(@JsonKey(name: 'code') String? code,
            @JsonKey(name: 'songs') List<Song> songs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongBook() when $default != null:
        return $default(_that.code, _that.songs);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SongBook extends SongBook {
  const _SongBook(
      {@JsonKey(name: 'code') this.code,
      @JsonKey(name: 'songs') final List<Song> songs = const []})
      : _songs = songs,
        super._();
  factory _SongBook.fromJson(Map<String, dynamic> json) =>
      _$SongBookFromJson(json);

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

  /// Create a copy of SongBook
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SongBookCopyWith<_SongBook> get copyWith =>
      __$SongBookCopyWithImpl<_SongBook>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SongBookToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SongBook &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._songs, _songs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, code, const DeepCollectionEquality().hash(_songs));

  @override
  String toString() {
    return 'SongBook(code: $code, songs: $songs)';
  }
}

/// @nodoc
abstract mixin class _$SongBookCopyWith<$Res>
    implements $SongBookCopyWith<$Res> {
  factory _$SongBookCopyWith(_SongBook value, $Res Function(_SongBook) _then) =
      __$SongBookCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'code') String? code,
      @JsonKey(name: 'songs') List<Song> songs});
}

/// @nodoc
class __$SongBookCopyWithImpl<$Res> implements _$SongBookCopyWith<$Res> {
  __$SongBookCopyWithImpl(this._self, this._then);

  final _SongBook _self;
  final $Res Function(_SongBook) _then;

  /// Create a copy of SongBook
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? code = freezed,
    Object? songs = null,
  }) {
    return _then(_SongBook(
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      songs: null == songs
          ? _self._songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
    ));
  }
}

/// @nodoc
mixin _$Song {
  @JsonKey(name: 'code')
  String? get code;
  @JsonKey(name: 'number')
  String? get number;
  @JsonKey(name: 'number2')
  String? get number2;
  @JsonKey(name: 'lyric')
  String? get title;
  @JsonKey(name: 'song')
  String? get soundfilePath;
  @JsonKey(name: 'pages')
  int? get pageLength;
  @JsonKey(name: 'page')
  int? get pageStart;
  @JsonKey(name: 'verses')
  List<String> get verses;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SongCopyWith<Song> get copyWith =>
      _$SongCopyWithImpl<Song>(this as Song, _$identity);

  /// Serializes this Song to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Song &&
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
            const DeepCollectionEquality().equals(other.verses, verses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
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
      const DeepCollectionEquality().hash(verses));

  @override
  String toString() {
    return 'Song(code: $code, number: $number, number2: $number2, title: $title, soundfilePath: $soundfilePath, pageLength: $pageLength, pageStart: $pageStart, verses: $verses)';
  }
}

/// @nodoc
abstract mixin class $SongCopyWith<$Res> {
  factory $SongCopyWith(Song value, $Res Function(Song) _then) =
      _$SongCopyWithImpl;
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
class _$SongCopyWithImpl<$Res> implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._self, this._then);

  final Song _self;
  final $Res Function(Song) _then;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
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
    return _then(_self.copyWith(
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      number: freezed == number
          ? _self.number
          : number // ignore: cast_nullable_to_non_nullable
              as String?,
      number2: freezed == number2
          ? _self.number2
          : number2 // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      soundfilePath: freezed == soundfilePath
          ? _self.soundfilePath
          : soundfilePath // ignore: cast_nullable_to_non_nullable
              as String?,
      pageLength: freezed == pageLength
          ? _self.pageLength
          : pageLength // ignore: cast_nullable_to_non_nullable
              as int?,
      pageStart: freezed == pageStart
          ? _self.pageStart
          : pageStart // ignore: cast_nullable_to_non_nullable
              as int?,
      verses: null == verses
          ? _self.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [Song].
extension SongPatterns on Song {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Song value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Song value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Song value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'code') String? code,
            @JsonKey(name: 'number') String? number,
            @JsonKey(name: 'number2') String? number2,
            @JsonKey(name: 'lyric') String? title,
            @JsonKey(name: 'song') String? soundfilePath,
            @JsonKey(name: 'pages') int? pageLength,
            @JsonKey(name: 'page') int? pageStart,
            @JsonKey(name: 'verses') List<String> verses)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
        return $default(
            _that.code,
            _that.number,
            _that.number2,
            _that.title,
            _that.soundfilePath,
            _that.pageLength,
            _that.pageStart,
            _that.verses);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'code') String? code,
            @JsonKey(name: 'number') String? number,
            @JsonKey(name: 'number2') String? number2,
            @JsonKey(name: 'lyric') String? title,
            @JsonKey(name: 'song') String? soundfilePath,
            @JsonKey(name: 'pages') int? pageLength,
            @JsonKey(name: 'page') int? pageStart,
            @JsonKey(name: 'verses') List<String> verses)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song():
        return $default(
            _that.code,
            _that.number,
            _that.number2,
            _that.title,
            _that.soundfilePath,
            _that.pageLength,
            _that.pageStart,
            _that.verses);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @JsonKey(name: 'code') String? code,
            @JsonKey(name: 'number') String? number,
            @JsonKey(name: 'number2') String? number2,
            @JsonKey(name: 'lyric') String? title,
            @JsonKey(name: 'song') String? soundfilePath,
            @JsonKey(name: 'pages') int? pageLength,
            @JsonKey(name: 'page') int? pageStart,
            @JsonKey(name: 'verses') List<String> verses)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
        return $default(
            _that.code,
            _that.number,
            _that.number2,
            _that.title,
            _that.soundfilePath,
            _that.pageLength,
            _that.pageStart,
            _that.verses);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Song extends Song {
  const _Song(
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
  factory _Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

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

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SongCopyWith<_Song> get copyWith =>
      __$SongCopyWithImpl<_Song>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SongToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Song &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  @override
  String toString() {
    return 'Song(code: $code, number: $number, number2: $number2, title: $title, soundfilePath: $soundfilePath, pageLength: $pageLength, pageStart: $pageStart, verses: $verses)';
  }
}

/// @nodoc
abstract mixin class _$SongCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$SongCopyWith(_Song value, $Res Function(_Song) _then) =
      __$SongCopyWithImpl;
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
class __$SongCopyWithImpl<$Res> implements _$SongCopyWith<$Res> {
  __$SongCopyWithImpl(this._self, this._then);

  final _Song _self;
  final $Res Function(_Song) _then;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_Song(
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      number: freezed == number
          ? _self.number
          : number // ignore: cast_nullable_to_non_nullable
              as String?,
      number2: freezed == number2
          ? _self.number2
          : number2 // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      soundfilePath: freezed == soundfilePath
          ? _self.soundfilePath
          : soundfilePath // ignore: cast_nullable_to_non_nullable
              as String?,
      pageLength: freezed == pageLength
          ? _self.pageLength
          : pageLength // ignore: cast_nullable_to_non_nullable
              as int?,
      pageStart: freezed == pageStart
          ? _self.pageStart
          : pageStart // ignore: cast_nullable_to_non_nullable
              as int?,
      verses: null == verses
          ? _self._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on

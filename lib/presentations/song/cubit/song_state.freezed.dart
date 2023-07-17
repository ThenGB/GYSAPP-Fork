// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SongState _$SongStateFromJson(Map<String, dynamic> json) {
  return _SongState.fromJson(json);
}

/// @nodoc
mixin _$SongState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isAudioLoading => throw _privateConstructorUsedError;
  List<SongBook> get songBook => throw _privateConstructorUsedError;
  List<SongBook> get favoriteSongBook => throw _privateConstructorUsedError;
  String get bookCode => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;
  int get verseIndex => throw _privateConstructorUsedError;
  dynamic get isImageMode => throw _privateConstructorUsedError;
  double get textScaleFactor => throw _privateConstructorUsedError;
  bool get showSizer => throw _privateConstructorUsedError;
  String get defaultAudioFormat => throw _privateConstructorUsedError;
  Song? get selectedSong => throw _privateConstructorUsedError;
  List<SongNote> get notes => throw _privateConstructorUsedError;
  String get sortNotesBy => throw _privateConstructorUsedError;
  List<SongHistory> get histories => throw _privateConstructorUsedError;
  bool get playOnlyFavorite => throw _privateConstructorUsedError;
  bool get shuffleMode => throw _privateConstructorUsedError;
  List<int> get shuffleIndex => throw _privateConstructorUsedError;
  bool get showAudio => throw _privateConstructorUsedError;
  String get searchTerms => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SongStateCopyWith<SongState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongStateCopyWith<$Res> {
  factory $SongStateCopyWith(SongState value, $Res Function(SongState) then) =
      _$SongStateCopyWithImpl<$Res, SongState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isAudioLoading,
      List<SongBook> songBook,
      List<SongBook> favoriteSongBook,
      String bookCode,
      int pageIndex,
      int verseIndex,
      dynamic isImageMode,
      double textScaleFactor,
      bool showSizer,
      String defaultAudioFormat,
      Song? selectedSong,
      List<SongNote> notes,
      String sortNotesBy,
      List<SongHistory> histories,
      bool playOnlyFavorite,
      bool shuffleMode,
      List<int> shuffleIndex,
      bool showAudio,
      String searchTerms});

  $SongCopyWith<$Res>? get selectedSong;
}

/// @nodoc
class _$SongStateCopyWithImpl<$Res, $Val extends SongState>
    implements $SongStateCopyWith<$Res> {
  _$SongStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isAudioLoading = null,
    Object? songBook = null,
    Object? favoriteSongBook = null,
    Object? bookCode = null,
    Object? pageIndex = null,
    Object? verseIndex = null,
    Object? isImageMode = freezed,
    Object? textScaleFactor = null,
    Object? showSizer = null,
    Object? defaultAudioFormat = null,
    Object? selectedSong = freezed,
    Object? notes = null,
    Object? sortNotesBy = null,
    Object? histories = null,
    Object? playOnlyFavorite = null,
    Object? shuffleMode = null,
    Object? shuffleIndex = null,
    Object? showAudio = null,
    Object? searchTerms = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isAudioLoading: null == isAudioLoading
          ? _value.isAudioLoading
          : isAudioLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      songBook: null == songBook
          ? _value.songBook
          : songBook // ignore: cast_nullable_to_non_nullable
              as List<SongBook>,
      favoriteSongBook: null == favoriteSongBook
          ? _value.favoriteSongBook
          : favoriteSongBook // ignore: cast_nullable_to_non_nullable
              as List<SongBook>,
      bookCode: null == bookCode
          ? _value.bookCode
          : bookCode // ignore: cast_nullable_to_non_nullable
              as String,
      pageIndex: null == pageIndex
          ? _value.pageIndex
          : pageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      verseIndex: null == verseIndex
          ? _value.verseIndex
          : verseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isImageMode: freezed == isImageMode
          ? _value.isImageMode
          : isImageMode // ignore: cast_nullable_to_non_nullable
              as dynamic,
      textScaleFactor: null == textScaleFactor
          ? _value.textScaleFactor
          : textScaleFactor // ignore: cast_nullable_to_non_nullable
              as double,
      showSizer: null == showSizer
          ? _value.showSizer
          : showSizer // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultAudioFormat: null == defaultAudioFormat
          ? _value.defaultAudioFormat
          : defaultAudioFormat // ignore: cast_nullable_to_non_nullable
              as String,
      selectedSong: freezed == selectedSong
          ? _value.selectedSong
          : selectedSong // ignore: cast_nullable_to_non_nullable
              as Song?,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<SongNote>,
      sortNotesBy: null == sortNotesBy
          ? _value.sortNotesBy
          : sortNotesBy // ignore: cast_nullable_to_non_nullable
              as String,
      histories: null == histories
          ? _value.histories
          : histories // ignore: cast_nullable_to_non_nullable
              as List<SongHistory>,
      playOnlyFavorite: null == playOnlyFavorite
          ? _value.playOnlyFavorite
          : playOnlyFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      shuffleMode: null == shuffleMode
          ? _value.shuffleMode
          : shuffleMode // ignore: cast_nullable_to_non_nullable
              as bool,
      shuffleIndex: null == shuffleIndex
          ? _value.shuffleIndex
          : shuffleIndex // ignore: cast_nullable_to_non_nullable
              as List<int>,
      showAudio: null == showAudio
          ? _value.showAudio
          : showAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      searchTerms: null == searchTerms
          ? _value.searchTerms
          : searchTerms // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SongCopyWith<$Res>? get selectedSong {
    if (_value.selectedSong == null) {
      return null;
    }

    return $SongCopyWith<$Res>(_value.selectedSong!, (value) {
      return _then(_value.copyWith(selectedSong: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_SongStateCopyWith<$Res> implements $SongStateCopyWith<$Res> {
  factory _$$_SongStateCopyWith(
          _$_SongState value, $Res Function(_$_SongState) then) =
      __$$_SongStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isAudioLoading,
      List<SongBook> songBook,
      List<SongBook> favoriteSongBook,
      String bookCode,
      int pageIndex,
      int verseIndex,
      dynamic isImageMode,
      double textScaleFactor,
      bool showSizer,
      String defaultAudioFormat,
      Song? selectedSong,
      List<SongNote> notes,
      String sortNotesBy,
      List<SongHistory> histories,
      bool playOnlyFavorite,
      bool shuffleMode,
      List<int> shuffleIndex,
      bool showAudio,
      String searchTerms});

  @override
  $SongCopyWith<$Res>? get selectedSong;
}

/// @nodoc
class __$$_SongStateCopyWithImpl<$Res>
    extends _$SongStateCopyWithImpl<$Res, _$_SongState>
    implements _$$_SongStateCopyWith<$Res> {
  __$$_SongStateCopyWithImpl(
      _$_SongState _value, $Res Function(_$_SongState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isAudioLoading = null,
    Object? songBook = null,
    Object? favoriteSongBook = null,
    Object? bookCode = null,
    Object? pageIndex = null,
    Object? verseIndex = null,
    Object? isImageMode = freezed,
    Object? textScaleFactor = null,
    Object? showSizer = null,
    Object? defaultAudioFormat = null,
    Object? selectedSong = freezed,
    Object? notes = null,
    Object? sortNotesBy = null,
    Object? histories = null,
    Object? playOnlyFavorite = null,
    Object? shuffleMode = null,
    Object? shuffleIndex = null,
    Object? showAudio = null,
    Object? searchTerms = null,
  }) {
    return _then(_$_SongState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isAudioLoading: null == isAudioLoading
          ? _value.isAudioLoading
          : isAudioLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      songBook: null == songBook
          ? _value._songBook
          : songBook // ignore: cast_nullable_to_non_nullable
              as List<SongBook>,
      favoriteSongBook: null == favoriteSongBook
          ? _value._favoriteSongBook
          : favoriteSongBook // ignore: cast_nullable_to_non_nullable
              as List<SongBook>,
      bookCode: null == bookCode
          ? _value.bookCode
          : bookCode // ignore: cast_nullable_to_non_nullable
              as String,
      pageIndex: null == pageIndex
          ? _value.pageIndex
          : pageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      verseIndex: null == verseIndex
          ? _value.verseIndex
          : verseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isImageMode: freezed == isImageMode ? _value.isImageMode! : isImageMode,
      textScaleFactor: null == textScaleFactor
          ? _value.textScaleFactor
          : textScaleFactor // ignore: cast_nullable_to_non_nullable
              as double,
      showSizer: null == showSizer
          ? _value.showSizer
          : showSizer // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultAudioFormat: null == defaultAudioFormat
          ? _value.defaultAudioFormat
          : defaultAudioFormat // ignore: cast_nullable_to_non_nullable
              as String,
      selectedSong: freezed == selectedSong
          ? _value.selectedSong
          : selectedSong // ignore: cast_nullable_to_non_nullable
              as Song?,
      notes: null == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<SongNote>,
      sortNotesBy: null == sortNotesBy
          ? _value.sortNotesBy
          : sortNotesBy // ignore: cast_nullable_to_non_nullable
              as String,
      histories: null == histories
          ? _value._histories
          : histories // ignore: cast_nullable_to_non_nullable
              as List<SongHistory>,
      playOnlyFavorite: null == playOnlyFavorite
          ? _value.playOnlyFavorite
          : playOnlyFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      shuffleMode: null == shuffleMode
          ? _value.shuffleMode
          : shuffleMode // ignore: cast_nullable_to_non_nullable
              as bool,
      shuffleIndex: null == shuffleIndex
          ? _value._shuffleIndex
          : shuffleIndex // ignore: cast_nullable_to_non_nullable
              as List<int>,
      showAudio: null == showAudio
          ? _value.showAudio
          : showAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      searchTerms: null == searchTerms
          ? _value.searchTerms
          : searchTerms // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SongState extends _SongState {
  const _$_SongState(
      {this.isLoading = false,
      this.isAudioLoading = false,
      final List<SongBook> songBook = const [],
      final List<SongBook> favoriteSongBook = const [],
      this.bookCode = 'KR',
      this.pageIndex = 0,
      this.verseIndex = 0,
      this.isImageMode = false,
      this.textScaleFactor = 1,
      this.showSizer = false,
      this.defaultAudioFormat = 'mid',
      this.selectedSong,
      final List<SongNote> notes = const [],
      this.sortNotesBy = 'Newest',
      final List<SongHistory> histories = const [],
      this.playOnlyFavorite = false,
      this.shuffleMode = false,
      final List<int> shuffleIndex = const [],
      this.showAudio = false,
      this.searchTerms = ''})
      : _songBook = songBook,
        _favoriteSongBook = favoriteSongBook,
        _notes = notes,
        _histories = histories,
        _shuffleIndex = shuffleIndex,
        super._();

  factory _$_SongState.fromJson(Map<String, dynamic> json) =>
      _$$_SongStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isAudioLoading;
  final List<SongBook> _songBook;
  @override
  @JsonKey()
  List<SongBook> get songBook {
    if (_songBook is EqualUnmodifiableListView) return _songBook;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_songBook);
  }

  final List<SongBook> _favoriteSongBook;
  @override
  @JsonKey()
  List<SongBook> get favoriteSongBook {
    if (_favoriteSongBook is EqualUnmodifiableListView)
      return _favoriteSongBook;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteSongBook);
  }

  @override
  @JsonKey()
  final String bookCode;
  @override
  @JsonKey()
  final int pageIndex;
  @override
  @JsonKey()
  final int verseIndex;
  @override
  @JsonKey()
  final dynamic isImageMode;
  @override
  @JsonKey()
  final double textScaleFactor;
  @override
  @JsonKey()
  final bool showSizer;
  @override
  @JsonKey()
  final String defaultAudioFormat;
  @override
  final Song? selectedSong;
  final List<SongNote> _notes;
  @override
  @JsonKey()
  List<SongNote> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  @JsonKey()
  final String sortNotesBy;
  final List<SongHistory> _histories;
  @override
  @JsonKey()
  List<SongHistory> get histories {
    if (_histories is EqualUnmodifiableListView) return _histories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_histories);
  }

  @override
  @JsonKey()
  final bool playOnlyFavorite;
  @override
  @JsonKey()
  final bool shuffleMode;
  final List<int> _shuffleIndex;
  @override
  @JsonKey()
  List<int> get shuffleIndex {
    if (_shuffleIndex is EqualUnmodifiableListView) return _shuffleIndex;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shuffleIndex);
  }

  @override
  @JsonKey()
  final bool showAudio;
  @override
  @JsonKey()
  final String searchTerms;

  @override
  String toString() {
    return 'SongState(isLoading: $isLoading, isAudioLoading: $isAudioLoading, songBook: $songBook, favoriteSongBook: $favoriteSongBook, bookCode: $bookCode, pageIndex: $pageIndex, verseIndex: $verseIndex, isImageMode: $isImageMode, textScaleFactor: $textScaleFactor, showSizer: $showSizer, defaultAudioFormat: $defaultAudioFormat, selectedSong: $selectedSong, notes: $notes, sortNotesBy: $sortNotesBy, histories: $histories, playOnlyFavorite: $playOnlyFavorite, shuffleMode: $shuffleMode, shuffleIndex: $shuffleIndex, showAudio: $showAudio, searchTerms: $searchTerms)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SongState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isAudioLoading, isAudioLoading) ||
                other.isAudioLoading == isAudioLoading) &&
            const DeepCollectionEquality().equals(other._songBook, _songBook) &&
            const DeepCollectionEquality()
                .equals(other._favoriteSongBook, _favoriteSongBook) &&
            (identical(other.bookCode, bookCode) ||
                other.bookCode == bookCode) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex) &&
            (identical(other.verseIndex, verseIndex) ||
                other.verseIndex == verseIndex) &&
            const DeepCollectionEquality()
                .equals(other.isImageMode, isImageMode) &&
            (identical(other.textScaleFactor, textScaleFactor) ||
                other.textScaleFactor == textScaleFactor) &&
            (identical(other.showSizer, showSizer) ||
                other.showSizer == showSizer) &&
            (identical(other.defaultAudioFormat, defaultAudioFormat) ||
                other.defaultAudioFormat == defaultAudioFormat) &&
            (identical(other.selectedSong, selectedSong) ||
                other.selectedSong == selectedSong) &&
            const DeepCollectionEquality().equals(other._notes, _notes) &&
            (identical(other.sortNotesBy, sortNotesBy) ||
                other.sortNotesBy == sortNotesBy) &&
            const DeepCollectionEquality()
                .equals(other._histories, _histories) &&
            (identical(other.playOnlyFavorite, playOnlyFavorite) ||
                other.playOnlyFavorite == playOnlyFavorite) &&
            (identical(other.shuffleMode, shuffleMode) ||
                other.shuffleMode == shuffleMode) &&
            const DeepCollectionEquality()
                .equals(other._shuffleIndex, _shuffleIndex) &&
            (identical(other.showAudio, showAudio) ||
                other.showAudio == showAudio) &&
            (identical(other.searchTerms, searchTerms) ||
                other.searchTerms == searchTerms));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isLoading,
        isAudioLoading,
        const DeepCollectionEquality().hash(_songBook),
        const DeepCollectionEquality().hash(_favoriteSongBook),
        bookCode,
        pageIndex,
        verseIndex,
        const DeepCollectionEquality().hash(isImageMode),
        textScaleFactor,
        showSizer,
        defaultAudioFormat,
        selectedSong,
        const DeepCollectionEquality().hash(_notes),
        sortNotesBy,
        const DeepCollectionEquality().hash(_histories),
        playOnlyFavorite,
        shuffleMode,
        const DeepCollectionEquality().hash(_shuffleIndex),
        showAudio,
        searchTerms
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SongStateCopyWith<_$_SongState> get copyWith =>
      __$$_SongStateCopyWithImpl<_$_SongState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SongStateToJson(
      this,
    );
  }
}

abstract class _SongState extends SongState {
  const factory _SongState(
      {final bool isLoading,
      final bool isAudioLoading,
      final List<SongBook> songBook,
      final List<SongBook> favoriteSongBook,
      final String bookCode,
      final int pageIndex,
      final int verseIndex,
      final dynamic isImageMode,
      final double textScaleFactor,
      final bool showSizer,
      final String defaultAudioFormat,
      final Song? selectedSong,
      final List<SongNote> notes,
      final String sortNotesBy,
      final List<SongHistory> histories,
      final bool playOnlyFavorite,
      final bool shuffleMode,
      final List<int> shuffleIndex,
      final bool showAudio,
      final String searchTerms}) = _$_SongState;
  const _SongState._() : super._();

  factory _SongState.fromJson(Map<String, dynamic> json) =
      _$_SongState.fromJson;

  @override
  bool get isLoading;
  @override
  bool get isAudioLoading;
  @override
  List<SongBook> get songBook;
  @override
  List<SongBook> get favoriteSongBook;
  @override
  String get bookCode;
  @override
  int get pageIndex;
  @override
  int get verseIndex;
  @override
  dynamic get isImageMode;
  @override
  double get textScaleFactor;
  @override
  bool get showSizer;
  @override
  String get defaultAudioFormat;
  @override
  Song? get selectedSong;
  @override
  List<SongNote> get notes;
  @override
  String get sortNotesBy;
  @override
  List<SongHistory> get histories;
  @override
  bool get playOnlyFavorite;
  @override
  bool get shuffleMode;
  @override
  List<int> get shuffleIndex;
  @override
  bool get showAudio;
  @override
  String get searchTerms;
  @override
  @JsonKey(ignore: true)
  _$$_SongStateCopyWith<_$_SongState> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BibleState _$BibleStateFromJson(Map<String, dynamic> json) {
  return _BibleState.fromJson(json);
}

/// @nodoc
mixin _$BibleState {
  String get currentBibleCode => throw _privateConstructorUsedError;
  String get splitBibleCode => throw _privateConstructorUsedError;
  List<String> get bibleCodes => throw _privateConstructorUsedError;
  Verse? get currentBible => throw _privateConstructorUsedError;
  Verse? get prevBible => throw _privateConstructorUsedError;
  Verse? get currentBibleSplit => throw _privateConstructorUsedError;
  Verse? get prevBibleSplit => throw _privateConstructorUsedError;
  List<BibleBook> get books => throw _privateConstructorUsedError;
  List<BibleBook> get booksSplit => throw _privateConstructorUsedError;
  List<Verse> get verses => throw _privateConstructorUsedError;
  List<BibleBookmark> get bookmarks => throw _privateConstructorUsedError;
  List<BibleRef> get references => throw _privateConstructorUsedError;
  List<BibleRef> get referencesSplit => throw _privateConstructorUsedError;
  List<Verse> get versesSplit => throw _privateConstructorUsedError;
  Map<DateTime, Verse> get histories => throw _privateConstructorUsedError;
  List<Pericope> get pericopes => throw _privateConstructorUsedError;
  List<Pericope> get pericopesSplit => throw _privateConstructorUsedError;
  List<BibleNote> get notes => throw _privateConstructorUsedError;
  List<PericopeParalel> get pericopesParalels =>
      throw _privateConstructorUsedError;
  List<PericopeParalel> get pericopesParalelsSplit =>
      throw _privateConstructorUsedError;
  BibleBook? get currentBook => throw _privateConstructorUsedError;
  BibleBook? get currentBookSplit => throw _privateConstructorUsedError;
  List<Verse> get selectedVerse => throw _privateConstructorUsedError;
  List<Verse> get hightlightedVerse => throw _privateConstructorUsedError;
  Verse? get todayReading => throw _privateConstructorUsedError;
  DateTime? get lastOpenBible => throw _privateConstructorUsedError;
  String get defaultFont => throw _privateConstructorUsedError;
  double get defaultTextScale => throw _privateConstructorUsedError;
  double get defaultTextHeight => throw _privateConstructorUsedError;
  String get sortNotesBy => throw _privateConstructorUsedError;
  bool get enableAudio => throw _privateConstructorUsedError;
  bool get isSpeaking => throw _privateConstructorUsedError;
  String get currentWord => throw _privateConstructorUsedError;
  int get currentStartWord => throw _privateConstructorUsedError;
  int get currentEndWord => throw _privateConstructorUsedError;
  List<BibleBook> get selectedFilterBooks => throw _privateConstructorUsedError;
  Map<String, Map> get voices => throw _privateConstructorUsedError;
  double get speedRate => throw _privateConstructorUsedError;
  double get pitchRate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BibleStateCopyWith<BibleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BibleStateCopyWith<$Res> {
  factory $BibleStateCopyWith(
          BibleState value, $Res Function(BibleState) then) =
      _$BibleStateCopyWithImpl<$Res, BibleState>;
  @useResult
  $Res call(
      {String currentBibleCode,
      String splitBibleCode,
      List<String> bibleCodes,
      Verse? currentBible,
      Verse? prevBible,
      Verse? currentBibleSplit,
      Verse? prevBibleSplit,
      List<BibleBook> books,
      List<BibleBook> booksSplit,
      List<Verse> verses,
      List<BibleBookmark> bookmarks,
      List<BibleRef> references,
      List<BibleRef> referencesSplit,
      List<Verse> versesSplit,
      Map<DateTime, Verse> histories,
      List<Pericope> pericopes,
      List<Pericope> pericopesSplit,
      List<BibleNote> notes,
      List<PericopeParalel> pericopesParalels,
      List<PericopeParalel> pericopesParalelsSplit,
      BibleBook? currentBook,
      BibleBook? currentBookSplit,
      List<Verse> selectedVerse,
      List<Verse> hightlightedVerse,
      Verse? todayReading,
      DateTime? lastOpenBible,
      String defaultFont,
      double defaultTextScale,
      double defaultTextHeight,
      String sortNotesBy,
      bool enableAudio,
      bool isSpeaking,
      String currentWord,
      int currentStartWord,
      int currentEndWord,
      List<BibleBook> selectedFilterBooks,
      Map<String, Map> voices,
      double speedRate,
      double pitchRate});

  $VerseCopyWith<$Res>? get currentBible;
  $VerseCopyWith<$Res>? get prevBible;
  $VerseCopyWith<$Res>? get currentBibleSplit;
  $VerseCopyWith<$Res>? get prevBibleSplit;
  $BibleBookCopyWith<$Res>? get currentBook;
  $BibleBookCopyWith<$Res>? get currentBookSplit;
  $VerseCopyWith<$Res>? get todayReading;
}

/// @nodoc
class _$BibleStateCopyWithImpl<$Res, $Val extends BibleState>
    implements $BibleStateCopyWith<$Res> {
  _$BibleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBibleCode = null,
    Object? splitBibleCode = null,
    Object? bibleCodes = null,
    Object? currentBible = freezed,
    Object? prevBible = freezed,
    Object? currentBibleSplit = freezed,
    Object? prevBibleSplit = freezed,
    Object? books = null,
    Object? booksSplit = null,
    Object? verses = null,
    Object? bookmarks = null,
    Object? references = null,
    Object? referencesSplit = null,
    Object? versesSplit = null,
    Object? histories = null,
    Object? pericopes = null,
    Object? pericopesSplit = null,
    Object? notes = null,
    Object? pericopesParalels = null,
    Object? pericopesParalelsSplit = null,
    Object? currentBook = freezed,
    Object? currentBookSplit = freezed,
    Object? selectedVerse = null,
    Object? hightlightedVerse = null,
    Object? todayReading = freezed,
    Object? lastOpenBible = freezed,
    Object? defaultFont = null,
    Object? defaultTextScale = null,
    Object? defaultTextHeight = null,
    Object? sortNotesBy = null,
    Object? enableAudio = null,
    Object? isSpeaking = null,
    Object? currentWord = null,
    Object? currentStartWord = null,
    Object? currentEndWord = null,
    Object? selectedFilterBooks = null,
    Object? voices = null,
    Object? speedRate = null,
    Object? pitchRate = null,
  }) {
    return _then(_value.copyWith(
      currentBibleCode: null == currentBibleCode
          ? _value.currentBibleCode
          : currentBibleCode // ignore: cast_nullable_to_non_nullable
              as String,
      splitBibleCode: null == splitBibleCode
          ? _value.splitBibleCode
          : splitBibleCode // ignore: cast_nullable_to_non_nullable
              as String,
      bibleCodes: null == bibleCodes
          ? _value.bibleCodes
          : bibleCodes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currentBible: freezed == currentBible
          ? _value.currentBible
          : currentBible // ignore: cast_nullable_to_non_nullable
              as Verse?,
      prevBible: freezed == prevBible
          ? _value.prevBible
          : prevBible // ignore: cast_nullable_to_non_nullable
              as Verse?,
      currentBibleSplit: freezed == currentBibleSplit
          ? _value.currentBibleSplit
          : currentBibleSplit // ignore: cast_nullable_to_non_nullable
              as Verse?,
      prevBibleSplit: freezed == prevBibleSplit
          ? _value.prevBibleSplit
          : prevBibleSplit // ignore: cast_nullable_to_non_nullable
              as Verse?,
      books: null == books
          ? _value.books
          : books // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      booksSplit: null == booksSplit
          ? _value.booksSplit
          : booksSplit // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      bookmarks: null == bookmarks
          ? _value.bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<BibleBookmark>,
      references: null == references
          ? _value.references
          : references // ignore: cast_nullable_to_non_nullable
              as List<BibleRef>,
      referencesSplit: null == referencesSplit
          ? _value.referencesSplit
          : referencesSplit // ignore: cast_nullable_to_non_nullable
              as List<BibleRef>,
      versesSplit: null == versesSplit
          ? _value.versesSplit
          : versesSplit // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      histories: null == histories
          ? _value.histories
          : histories // ignore: cast_nullable_to_non_nullable
              as Map<DateTime, Verse>,
      pericopes: null == pericopes
          ? _value.pericopes
          : pericopes // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      pericopesSplit: null == pericopesSplit
          ? _value.pericopesSplit
          : pericopesSplit // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<BibleNote>,
      pericopesParalels: null == pericopesParalels
          ? _value.pericopesParalels
          : pericopesParalels // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      pericopesParalelsSplit: null == pericopesParalelsSplit
          ? _value.pericopesParalelsSplit
          : pericopesParalelsSplit // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      currentBook: freezed == currentBook
          ? _value.currentBook
          : currentBook // ignore: cast_nullable_to_non_nullable
              as BibleBook?,
      currentBookSplit: freezed == currentBookSplit
          ? _value.currentBookSplit
          : currentBookSplit // ignore: cast_nullable_to_non_nullable
              as BibleBook?,
      selectedVerse: null == selectedVerse
          ? _value.selectedVerse
          : selectedVerse // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      hightlightedVerse: null == hightlightedVerse
          ? _value.hightlightedVerse
          : hightlightedVerse // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      todayReading: freezed == todayReading
          ? _value.todayReading
          : todayReading // ignore: cast_nullable_to_non_nullable
              as Verse?,
      lastOpenBible: freezed == lastOpenBible
          ? _value.lastOpenBible
          : lastOpenBible // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      defaultFont: null == defaultFont
          ? _value.defaultFont
          : defaultFont // ignore: cast_nullable_to_non_nullable
              as String,
      defaultTextScale: null == defaultTextScale
          ? _value.defaultTextScale
          : defaultTextScale // ignore: cast_nullable_to_non_nullable
              as double,
      defaultTextHeight: null == defaultTextHeight
          ? _value.defaultTextHeight
          : defaultTextHeight // ignore: cast_nullable_to_non_nullable
              as double,
      sortNotesBy: null == sortNotesBy
          ? _value.sortNotesBy
          : sortNotesBy // ignore: cast_nullable_to_non_nullable
              as String,
      enableAudio: null == enableAudio
          ? _value.enableAudio
          : enableAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeaking: null == isSpeaking
          ? _value.isSpeaking
          : isSpeaking // ignore: cast_nullable_to_non_nullable
              as bool,
      currentWord: null == currentWord
          ? _value.currentWord
          : currentWord // ignore: cast_nullable_to_non_nullable
              as String,
      currentStartWord: null == currentStartWord
          ? _value.currentStartWord
          : currentStartWord // ignore: cast_nullable_to_non_nullable
              as int,
      currentEndWord: null == currentEndWord
          ? _value.currentEndWord
          : currentEndWord // ignore: cast_nullable_to_non_nullable
              as int,
      selectedFilterBooks: null == selectedFilterBooks
          ? _value.selectedFilterBooks
          : selectedFilterBooks // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      voices: null == voices
          ? _value.voices
          : voices // ignore: cast_nullable_to_non_nullable
              as Map<String, Map>,
      speedRate: null == speedRate
          ? _value.speedRate
          : speedRate // ignore: cast_nullable_to_non_nullable
              as double,
      pitchRate: null == pitchRate
          ? _value.pitchRate
          : pitchRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VerseCopyWith<$Res>? get currentBible {
    if (_value.currentBible == null) {
      return null;
    }

    return $VerseCopyWith<$Res>(_value.currentBible!, (value) {
      return _then(_value.copyWith(currentBible: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $VerseCopyWith<$Res>? get prevBible {
    if (_value.prevBible == null) {
      return null;
    }

    return $VerseCopyWith<$Res>(_value.prevBible!, (value) {
      return _then(_value.copyWith(prevBible: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $VerseCopyWith<$Res>? get currentBibleSplit {
    if (_value.currentBibleSplit == null) {
      return null;
    }

    return $VerseCopyWith<$Res>(_value.currentBibleSplit!, (value) {
      return _then(_value.copyWith(currentBibleSplit: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $VerseCopyWith<$Res>? get prevBibleSplit {
    if (_value.prevBibleSplit == null) {
      return null;
    }

    return $VerseCopyWith<$Res>(_value.prevBibleSplit!, (value) {
      return _then(_value.copyWith(prevBibleSplit: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BibleBookCopyWith<$Res>? get currentBook {
    if (_value.currentBook == null) {
      return null;
    }

    return $BibleBookCopyWith<$Res>(_value.currentBook!, (value) {
      return _then(_value.copyWith(currentBook: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BibleBookCopyWith<$Res>? get currentBookSplit {
    if (_value.currentBookSplit == null) {
      return null;
    }

    return $BibleBookCopyWith<$Res>(_value.currentBookSplit!, (value) {
      return _then(_value.copyWith(currentBookSplit: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $VerseCopyWith<$Res>? get todayReading {
    if (_value.todayReading == null) {
      return null;
    }

    return $VerseCopyWith<$Res>(_value.todayReading!, (value) {
      return _then(_value.copyWith(todayReading: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_BibleStateCopyWith<$Res>
    implements $BibleStateCopyWith<$Res> {
  factory _$$_BibleStateCopyWith(
          _$_BibleState value, $Res Function(_$_BibleState) then) =
      __$$_BibleStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String currentBibleCode,
      String splitBibleCode,
      List<String> bibleCodes,
      Verse? currentBible,
      Verse? prevBible,
      Verse? currentBibleSplit,
      Verse? prevBibleSplit,
      List<BibleBook> books,
      List<BibleBook> booksSplit,
      List<Verse> verses,
      List<BibleBookmark> bookmarks,
      List<BibleRef> references,
      List<BibleRef> referencesSplit,
      List<Verse> versesSplit,
      Map<DateTime, Verse> histories,
      List<Pericope> pericopes,
      List<Pericope> pericopesSplit,
      List<BibleNote> notes,
      List<PericopeParalel> pericopesParalels,
      List<PericopeParalel> pericopesParalelsSplit,
      BibleBook? currentBook,
      BibleBook? currentBookSplit,
      List<Verse> selectedVerse,
      List<Verse> hightlightedVerse,
      Verse? todayReading,
      DateTime? lastOpenBible,
      String defaultFont,
      double defaultTextScale,
      double defaultTextHeight,
      String sortNotesBy,
      bool enableAudio,
      bool isSpeaking,
      String currentWord,
      int currentStartWord,
      int currentEndWord,
      List<BibleBook> selectedFilterBooks,
      Map<String, Map> voices,
      double speedRate,
      double pitchRate});

  @override
  $VerseCopyWith<$Res>? get currentBible;
  @override
  $VerseCopyWith<$Res>? get prevBible;
  @override
  $VerseCopyWith<$Res>? get currentBibleSplit;
  @override
  $VerseCopyWith<$Res>? get prevBibleSplit;
  @override
  $BibleBookCopyWith<$Res>? get currentBook;
  @override
  $BibleBookCopyWith<$Res>? get currentBookSplit;
  @override
  $VerseCopyWith<$Res>? get todayReading;
}

/// @nodoc
class __$$_BibleStateCopyWithImpl<$Res>
    extends _$BibleStateCopyWithImpl<$Res, _$_BibleState>
    implements _$$_BibleStateCopyWith<$Res> {
  __$$_BibleStateCopyWithImpl(
      _$_BibleState _value, $Res Function(_$_BibleState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBibleCode = null,
    Object? splitBibleCode = null,
    Object? bibleCodes = null,
    Object? currentBible = freezed,
    Object? prevBible = freezed,
    Object? currentBibleSplit = freezed,
    Object? prevBibleSplit = freezed,
    Object? books = null,
    Object? booksSplit = null,
    Object? verses = null,
    Object? bookmarks = null,
    Object? references = null,
    Object? referencesSplit = null,
    Object? versesSplit = null,
    Object? histories = null,
    Object? pericopes = null,
    Object? pericopesSplit = null,
    Object? notes = null,
    Object? pericopesParalels = null,
    Object? pericopesParalelsSplit = null,
    Object? currentBook = freezed,
    Object? currentBookSplit = freezed,
    Object? selectedVerse = null,
    Object? hightlightedVerse = null,
    Object? todayReading = freezed,
    Object? lastOpenBible = freezed,
    Object? defaultFont = null,
    Object? defaultTextScale = null,
    Object? defaultTextHeight = null,
    Object? sortNotesBy = null,
    Object? enableAudio = null,
    Object? isSpeaking = null,
    Object? currentWord = null,
    Object? currentStartWord = null,
    Object? currentEndWord = null,
    Object? selectedFilterBooks = null,
    Object? voices = null,
    Object? speedRate = null,
    Object? pitchRate = null,
  }) {
    return _then(_$_BibleState(
      currentBibleCode: null == currentBibleCode
          ? _value.currentBibleCode
          : currentBibleCode // ignore: cast_nullable_to_non_nullable
              as String,
      splitBibleCode: null == splitBibleCode
          ? _value.splitBibleCode
          : splitBibleCode // ignore: cast_nullable_to_non_nullable
              as String,
      bibleCodes: null == bibleCodes
          ? _value._bibleCodes
          : bibleCodes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currentBible: freezed == currentBible
          ? _value.currentBible
          : currentBible // ignore: cast_nullable_to_non_nullable
              as Verse?,
      prevBible: freezed == prevBible
          ? _value.prevBible
          : prevBible // ignore: cast_nullable_to_non_nullable
              as Verse?,
      currentBibleSplit: freezed == currentBibleSplit
          ? _value.currentBibleSplit
          : currentBibleSplit // ignore: cast_nullable_to_non_nullable
              as Verse?,
      prevBibleSplit: freezed == prevBibleSplit
          ? _value.prevBibleSplit
          : prevBibleSplit // ignore: cast_nullable_to_non_nullable
              as Verse?,
      books: null == books
          ? _value._books
          : books // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      booksSplit: null == booksSplit
          ? _value._booksSplit
          : booksSplit // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      bookmarks: null == bookmarks
          ? _value._bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<BibleBookmark>,
      references: null == references
          ? _value._references
          : references // ignore: cast_nullable_to_non_nullable
              as List<BibleRef>,
      referencesSplit: null == referencesSplit
          ? _value._referencesSplit
          : referencesSplit // ignore: cast_nullable_to_non_nullable
              as List<BibleRef>,
      versesSplit: null == versesSplit
          ? _value._versesSplit
          : versesSplit // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      histories: null == histories
          ? _value._histories
          : histories // ignore: cast_nullable_to_non_nullable
              as Map<DateTime, Verse>,
      pericopes: null == pericopes
          ? _value._pericopes
          : pericopes // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      pericopesSplit: null == pericopesSplit
          ? _value._pericopesSplit
          : pericopesSplit // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      notes: null == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<BibleNote>,
      pericopesParalels: null == pericopesParalels
          ? _value._pericopesParalels
          : pericopesParalels // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      pericopesParalelsSplit: null == pericopesParalelsSplit
          ? _value._pericopesParalelsSplit
          : pericopesParalelsSplit // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      currentBook: freezed == currentBook
          ? _value.currentBook
          : currentBook // ignore: cast_nullable_to_non_nullable
              as BibleBook?,
      currentBookSplit: freezed == currentBookSplit
          ? _value.currentBookSplit
          : currentBookSplit // ignore: cast_nullable_to_non_nullable
              as BibleBook?,
      selectedVerse: null == selectedVerse
          ? _value._selectedVerse
          : selectedVerse // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      hightlightedVerse: null == hightlightedVerse
          ? _value._hightlightedVerse
          : hightlightedVerse // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      todayReading: freezed == todayReading
          ? _value.todayReading
          : todayReading // ignore: cast_nullable_to_non_nullable
              as Verse?,
      lastOpenBible: freezed == lastOpenBible
          ? _value.lastOpenBible
          : lastOpenBible // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      defaultFont: null == defaultFont
          ? _value.defaultFont
          : defaultFont // ignore: cast_nullable_to_non_nullable
              as String,
      defaultTextScale: null == defaultTextScale
          ? _value.defaultTextScale
          : defaultTextScale // ignore: cast_nullable_to_non_nullable
              as double,
      defaultTextHeight: null == defaultTextHeight
          ? _value.defaultTextHeight
          : defaultTextHeight // ignore: cast_nullable_to_non_nullable
              as double,
      sortNotesBy: null == sortNotesBy
          ? _value.sortNotesBy
          : sortNotesBy // ignore: cast_nullable_to_non_nullable
              as String,
      enableAudio: null == enableAudio
          ? _value.enableAudio
          : enableAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeaking: null == isSpeaking
          ? _value.isSpeaking
          : isSpeaking // ignore: cast_nullable_to_non_nullable
              as bool,
      currentWord: null == currentWord
          ? _value.currentWord
          : currentWord // ignore: cast_nullable_to_non_nullable
              as String,
      currentStartWord: null == currentStartWord
          ? _value.currentStartWord
          : currentStartWord // ignore: cast_nullable_to_non_nullable
              as int,
      currentEndWord: null == currentEndWord
          ? _value.currentEndWord
          : currentEndWord // ignore: cast_nullable_to_non_nullable
              as int,
      selectedFilterBooks: null == selectedFilterBooks
          ? _value._selectedFilterBooks
          : selectedFilterBooks // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      voices: null == voices
          ? _value._voices
          : voices // ignore: cast_nullable_to_non_nullable
              as Map<String, Map>,
      speedRate: null == speedRate
          ? _value.speedRate
          : speedRate // ignore: cast_nullable_to_non_nullable
              as double,
      pitchRate: null == pitchRate
          ? _value.pitchRate
          : pitchRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BibleState extends _BibleState {
  const _$_BibleState(
      {this.currentBibleCode = 'b_tb',
      this.splitBibleCode = 'b_tb',
      final List<String> bibleCodes = const [],
      this.currentBible,
      this.prevBible,
      this.currentBibleSplit,
      this.prevBibleSplit,
      final List<BibleBook> books = const [],
      final List<BibleBook> booksSplit = const [],
      final List<Verse> verses = const [],
      final List<BibleBookmark> bookmarks = const [],
      final List<BibleRef> references = const [],
      final List<BibleRef> referencesSplit = const [],
      final List<Verse> versesSplit = const [],
      final Map<DateTime, Verse> histories = const {},
      final List<Pericope> pericopes = const [],
      final List<Pericope> pericopesSplit = const [],
      final List<BibleNote> notes = const [],
      final List<PericopeParalel> pericopesParalels = const [],
      final List<PericopeParalel> pericopesParalelsSplit = const [],
      this.currentBook,
      this.currentBookSplit,
      final List<Verse> selectedVerse = const [],
      final List<Verse> hightlightedVerse = const [],
      this.todayReading,
      this.lastOpenBible,
      this.defaultFont = 'Roboto',
      this.defaultTextScale = 1.2,
      this.defaultTextHeight = 1.5,
      this.sortNotesBy = 'Newest',
      this.enableAudio = false,
      this.isSpeaking = false,
      this.currentWord = '',
      this.currentStartWord = 0,
      this.currentEndWord = 0,
      final List<BibleBook> selectedFilterBooks = const [],
      final Map<String, Map> voices = const {},
      this.speedRate = .35,
      this.pitchRate = .90})
      : _bibleCodes = bibleCodes,
        _books = books,
        _booksSplit = booksSplit,
        _verses = verses,
        _bookmarks = bookmarks,
        _references = references,
        _referencesSplit = referencesSplit,
        _versesSplit = versesSplit,
        _histories = histories,
        _pericopes = pericopes,
        _pericopesSplit = pericopesSplit,
        _notes = notes,
        _pericopesParalels = pericopesParalels,
        _pericopesParalelsSplit = pericopesParalelsSplit,
        _selectedVerse = selectedVerse,
        _hightlightedVerse = hightlightedVerse,
        _selectedFilterBooks = selectedFilterBooks,
        _voices = voices,
        super._();

  factory _$_BibleState.fromJson(Map<String, dynamic> json) =>
      _$$_BibleStateFromJson(json);

  @override
  @JsonKey()
  final String currentBibleCode;
  @override
  @JsonKey()
  final String splitBibleCode;
  final List<String> _bibleCodes;
  @override
  @JsonKey()
  List<String> get bibleCodes {
    if (_bibleCodes is EqualUnmodifiableListView) return _bibleCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bibleCodes);
  }

  @override
  final Verse? currentBible;
  @override
  final Verse? prevBible;
  @override
  final Verse? currentBibleSplit;
  @override
  final Verse? prevBibleSplit;
  final List<BibleBook> _books;
  @override
  @JsonKey()
  List<BibleBook> get books {
    if (_books is EqualUnmodifiableListView) return _books;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_books);
  }

  final List<BibleBook> _booksSplit;
  @override
  @JsonKey()
  List<BibleBook> get booksSplit {
    if (_booksSplit is EqualUnmodifiableListView) return _booksSplit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_booksSplit);
  }

  final List<Verse> _verses;
  @override
  @JsonKey()
  List<Verse> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

  final List<BibleBookmark> _bookmarks;
  @override
  @JsonKey()
  List<BibleBookmark> get bookmarks {
    if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bookmarks);
  }

  final List<BibleRef> _references;
  @override
  @JsonKey()
  List<BibleRef> get references {
    if (_references is EqualUnmodifiableListView) return _references;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_references);
  }

  final List<BibleRef> _referencesSplit;
  @override
  @JsonKey()
  List<BibleRef> get referencesSplit {
    if (_referencesSplit is EqualUnmodifiableListView) return _referencesSplit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_referencesSplit);
  }

  final List<Verse> _versesSplit;
  @override
  @JsonKey()
  List<Verse> get versesSplit {
    if (_versesSplit is EqualUnmodifiableListView) return _versesSplit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_versesSplit);
  }

  final Map<DateTime, Verse> _histories;
  @override
  @JsonKey()
  Map<DateTime, Verse> get histories {
    if (_histories is EqualUnmodifiableMapView) return _histories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_histories);
  }

  final List<Pericope> _pericopes;
  @override
  @JsonKey()
  List<Pericope> get pericopes {
    if (_pericopes is EqualUnmodifiableListView) return _pericopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pericopes);
  }

  final List<Pericope> _pericopesSplit;
  @override
  @JsonKey()
  List<Pericope> get pericopesSplit {
    if (_pericopesSplit is EqualUnmodifiableListView) return _pericopesSplit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pericopesSplit);
  }

  final List<BibleNote> _notes;
  @override
  @JsonKey()
  List<BibleNote> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  final List<PericopeParalel> _pericopesParalels;
  @override
  @JsonKey()
  List<PericopeParalel> get pericopesParalels {
    if (_pericopesParalels is EqualUnmodifiableListView)
      return _pericopesParalels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pericopesParalels);
  }

  final List<PericopeParalel> _pericopesParalelsSplit;
  @override
  @JsonKey()
  List<PericopeParalel> get pericopesParalelsSplit {
    if (_pericopesParalelsSplit is EqualUnmodifiableListView)
      return _pericopesParalelsSplit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pericopesParalelsSplit);
  }

  @override
  final BibleBook? currentBook;
  @override
  final BibleBook? currentBookSplit;
  final List<Verse> _selectedVerse;
  @override
  @JsonKey()
  List<Verse> get selectedVerse {
    if (_selectedVerse is EqualUnmodifiableListView) return _selectedVerse;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedVerse);
  }

  final List<Verse> _hightlightedVerse;
  @override
  @JsonKey()
  List<Verse> get hightlightedVerse {
    if (_hightlightedVerse is EqualUnmodifiableListView)
      return _hightlightedVerse;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hightlightedVerse);
  }

  @override
  final Verse? todayReading;
  @override
  final DateTime? lastOpenBible;
  @override
  @JsonKey()
  final String defaultFont;
  @override
  @JsonKey()
  final double defaultTextScale;
  @override
  @JsonKey()
  final double defaultTextHeight;
  @override
  @JsonKey()
  final String sortNotesBy;
  @override
  @JsonKey()
  final bool enableAudio;
  @override
  @JsonKey()
  final bool isSpeaking;
  @override
  @JsonKey()
  final String currentWord;
  @override
  @JsonKey()
  final int currentStartWord;
  @override
  @JsonKey()
  final int currentEndWord;
  final List<BibleBook> _selectedFilterBooks;
  @override
  @JsonKey()
  List<BibleBook> get selectedFilterBooks {
    if (_selectedFilterBooks is EqualUnmodifiableListView)
      return _selectedFilterBooks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedFilterBooks);
  }

  final Map<String, Map> _voices;
  @override
  @JsonKey()
  Map<String, Map> get voices {
    if (_voices is EqualUnmodifiableMapView) return _voices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_voices);
  }

  @override
  @JsonKey()
  final double speedRate;
  @override
  @JsonKey()
  final double pitchRate;

  @override
  String toString() {
    return 'BibleState(currentBibleCode: $currentBibleCode, splitBibleCode: $splitBibleCode, bibleCodes: $bibleCodes, currentBible: $currentBible, prevBible: $prevBible, currentBibleSplit: $currentBibleSplit, prevBibleSplit: $prevBibleSplit, books: $books, booksSplit: $booksSplit, verses: $verses, bookmarks: $bookmarks, references: $references, referencesSplit: $referencesSplit, versesSplit: $versesSplit, histories: $histories, pericopes: $pericopes, pericopesSplit: $pericopesSplit, notes: $notes, pericopesParalels: $pericopesParalels, pericopesParalelsSplit: $pericopesParalelsSplit, currentBook: $currentBook, currentBookSplit: $currentBookSplit, selectedVerse: $selectedVerse, hightlightedVerse: $hightlightedVerse, todayReading: $todayReading, lastOpenBible: $lastOpenBible, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight, sortNotesBy: $sortNotesBy, enableAudio: $enableAudio, isSpeaking: $isSpeaking, currentWord: $currentWord, currentStartWord: $currentStartWord, currentEndWord: $currentEndWord, selectedFilterBooks: $selectedFilterBooks, voices: $voices, speedRate: $speedRate, pitchRate: $pitchRate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BibleState &&
            (identical(other.currentBibleCode, currentBibleCode) ||
                other.currentBibleCode == currentBibleCode) &&
            (identical(other.splitBibleCode, splitBibleCode) ||
                other.splitBibleCode == splitBibleCode) &&
            const DeepCollectionEquality()
                .equals(other._bibleCodes, _bibleCodes) &&
            (identical(other.currentBible, currentBible) ||
                other.currentBible == currentBible) &&
            (identical(other.prevBible, prevBible) ||
                other.prevBible == prevBible) &&
            (identical(other.currentBibleSplit, currentBibleSplit) ||
                other.currentBibleSplit == currentBibleSplit) &&
            (identical(other.prevBibleSplit, prevBibleSplit) ||
                other.prevBibleSplit == prevBibleSplit) &&
            const DeepCollectionEquality().equals(other._books, _books) &&
            const DeepCollectionEquality()
                .equals(other._booksSplit, _booksSplit) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            const DeepCollectionEquality()
                .equals(other._bookmarks, _bookmarks) &&
            const DeepCollectionEquality()
                .equals(other._references, _references) &&
            const DeepCollectionEquality()
                .equals(other._referencesSplit, _referencesSplit) &&
            const DeepCollectionEquality()
                .equals(other._versesSplit, _versesSplit) &&
            const DeepCollectionEquality()
                .equals(other._histories, _histories) &&
            const DeepCollectionEquality()
                .equals(other._pericopes, _pericopes) &&
            const DeepCollectionEquality()
                .equals(other._pericopesSplit, _pericopesSplit) &&
            const DeepCollectionEquality().equals(other._notes, _notes) &&
            const DeepCollectionEquality()
                .equals(other._pericopesParalels, _pericopesParalels) &&
            const DeepCollectionEquality().equals(
                other._pericopesParalelsSplit, _pericopesParalelsSplit) &&
            (identical(other.currentBook, currentBook) ||
                other.currentBook == currentBook) &&
            (identical(other.currentBookSplit, currentBookSplit) ||
                other.currentBookSplit == currentBookSplit) &&
            const DeepCollectionEquality()
                .equals(other._selectedVerse, _selectedVerse) &&
            const DeepCollectionEquality()
                .equals(other._hightlightedVerse, _hightlightedVerse) &&
            (identical(other.todayReading, todayReading) ||
                other.todayReading == todayReading) &&
            (identical(other.lastOpenBible, lastOpenBible) ||
                other.lastOpenBible == lastOpenBible) &&
            (identical(other.defaultFont, defaultFont) ||
                other.defaultFont == defaultFont) &&
            (identical(other.defaultTextScale, defaultTextScale) ||
                other.defaultTextScale == defaultTextScale) &&
            (identical(other.defaultTextHeight, defaultTextHeight) ||
                other.defaultTextHeight == defaultTextHeight) &&
            (identical(other.sortNotesBy, sortNotesBy) ||
                other.sortNotesBy == sortNotesBy) &&
            (identical(other.enableAudio, enableAudio) ||
                other.enableAudio == enableAudio) &&
            (identical(other.isSpeaking, isSpeaking) ||
                other.isSpeaking == isSpeaking) &&
            (identical(other.currentWord, currentWord) ||
                other.currentWord == currentWord) &&
            (identical(other.currentStartWord, currentStartWord) ||
                other.currentStartWord == currentStartWord) &&
            (identical(other.currentEndWord, currentEndWord) ||
                other.currentEndWord == currentEndWord) &&
            const DeepCollectionEquality()
                .equals(other._selectedFilterBooks, _selectedFilterBooks) &&
            const DeepCollectionEquality().equals(other._voices, _voices) &&
            (identical(other.speedRate, speedRate) ||
                other.speedRate == speedRate) &&
            (identical(other.pitchRate, pitchRate) ||
                other.pitchRate == pitchRate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        currentBibleCode,
        splitBibleCode,
        const DeepCollectionEquality().hash(_bibleCodes),
        currentBible,
        prevBible,
        currentBibleSplit,
        prevBibleSplit,
        const DeepCollectionEquality().hash(_books),
        const DeepCollectionEquality().hash(_booksSplit),
        const DeepCollectionEquality().hash(_verses),
        const DeepCollectionEquality().hash(_bookmarks),
        const DeepCollectionEquality().hash(_references),
        const DeepCollectionEquality().hash(_referencesSplit),
        const DeepCollectionEquality().hash(_versesSplit),
        const DeepCollectionEquality().hash(_histories),
        const DeepCollectionEquality().hash(_pericopes),
        const DeepCollectionEquality().hash(_pericopesSplit),
        const DeepCollectionEquality().hash(_notes),
        const DeepCollectionEquality().hash(_pericopesParalels),
        const DeepCollectionEquality().hash(_pericopesParalelsSplit),
        currentBook,
        currentBookSplit,
        const DeepCollectionEquality().hash(_selectedVerse),
        const DeepCollectionEquality().hash(_hightlightedVerse),
        todayReading,
        lastOpenBible,
        defaultFont,
        defaultTextScale,
        defaultTextHeight,
        sortNotesBy,
        enableAudio,
        isSpeaking,
        currentWord,
        currentStartWord,
        currentEndWord,
        const DeepCollectionEquality().hash(_selectedFilterBooks),
        const DeepCollectionEquality().hash(_voices),
        speedRate,
        pitchRate
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BibleStateCopyWith<_$_BibleState> get copyWith =>
      __$$_BibleStateCopyWithImpl<_$_BibleState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BibleStateToJson(
      this,
    );
  }
}

abstract class _BibleState extends BibleState {
  const factory _BibleState(
      {final String currentBibleCode,
      final String splitBibleCode,
      final List<String> bibleCodes,
      final Verse? currentBible,
      final Verse? prevBible,
      final Verse? currentBibleSplit,
      final Verse? prevBibleSplit,
      final List<BibleBook> books,
      final List<BibleBook> booksSplit,
      final List<Verse> verses,
      final List<BibleBookmark> bookmarks,
      final List<BibleRef> references,
      final List<BibleRef> referencesSplit,
      final List<Verse> versesSplit,
      final Map<DateTime, Verse> histories,
      final List<Pericope> pericopes,
      final List<Pericope> pericopesSplit,
      final List<BibleNote> notes,
      final List<PericopeParalel> pericopesParalels,
      final List<PericopeParalel> pericopesParalelsSplit,
      final BibleBook? currentBook,
      final BibleBook? currentBookSplit,
      final List<Verse> selectedVerse,
      final List<Verse> hightlightedVerse,
      final Verse? todayReading,
      final DateTime? lastOpenBible,
      final String defaultFont,
      final double defaultTextScale,
      final double defaultTextHeight,
      final String sortNotesBy,
      final bool enableAudio,
      final bool isSpeaking,
      final String currentWord,
      final int currentStartWord,
      final int currentEndWord,
      final List<BibleBook> selectedFilterBooks,
      final Map<String, Map> voices,
      final double speedRate,
      final double pitchRate}) = _$_BibleState;
  const _BibleState._() : super._();

  factory _BibleState.fromJson(Map<String, dynamic> json) =
      _$_BibleState.fromJson;

  @override
  String get currentBibleCode;
  @override
  String get splitBibleCode;
  @override
  List<String> get bibleCodes;
  @override
  Verse? get currentBible;
  @override
  Verse? get prevBible;
  @override
  Verse? get currentBibleSplit;
  @override
  Verse? get prevBibleSplit;
  @override
  List<BibleBook> get books;
  @override
  List<BibleBook> get booksSplit;
  @override
  List<Verse> get verses;
  @override
  List<BibleBookmark> get bookmarks;
  @override
  List<BibleRef> get references;
  @override
  List<BibleRef> get referencesSplit;
  @override
  List<Verse> get versesSplit;
  @override
  Map<DateTime, Verse> get histories;
  @override
  List<Pericope> get pericopes;
  @override
  List<Pericope> get pericopesSplit;
  @override
  List<BibleNote> get notes;
  @override
  List<PericopeParalel> get pericopesParalels;
  @override
  List<PericopeParalel> get pericopesParalelsSplit;
  @override
  BibleBook? get currentBook;
  @override
  BibleBook? get currentBookSplit;
  @override
  List<Verse> get selectedVerse;
  @override
  List<Verse> get hightlightedVerse;
  @override
  Verse? get todayReading;
  @override
  DateTime? get lastOpenBible;
  @override
  String get defaultFont;
  @override
  double get defaultTextScale;
  @override
  double get defaultTextHeight;
  @override
  String get sortNotesBy;
  @override
  bool get enableAudio;
  @override
  bool get isSpeaking;
  @override
  String get currentWord;
  @override
  int get currentStartWord;
  @override
  int get currentEndWord;
  @override
  List<BibleBook> get selectedFilterBooks;
  @override
  Map<String, Map> get voices;
  @override
  double get speedRate;
  @override
  double get pitchRate;
  @override
  @JsonKey(ignore: true)
  _$$_BibleStateCopyWith<_$_BibleState> get copyWith =>
      throw _privateConstructorUsedError;
}

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
  String? get currentBibleCode => throw _privateConstructorUsedError;
  String? get splitBibleCode => throw _privateConstructorUsedError;
  List<String> get bibleCodes => throw _privateConstructorUsedError;
  Verse? get currentBible => throw _privateConstructorUsedError;
  Verse? get prevBible => throw _privateConstructorUsedError;
  List<BibleBook> get books => throw _privateConstructorUsedError;
  List<Verse> get verses => throw _privateConstructorUsedError;
  List<Verse> get bookmarks => throw _privateConstructorUsedError;
  List<BibleRef> get references => throw _privateConstructorUsedError;
  List<Verse> get splitVerses => throw _privateConstructorUsedError;
  Map<DateTime, Verse> get histories => throw _privateConstructorUsedError;
  List<Pericope> get pericopes => throw _privateConstructorUsedError;
  List<Pericope> get splitPericopes => throw _privateConstructorUsedError;
  List<BibleNote> get notes => throw _privateConstructorUsedError;
  List<PericopeParalel> get pericopesParalels =>
      throw _privateConstructorUsedError;
  List<PericopeParalel> get splitPericopesParalels =>
      throw _privateConstructorUsedError;
  BibleBook? get currentBook => throw _privateConstructorUsedError;
  BibleBook? get splitBook => throw _privateConstructorUsedError;
  List<Verse> get selectedVerse => throw _privateConstructorUsedError;
  List<Verse> get hightlightedVerse => throw _privateConstructorUsedError;
  Verse? get todayReading => throw _privateConstructorUsedError;
  DateTime? get lastOpenBible => throw _privateConstructorUsedError;
  String get defaultFont => throw _privateConstructorUsedError;
  double get defaultTextScale => throw _privateConstructorUsedError;
  double get defaultTextHeight => throw _privateConstructorUsedError;
  String get sortNotesBy => throw _privateConstructorUsedError;

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
      {String? currentBibleCode,
      String? splitBibleCode,
      List<String> bibleCodes,
      Verse? currentBible,
      Verse? prevBible,
      List<BibleBook> books,
      List<Verse> verses,
      List<Verse> bookmarks,
      List<BibleRef> references,
      List<Verse> splitVerses,
      Map<DateTime, Verse> histories,
      List<Pericope> pericopes,
      List<Pericope> splitPericopes,
      List<BibleNote> notes,
      List<PericopeParalel> pericopesParalels,
      List<PericopeParalel> splitPericopesParalels,
      BibleBook? currentBook,
      BibleBook? splitBook,
      List<Verse> selectedVerse,
      List<Verse> hightlightedVerse,
      Verse? todayReading,
      DateTime? lastOpenBible,
      String defaultFont,
      double defaultTextScale,
      double defaultTextHeight,
      String sortNotesBy});

  $VerseCopyWith<$Res>? get currentBible;
  $VerseCopyWith<$Res>? get prevBible;
  $BibleBookCopyWith<$Res>? get currentBook;
  $BibleBookCopyWith<$Res>? get splitBook;
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
    Object? currentBibleCode = freezed,
    Object? splitBibleCode = freezed,
    Object? bibleCodes = null,
    Object? currentBible = freezed,
    Object? prevBible = freezed,
    Object? books = null,
    Object? verses = null,
    Object? bookmarks = null,
    Object? references = null,
    Object? splitVerses = null,
    Object? histories = null,
    Object? pericopes = null,
    Object? splitPericopes = null,
    Object? notes = null,
    Object? pericopesParalels = null,
    Object? splitPericopesParalels = null,
    Object? currentBook = freezed,
    Object? splitBook = freezed,
    Object? selectedVerse = null,
    Object? hightlightedVerse = null,
    Object? todayReading = freezed,
    Object? lastOpenBible = freezed,
    Object? defaultFont = null,
    Object? defaultTextScale = null,
    Object? defaultTextHeight = null,
    Object? sortNotesBy = null,
  }) {
    return _then(_value.copyWith(
      currentBibleCode: freezed == currentBibleCode
          ? _value.currentBibleCode
          : currentBibleCode // ignore: cast_nullable_to_non_nullable
              as String?,
      splitBibleCode: freezed == splitBibleCode
          ? _value.splitBibleCode
          : splitBibleCode // ignore: cast_nullable_to_non_nullable
              as String?,
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
      books: null == books
          ? _value.books
          : books // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      bookmarks: null == bookmarks
          ? _value.bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      references: null == references
          ? _value.references
          : references // ignore: cast_nullable_to_non_nullable
              as List<BibleRef>,
      splitVerses: null == splitVerses
          ? _value.splitVerses
          : splitVerses // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      histories: null == histories
          ? _value.histories
          : histories // ignore: cast_nullable_to_non_nullable
              as Map<DateTime, Verse>,
      pericopes: null == pericopes
          ? _value.pericopes
          : pericopes // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      splitPericopes: null == splitPericopes
          ? _value.splitPericopes
          : splitPericopes // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<BibleNote>,
      pericopesParalels: null == pericopesParalels
          ? _value.pericopesParalels
          : pericopesParalels // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      splitPericopesParalels: null == splitPericopesParalels
          ? _value.splitPericopesParalels
          : splitPericopesParalels // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      currentBook: freezed == currentBook
          ? _value.currentBook
          : currentBook // ignore: cast_nullable_to_non_nullable
              as BibleBook?,
      splitBook: freezed == splitBook
          ? _value.splitBook
          : splitBook // ignore: cast_nullable_to_non_nullable
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
  $BibleBookCopyWith<$Res>? get splitBook {
    if (_value.splitBook == null) {
      return null;
    }

    return $BibleBookCopyWith<$Res>(_value.splitBook!, (value) {
      return _then(_value.copyWith(splitBook: value) as $Val);
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
      {String? currentBibleCode,
      String? splitBibleCode,
      List<String> bibleCodes,
      Verse? currentBible,
      Verse? prevBible,
      List<BibleBook> books,
      List<Verse> verses,
      List<Verse> bookmarks,
      List<BibleRef> references,
      List<Verse> splitVerses,
      Map<DateTime, Verse> histories,
      List<Pericope> pericopes,
      List<Pericope> splitPericopes,
      List<BibleNote> notes,
      List<PericopeParalel> pericopesParalels,
      List<PericopeParalel> splitPericopesParalels,
      BibleBook? currentBook,
      BibleBook? splitBook,
      List<Verse> selectedVerse,
      List<Verse> hightlightedVerse,
      Verse? todayReading,
      DateTime? lastOpenBible,
      String defaultFont,
      double defaultTextScale,
      double defaultTextHeight,
      String sortNotesBy});

  @override
  $VerseCopyWith<$Res>? get currentBible;
  @override
  $VerseCopyWith<$Res>? get prevBible;
  @override
  $BibleBookCopyWith<$Res>? get currentBook;
  @override
  $BibleBookCopyWith<$Res>? get splitBook;
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
    Object? currentBibleCode = freezed,
    Object? splitBibleCode = freezed,
    Object? bibleCodes = null,
    Object? currentBible = freezed,
    Object? prevBible = freezed,
    Object? books = null,
    Object? verses = null,
    Object? bookmarks = null,
    Object? references = null,
    Object? splitVerses = null,
    Object? histories = null,
    Object? pericopes = null,
    Object? splitPericopes = null,
    Object? notes = null,
    Object? pericopesParalels = null,
    Object? splitPericopesParalels = null,
    Object? currentBook = freezed,
    Object? splitBook = freezed,
    Object? selectedVerse = null,
    Object? hightlightedVerse = null,
    Object? todayReading = freezed,
    Object? lastOpenBible = freezed,
    Object? defaultFont = null,
    Object? defaultTextScale = null,
    Object? defaultTextHeight = null,
    Object? sortNotesBy = null,
  }) {
    return _then(_$_BibleState(
      currentBibleCode: freezed == currentBibleCode
          ? _value.currentBibleCode
          : currentBibleCode // ignore: cast_nullable_to_non_nullable
              as String?,
      splitBibleCode: freezed == splitBibleCode
          ? _value.splitBibleCode
          : splitBibleCode // ignore: cast_nullable_to_non_nullable
              as String?,
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
      books: null == books
          ? _value._books
          : books // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      bookmarks: null == bookmarks
          ? _value._bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      references: null == references
          ? _value._references
          : references // ignore: cast_nullable_to_non_nullable
              as List<BibleRef>,
      splitVerses: null == splitVerses
          ? _value._splitVerses
          : splitVerses // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      histories: null == histories
          ? _value._histories
          : histories // ignore: cast_nullable_to_non_nullable
              as Map<DateTime, Verse>,
      pericopes: null == pericopes
          ? _value._pericopes
          : pericopes // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      splitPericopes: null == splitPericopes
          ? _value._splitPericopes
          : splitPericopes // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      notes: null == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<BibleNote>,
      pericopesParalels: null == pericopesParalels
          ? _value._pericopesParalels
          : pericopesParalels // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      splitPericopesParalels: null == splitPericopesParalels
          ? _value._splitPericopesParalels
          : splitPericopesParalels // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      currentBook: freezed == currentBook
          ? _value.currentBook
          : currentBook // ignore: cast_nullable_to_non_nullable
              as BibleBook?,
      splitBook: freezed == splitBook
          ? _value.splitBook
          : splitBook // ignore: cast_nullable_to_non_nullable
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
      final List<BibleBook> books = const [],
      final List<Verse> verses = const [],
      final List<Verse> bookmarks = const [],
      final List<BibleRef> references = const [],
      final List<Verse> splitVerses = const [],
      final Map<DateTime, Verse> histories = const {},
      final List<Pericope> pericopes = const [],
      final List<Pericope> splitPericopes = const [],
      final List<BibleNote> notes = const [],
      final List<PericopeParalel> pericopesParalels = const [],
      final List<PericopeParalel> splitPericopesParalels = const [],
      this.currentBook,
      this.splitBook,
      final List<Verse> selectedVerse = const [],
      final List<Verse> hightlightedVerse = const [],
      this.todayReading,
      this.lastOpenBible,
      this.defaultFont = 'Roboto',
      this.defaultTextScale = 1,
      this.defaultTextHeight = 1.5,
      this.sortNotesBy = 'Newest'})
      : _bibleCodes = bibleCodes,
        _books = books,
        _verses = verses,
        _bookmarks = bookmarks,
        _references = references,
        _splitVerses = splitVerses,
        _histories = histories,
        _pericopes = pericopes,
        _splitPericopes = splitPericopes,
        _notes = notes,
        _pericopesParalels = pericopesParalels,
        _splitPericopesParalels = splitPericopesParalels,
        _selectedVerse = selectedVerse,
        _hightlightedVerse = hightlightedVerse,
        super._();

  factory _$_BibleState.fromJson(Map<String, dynamic> json) =>
      _$$_BibleStateFromJson(json);

  @override
  @JsonKey()
  final String? currentBibleCode;
  @override
  @JsonKey()
  final String? splitBibleCode;
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
  final List<BibleBook> _books;
  @override
  @JsonKey()
  List<BibleBook> get books {
    if (_books is EqualUnmodifiableListView) return _books;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_books);
  }

  final List<Verse> _verses;
  @override
  @JsonKey()
  List<Verse> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

  final List<Verse> _bookmarks;
  @override
  @JsonKey()
  List<Verse> get bookmarks {
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

  final List<Verse> _splitVerses;
  @override
  @JsonKey()
  List<Verse> get splitVerses {
    if (_splitVerses is EqualUnmodifiableListView) return _splitVerses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_splitVerses);
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

  final List<Pericope> _splitPericopes;
  @override
  @JsonKey()
  List<Pericope> get splitPericopes {
    if (_splitPericopes is EqualUnmodifiableListView) return _splitPericopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_splitPericopes);
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

  final List<PericopeParalel> _splitPericopesParalels;
  @override
  @JsonKey()
  List<PericopeParalel> get splitPericopesParalels {
    if (_splitPericopesParalels is EqualUnmodifiableListView)
      return _splitPericopesParalels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_splitPericopesParalels);
  }

  @override
  final BibleBook? currentBook;
  @override
  final BibleBook? splitBook;
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
  String toString() {
    return 'BibleState(currentBibleCode: $currentBibleCode, splitBibleCode: $splitBibleCode, bibleCodes: $bibleCodes, currentBible: $currentBible, prevBible: $prevBible, books: $books, verses: $verses, bookmarks: $bookmarks, references: $references, splitVerses: $splitVerses, histories: $histories, pericopes: $pericopes, splitPericopes: $splitPericopes, notes: $notes, pericopesParalels: $pericopesParalels, splitPericopesParalels: $splitPericopesParalels, currentBook: $currentBook, splitBook: $splitBook, selectedVerse: $selectedVerse, hightlightedVerse: $hightlightedVerse, todayReading: $todayReading, lastOpenBible: $lastOpenBible, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight, sortNotesBy: $sortNotesBy)';
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
            const DeepCollectionEquality().equals(other._books, _books) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            const DeepCollectionEquality()
                .equals(other._bookmarks, _bookmarks) &&
            const DeepCollectionEquality()
                .equals(other._references, _references) &&
            const DeepCollectionEquality()
                .equals(other._splitVerses, _splitVerses) &&
            const DeepCollectionEquality()
                .equals(other._histories, _histories) &&
            const DeepCollectionEquality()
                .equals(other._pericopes, _pericopes) &&
            const DeepCollectionEquality()
                .equals(other._splitPericopes, _splitPericopes) &&
            const DeepCollectionEquality().equals(other._notes, _notes) &&
            const DeepCollectionEquality()
                .equals(other._pericopesParalels, _pericopesParalels) &&
            const DeepCollectionEquality().equals(
                other._splitPericopesParalels, _splitPericopesParalels) &&
            (identical(other.currentBook, currentBook) ||
                other.currentBook == currentBook) &&
            (identical(other.splitBook, splitBook) ||
                other.splitBook == splitBook) &&
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
                other.sortNotesBy == sortNotesBy));
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
        const DeepCollectionEquality().hash(_books),
        const DeepCollectionEquality().hash(_verses),
        const DeepCollectionEquality().hash(_bookmarks),
        const DeepCollectionEquality().hash(_references),
        const DeepCollectionEquality().hash(_splitVerses),
        const DeepCollectionEquality().hash(_histories),
        const DeepCollectionEquality().hash(_pericopes),
        const DeepCollectionEquality().hash(_splitPericopes),
        const DeepCollectionEquality().hash(_notes),
        const DeepCollectionEquality().hash(_pericopesParalels),
        const DeepCollectionEquality().hash(_splitPericopesParalels),
        currentBook,
        splitBook,
        const DeepCollectionEquality().hash(_selectedVerse),
        const DeepCollectionEquality().hash(_hightlightedVerse),
        todayReading,
        lastOpenBible,
        defaultFont,
        defaultTextScale,
        defaultTextHeight,
        sortNotesBy
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
      {final String? currentBibleCode,
      final String? splitBibleCode,
      final List<String> bibleCodes,
      final Verse? currentBible,
      final Verse? prevBible,
      final List<BibleBook> books,
      final List<Verse> verses,
      final List<Verse> bookmarks,
      final List<BibleRef> references,
      final List<Verse> splitVerses,
      final Map<DateTime, Verse> histories,
      final List<Pericope> pericopes,
      final List<Pericope> splitPericopes,
      final List<BibleNote> notes,
      final List<PericopeParalel> pericopesParalels,
      final List<PericopeParalel> splitPericopesParalels,
      final BibleBook? currentBook,
      final BibleBook? splitBook,
      final List<Verse> selectedVerse,
      final List<Verse> hightlightedVerse,
      final Verse? todayReading,
      final DateTime? lastOpenBible,
      final String defaultFont,
      final double defaultTextScale,
      final double defaultTextHeight,
      final String sortNotesBy}) = _$_BibleState;
  const _BibleState._() : super._();

  factory _BibleState.fromJson(Map<String, dynamic> json) =
      _$_BibleState.fromJson;

  @override
  String? get currentBibleCode;
  @override
  String? get splitBibleCode;
  @override
  List<String> get bibleCodes;
  @override
  Verse? get currentBible;
  @override
  Verse? get prevBible;
  @override
  List<BibleBook> get books;
  @override
  List<Verse> get verses;
  @override
  List<Verse> get bookmarks;
  @override
  List<BibleRef> get references;
  @override
  List<Verse> get splitVerses;
  @override
  Map<DateTime, Verse> get histories;
  @override
  List<Pericope> get pericopes;
  @override
  List<Pericope> get splitPericopes;
  @override
  List<BibleNote> get notes;
  @override
  List<PericopeParalel> get pericopesParalels;
  @override
  List<PericopeParalel> get splitPericopesParalels;
  @override
  BibleBook? get currentBook;
  @override
  BibleBook? get splitBook;
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
  @JsonKey(ignore: true)
  _$$_BibleStateCopyWith<_$_BibleState> get copyWith =>
      throw _privateConstructorUsedError;
}

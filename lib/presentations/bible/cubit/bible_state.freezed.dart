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
  List<String> get bibleCodes => throw _privateConstructorUsedError;
  Bible? get currentBible => throw _privateConstructorUsedError;
  List<BibleBook> get books => throw _privateConstructorUsedError;
  List<Bible> get bibles => throw _privateConstructorUsedError;
  List<Pericope> get pericopes => throw _privateConstructorUsedError;
  List<PericopeParalel> get pericopesParalels =>
      throw _privateConstructorUsedError;
  BibleBook? get currentBook => throw _privateConstructorUsedError;
  String? get bookTitle => throw _privateConstructorUsedError;
  List<Bible> get selectedVerse => throw _privateConstructorUsedError;
  List<Bible> get hightlightedVerse => throw _privateConstructorUsedError;

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
      List<String> bibleCodes,
      Bible? currentBible,
      List<BibleBook> books,
      List<Bible> bibles,
      List<Pericope> pericopes,
      List<PericopeParalel> pericopesParalels,
      BibleBook? currentBook,
      String? bookTitle,
      List<Bible> selectedVerse,
      List<Bible> hightlightedVerse});

  $BibleCopyWith<$Res>? get currentBible;
  $BibleBookCopyWith<$Res>? get currentBook;
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
    Object? bibleCodes = null,
    Object? currentBible = freezed,
    Object? books = null,
    Object? bibles = null,
    Object? pericopes = null,
    Object? pericopesParalels = null,
    Object? currentBook = freezed,
    Object? bookTitle = freezed,
    Object? selectedVerse = null,
    Object? hightlightedVerse = null,
  }) {
    return _then(_value.copyWith(
      currentBibleCode: freezed == currentBibleCode
          ? _value.currentBibleCode
          : currentBibleCode // ignore: cast_nullable_to_non_nullable
              as String?,
      bibleCodes: null == bibleCodes
          ? _value.bibleCodes
          : bibleCodes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currentBible: freezed == currentBible
          ? _value.currentBible
          : currentBible // ignore: cast_nullable_to_non_nullable
              as Bible?,
      books: null == books
          ? _value.books
          : books // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      bibles: null == bibles
          ? _value.bibles
          : bibles // ignore: cast_nullable_to_non_nullable
              as List<Bible>,
      pericopes: null == pericopes
          ? _value.pericopes
          : pericopes // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      pericopesParalels: null == pericopesParalels
          ? _value.pericopesParalels
          : pericopesParalels // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      currentBook: freezed == currentBook
          ? _value.currentBook
          : currentBook // ignore: cast_nullable_to_non_nullable
              as BibleBook?,
      bookTitle: freezed == bookTitle
          ? _value.bookTitle
          : bookTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedVerse: null == selectedVerse
          ? _value.selectedVerse
          : selectedVerse // ignore: cast_nullable_to_non_nullable
              as List<Bible>,
      hightlightedVerse: null == hightlightedVerse
          ? _value.hightlightedVerse
          : hightlightedVerse // ignore: cast_nullable_to_non_nullable
              as List<Bible>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BibleCopyWith<$Res>? get currentBible {
    if (_value.currentBible == null) {
      return null;
    }

    return $BibleCopyWith<$Res>(_value.currentBible!, (value) {
      return _then(_value.copyWith(currentBible: value) as $Val);
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
      List<String> bibleCodes,
      Bible? currentBible,
      List<BibleBook> books,
      List<Bible> bibles,
      List<Pericope> pericopes,
      List<PericopeParalel> pericopesParalels,
      BibleBook? currentBook,
      String? bookTitle,
      List<Bible> selectedVerse,
      List<Bible> hightlightedVerse});

  @override
  $BibleCopyWith<$Res>? get currentBible;
  @override
  $BibleBookCopyWith<$Res>? get currentBook;
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
    Object? bibleCodes = null,
    Object? currentBible = freezed,
    Object? books = null,
    Object? bibles = null,
    Object? pericopes = null,
    Object? pericopesParalels = null,
    Object? currentBook = freezed,
    Object? bookTitle = freezed,
    Object? selectedVerse = null,
    Object? hightlightedVerse = null,
  }) {
    return _then(_$_BibleState(
      currentBibleCode: freezed == currentBibleCode
          ? _value.currentBibleCode
          : currentBibleCode // ignore: cast_nullable_to_non_nullable
              as String?,
      bibleCodes: null == bibleCodes
          ? _value._bibleCodes
          : bibleCodes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currentBible: freezed == currentBible
          ? _value.currentBible
          : currentBible // ignore: cast_nullable_to_non_nullable
              as Bible?,
      books: null == books
          ? _value._books
          : books // ignore: cast_nullable_to_non_nullable
              as List<BibleBook>,
      bibles: null == bibles
          ? _value._bibles
          : bibles // ignore: cast_nullable_to_non_nullable
              as List<Bible>,
      pericopes: null == pericopes
          ? _value._pericopes
          : pericopes // ignore: cast_nullable_to_non_nullable
              as List<Pericope>,
      pericopesParalels: null == pericopesParalels
          ? _value._pericopesParalels
          : pericopesParalels // ignore: cast_nullable_to_non_nullable
              as List<PericopeParalel>,
      currentBook: freezed == currentBook
          ? _value.currentBook
          : currentBook // ignore: cast_nullable_to_non_nullable
              as BibleBook?,
      bookTitle: freezed == bookTitle
          ? _value.bookTitle
          : bookTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedVerse: null == selectedVerse
          ? _value._selectedVerse
          : selectedVerse // ignore: cast_nullable_to_non_nullable
              as List<Bible>,
      hightlightedVerse: null == hightlightedVerse
          ? _value._hightlightedVerse
          : hightlightedVerse // ignore: cast_nullable_to_non_nullable
              as List<Bible>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BibleState extends _BibleState {
  const _$_BibleState(
      {this.currentBibleCode,
      final List<String> bibleCodes = const [],
      this.currentBible,
      final List<BibleBook> books = const [],
      final List<Bible> bibles = const [],
      final List<Pericope> pericopes = const [],
      final List<PericopeParalel> pericopesParalels = const [],
      this.currentBook,
      this.bookTitle,
      final List<Bible> selectedVerse = const [],
      final List<Bible> hightlightedVerse = const []})
      : _bibleCodes = bibleCodes,
        _books = books,
        _bibles = bibles,
        _pericopes = pericopes,
        _pericopesParalels = pericopesParalels,
        _selectedVerse = selectedVerse,
        _hightlightedVerse = hightlightedVerse,
        super._();

  factory _$_BibleState.fromJson(Map<String, dynamic> json) =>
      _$$_BibleStateFromJson(json);

  @override
  final String? currentBibleCode;
  final List<String> _bibleCodes;
  @override
  @JsonKey()
  List<String> get bibleCodes {
    if (_bibleCodes is EqualUnmodifiableListView) return _bibleCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bibleCodes);
  }

  @override
  final Bible? currentBible;
  final List<BibleBook> _books;
  @override
  @JsonKey()
  List<BibleBook> get books {
    if (_books is EqualUnmodifiableListView) return _books;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_books);
  }

  final List<Bible> _bibles;
  @override
  @JsonKey()
  List<Bible> get bibles {
    if (_bibles is EqualUnmodifiableListView) return _bibles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bibles);
  }

  final List<Pericope> _pericopes;
  @override
  @JsonKey()
  List<Pericope> get pericopes {
    if (_pericopes is EqualUnmodifiableListView) return _pericopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pericopes);
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

  @override
  final BibleBook? currentBook;
  @override
  final String? bookTitle;
  final List<Bible> _selectedVerse;
  @override
  @JsonKey()
  List<Bible> get selectedVerse {
    if (_selectedVerse is EqualUnmodifiableListView) return _selectedVerse;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedVerse);
  }

  final List<Bible> _hightlightedVerse;
  @override
  @JsonKey()
  List<Bible> get hightlightedVerse {
    if (_hightlightedVerse is EqualUnmodifiableListView)
      return _hightlightedVerse;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hightlightedVerse);
  }

  @override
  String toString() {
    return 'BibleState(currentBibleCode: $currentBibleCode, bibleCodes: $bibleCodes, currentBible: $currentBible, books: $books, bibles: $bibles, pericopes: $pericopes, pericopesParalels: $pericopesParalels, currentBook: $currentBook, bookTitle: $bookTitle, selectedVerse: $selectedVerse, hightlightedVerse: $hightlightedVerse)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BibleState &&
            (identical(other.currentBibleCode, currentBibleCode) ||
                other.currentBibleCode == currentBibleCode) &&
            const DeepCollectionEquality()
                .equals(other._bibleCodes, _bibleCodes) &&
            (identical(other.currentBible, currentBible) ||
                other.currentBible == currentBible) &&
            const DeepCollectionEquality().equals(other._books, _books) &&
            const DeepCollectionEquality().equals(other._bibles, _bibles) &&
            const DeepCollectionEquality()
                .equals(other._pericopes, _pericopes) &&
            const DeepCollectionEquality()
                .equals(other._pericopesParalels, _pericopesParalels) &&
            (identical(other.currentBook, currentBook) ||
                other.currentBook == currentBook) &&
            (identical(other.bookTitle, bookTitle) ||
                other.bookTitle == bookTitle) &&
            const DeepCollectionEquality()
                .equals(other._selectedVerse, _selectedVerse) &&
            const DeepCollectionEquality()
                .equals(other._hightlightedVerse, _hightlightedVerse));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentBibleCode,
      const DeepCollectionEquality().hash(_bibleCodes),
      currentBible,
      const DeepCollectionEquality().hash(_books),
      const DeepCollectionEquality().hash(_bibles),
      const DeepCollectionEquality().hash(_pericopes),
      const DeepCollectionEquality().hash(_pericopesParalels),
      currentBook,
      bookTitle,
      const DeepCollectionEquality().hash(_selectedVerse),
      const DeepCollectionEquality().hash(_hightlightedVerse));

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
      final List<String> bibleCodes,
      final Bible? currentBible,
      final List<BibleBook> books,
      final List<Bible> bibles,
      final List<Pericope> pericopes,
      final List<PericopeParalel> pericopesParalels,
      final BibleBook? currentBook,
      final String? bookTitle,
      final List<Bible> selectedVerse,
      final List<Bible> hightlightedVerse}) = _$_BibleState;
  const _BibleState._() : super._();

  factory _BibleState.fromJson(Map<String, dynamic> json) =
      _$_BibleState.fromJson;

  @override
  String? get currentBibleCode;
  @override
  List<String> get bibleCodes;
  @override
  Bible? get currentBible;
  @override
  List<BibleBook> get books;
  @override
  List<Bible> get bibles;
  @override
  List<Pericope> get pericopes;
  @override
  List<PericopeParalel> get pericopesParalels;
  @override
  BibleBook? get currentBook;
  @override
  String? get bookTitle;
  @override
  List<Bible> get selectedVerse;
  @override
  List<Bible> get hightlightedVerse;
  @override
  @JsonKey(ignore: true)
  _$$_BibleStateCopyWith<_$_BibleState> get copyWith =>
      throw _privateConstructorUsedError;
}

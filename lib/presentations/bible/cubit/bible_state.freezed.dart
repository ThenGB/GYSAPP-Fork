// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BibleState {

 String get currentBibleCode; String get splitBibleCode; List<String> get bibleCodes; Verse? get currentBible; Verse? get prevBible; Verse? get currentBibleSplit; Verse? get prevBibleSplit; List<BibleBook> get books; List<BibleBook> get booksSplit; List<Verse> get verses; List<Verse> get versesSplit; List<BibleBookmark> get bookmarks; List<BibleRef> get references; List<BibleRef> get referencesSplit; Map<DateTime, Verse> get histories; List<Pericope> get pericopes; List<Pericope> get pericopesSplit; List<BibleNote> get notes; List<PericopeParalel> get pericopesParalels; List<PericopeParalel> get pericopesParalelsSplit; BibleBook? get currentBook; BibleBook? get currentBookSplit; List<Verse> get selectedVerse; List<Verse> get hightlightedVerse; Verse? get todayReading; DateTime? get lastOpenBible; String get defaultFont; double get defaultTextScale; double get defaultTextHeight; bool get followGlobalFontSettings; String get sortNotesBy; bool get enableAudio; bool get isSpeaking; bool get isSplitContentLoading; String get currentWord; int get currentStartWord; int get currentEndWord; List<BibleBook> get selectedFilterBooks; Map<String, Map> get voices; double get speedRate; double get pitchRate;
/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BibleStateCopyWith<BibleState> get copyWith => _$BibleStateCopyWithImpl<BibleState>(this as BibleState, _$identity);

  /// Serializes this BibleState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BibleState&&(identical(other.currentBibleCode, currentBibleCode) || other.currentBibleCode == currentBibleCode)&&(identical(other.splitBibleCode, splitBibleCode) || other.splitBibleCode == splitBibleCode)&&const DeepCollectionEquality().equals(other.bibleCodes, bibleCodes)&&(identical(other.currentBible, currentBible) || other.currentBible == currentBible)&&(identical(other.prevBible, prevBible) || other.prevBible == prevBible)&&(identical(other.currentBibleSplit, currentBibleSplit) || other.currentBibleSplit == currentBibleSplit)&&(identical(other.prevBibleSplit, prevBibleSplit) || other.prevBibleSplit == prevBibleSplit)&&const DeepCollectionEquality().equals(other.books, books)&&const DeepCollectionEquality().equals(other.booksSplit, booksSplit)&&const DeepCollectionEquality().equals(other.verses, verses)&&const DeepCollectionEquality().equals(other.versesSplit, versesSplit)&&const DeepCollectionEquality().equals(other.bookmarks, bookmarks)&&const DeepCollectionEquality().equals(other.references, references)&&const DeepCollectionEquality().equals(other.referencesSplit, referencesSplit)&&const DeepCollectionEquality().equals(other.histories, histories)&&const DeepCollectionEquality().equals(other.pericopes, pericopes)&&const DeepCollectionEquality().equals(other.pericopesSplit, pericopesSplit)&&const DeepCollectionEquality().equals(other.notes, notes)&&const DeepCollectionEquality().equals(other.pericopesParalels, pericopesParalels)&&const DeepCollectionEquality().equals(other.pericopesParalelsSplit, pericopesParalelsSplit)&&(identical(other.currentBook, currentBook) || other.currentBook == currentBook)&&(identical(other.currentBookSplit, currentBookSplit) || other.currentBookSplit == currentBookSplit)&&const DeepCollectionEquality().equals(other.selectedVerse, selectedVerse)&&const DeepCollectionEquality().equals(other.hightlightedVerse, hightlightedVerse)&&(identical(other.todayReading, todayReading) || other.todayReading == todayReading)&&(identical(other.lastOpenBible, lastOpenBible) || other.lastOpenBible == lastOpenBible)&&(identical(other.defaultFont, defaultFont) || other.defaultFont == defaultFont)&&(identical(other.defaultTextScale, defaultTextScale) || other.defaultTextScale == defaultTextScale)&&(identical(other.defaultTextHeight, defaultTextHeight) || other.defaultTextHeight == defaultTextHeight)&&(identical(other.followGlobalFontSettings, followGlobalFontSettings) || other.followGlobalFontSettings == followGlobalFontSettings)&&(identical(other.sortNotesBy, sortNotesBy) || other.sortNotesBy == sortNotesBy)&&(identical(other.enableAudio, enableAudio) || other.enableAudio == enableAudio)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking)&&(identical(other.isSplitContentLoading, isSplitContentLoading) || other.isSplitContentLoading == isSplitContentLoading)&&(identical(other.currentWord, currentWord) || other.currentWord == currentWord)&&(identical(other.currentStartWord, currentStartWord) || other.currentStartWord == currentStartWord)&&(identical(other.currentEndWord, currentEndWord) || other.currentEndWord == currentEndWord)&&const DeepCollectionEquality().equals(other.selectedFilterBooks, selectedFilterBooks)&&const DeepCollectionEquality().equals(other.voices, voices)&&(identical(other.speedRate, speedRate) || other.speedRate == speedRate)&&(identical(other.pitchRate, pitchRate) || other.pitchRate == pitchRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,currentBibleCode,splitBibleCode,const DeepCollectionEquality().hash(bibleCodes),currentBible,prevBible,currentBibleSplit,prevBibleSplit,const DeepCollectionEquality().hash(books),const DeepCollectionEquality().hash(booksSplit),const DeepCollectionEquality().hash(verses),const DeepCollectionEquality().hash(versesSplit),const DeepCollectionEquality().hash(bookmarks),const DeepCollectionEquality().hash(references),const DeepCollectionEquality().hash(referencesSplit),const DeepCollectionEquality().hash(histories),const DeepCollectionEquality().hash(pericopes),const DeepCollectionEquality().hash(pericopesSplit),const DeepCollectionEquality().hash(notes),const DeepCollectionEquality().hash(pericopesParalels),const DeepCollectionEquality().hash(pericopesParalelsSplit),currentBook,currentBookSplit,const DeepCollectionEquality().hash(selectedVerse),const DeepCollectionEquality().hash(hightlightedVerse),todayReading,lastOpenBible,defaultFont,defaultTextScale,defaultTextHeight,followGlobalFontSettings,sortNotesBy,enableAudio,isSpeaking,isSplitContentLoading,currentWord,currentStartWord,currentEndWord,const DeepCollectionEquality().hash(selectedFilterBooks),const DeepCollectionEquality().hash(voices),speedRate,pitchRate]);

@override
String toString() {
  return 'BibleState(currentBibleCode: $currentBibleCode, splitBibleCode: $splitBibleCode, bibleCodes: $bibleCodes, currentBible: $currentBible, prevBible: $prevBible, currentBibleSplit: $currentBibleSplit, prevBibleSplit: $prevBibleSplit, books: $books, booksSplit: $booksSplit, verses: $verses, versesSplit: $versesSplit, bookmarks: $bookmarks, references: $references, referencesSplit: $referencesSplit, histories: $histories, pericopes: $pericopes, pericopesSplit: $pericopesSplit, notes: $notes, pericopesParalels: $pericopesParalels, pericopesParalelsSplit: $pericopesParalelsSplit, currentBook: $currentBook, currentBookSplit: $currentBookSplit, selectedVerse: $selectedVerse, hightlightedVerse: $hightlightedVerse, todayReading: $todayReading, lastOpenBible: $lastOpenBible, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight, followGlobalFontSettings: $followGlobalFontSettings, sortNotesBy: $sortNotesBy, enableAudio: $enableAudio, isSpeaking: $isSpeaking, isSplitContentLoading: $isSplitContentLoading, currentWord: $currentWord, currentStartWord: $currentStartWord, currentEndWord: $currentEndWord, selectedFilterBooks: $selectedFilterBooks, voices: $voices, speedRate: $speedRate, pitchRate: $pitchRate)';
}


}

/// @nodoc
abstract mixin class $BibleStateCopyWith<$Res>  {
  factory $BibleStateCopyWith(BibleState value, $Res Function(BibleState) _then) = _$BibleStateCopyWithImpl;
@useResult
$Res call({
 String currentBibleCode, String splitBibleCode, List<String> bibleCodes, Verse? currentBible, Verse? prevBible, Verse? currentBibleSplit, Verse? prevBibleSplit, List<BibleBook> books, List<BibleBook> booksSplit, List<Verse> verses, List<Verse> versesSplit, List<BibleBookmark> bookmarks, List<BibleRef> references, List<BibleRef> referencesSplit, Map<DateTime, Verse> histories, List<Pericope> pericopes, List<Pericope> pericopesSplit, List<BibleNote> notes, List<PericopeParalel> pericopesParalels, List<PericopeParalel> pericopesParalelsSplit, BibleBook? currentBook, BibleBook? currentBookSplit, List<Verse> selectedVerse, List<Verse> hightlightedVerse, Verse? todayReading, DateTime? lastOpenBible, String defaultFont, double defaultTextScale, double defaultTextHeight, bool followGlobalFontSettings, String sortNotesBy, bool enableAudio, bool isSpeaking, bool isSplitContentLoading, String currentWord, int currentStartWord, int currentEndWord, List<BibleBook> selectedFilterBooks, Map<String, Map> voices, double speedRate, double pitchRate
});


$VerseCopyWith<$Res>? get currentBible;$VerseCopyWith<$Res>? get prevBible;$VerseCopyWith<$Res>? get currentBibleSplit;$VerseCopyWith<$Res>? get prevBibleSplit;$BibleBookCopyWith<$Res>? get currentBook;$BibleBookCopyWith<$Res>? get currentBookSplit;$VerseCopyWith<$Res>? get todayReading;

}
/// @nodoc
class _$BibleStateCopyWithImpl<$Res>
    implements $BibleStateCopyWith<$Res> {
  _$BibleStateCopyWithImpl(this._self, this._then);

  final BibleState _self;
  final $Res Function(BibleState) _then;

/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentBibleCode = null,Object? splitBibleCode = null,Object? bibleCodes = null,Object? currentBible = freezed,Object? prevBible = freezed,Object? currentBibleSplit = freezed,Object? prevBibleSplit = freezed,Object? books = null,Object? booksSplit = null,Object? verses = null,Object? versesSplit = null,Object? bookmarks = null,Object? references = null,Object? referencesSplit = null,Object? histories = null,Object? pericopes = null,Object? pericopesSplit = null,Object? notes = null,Object? pericopesParalels = null,Object? pericopesParalelsSplit = null,Object? currentBook = freezed,Object? currentBookSplit = freezed,Object? selectedVerse = null,Object? hightlightedVerse = null,Object? todayReading = freezed,Object? lastOpenBible = freezed,Object? defaultFont = null,Object? defaultTextScale = null,Object? defaultTextHeight = null,Object? followGlobalFontSettings = null,Object? sortNotesBy = null,Object? enableAudio = null,Object? isSpeaking = null,Object? isSplitContentLoading = null,Object? currentWord = null,Object? currentStartWord = null,Object? currentEndWord = null,Object? selectedFilterBooks = null,Object? voices = null,Object? speedRate = null,Object? pitchRate = null,}) {
  return _then(_self.copyWith(
currentBibleCode: null == currentBibleCode ? _self.currentBibleCode : currentBibleCode // ignore: cast_nullable_to_non_nullable
as String,splitBibleCode: null == splitBibleCode ? _self.splitBibleCode : splitBibleCode // ignore: cast_nullable_to_non_nullable
as String,bibleCodes: null == bibleCodes ? _self.bibleCodes : bibleCodes // ignore: cast_nullable_to_non_nullable
as List<String>,currentBible: freezed == currentBible ? _self.currentBible : currentBible // ignore: cast_nullable_to_non_nullable
as Verse?,prevBible: freezed == prevBible ? _self.prevBible : prevBible // ignore: cast_nullable_to_non_nullable
as Verse?,currentBibleSplit: freezed == currentBibleSplit ? _self.currentBibleSplit : currentBibleSplit // ignore: cast_nullable_to_non_nullable
as Verse?,prevBibleSplit: freezed == prevBibleSplit ? _self.prevBibleSplit : prevBibleSplit // ignore: cast_nullable_to_non_nullable
as Verse?,books: null == books ? _self.books : books // ignore: cast_nullable_to_non_nullable
as List<BibleBook>,booksSplit: null == booksSplit ? _self.booksSplit : booksSplit // ignore: cast_nullable_to_non_nullable
as List<BibleBook>,verses: null == verses ? _self.verses : verses // ignore: cast_nullable_to_non_nullable
as List<Verse>,versesSplit: null == versesSplit ? _self.versesSplit : versesSplit // ignore: cast_nullable_to_non_nullable
as List<Verse>,bookmarks: null == bookmarks ? _self.bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as List<BibleBookmark>,references: null == references ? _self.references : references // ignore: cast_nullable_to_non_nullable
as List<BibleRef>,referencesSplit: null == referencesSplit ? _self.referencesSplit : referencesSplit // ignore: cast_nullable_to_non_nullable
as List<BibleRef>,histories: null == histories ? _self.histories : histories // ignore: cast_nullable_to_non_nullable
as Map<DateTime, Verse>,pericopes: null == pericopes ? _self.pericopes : pericopes // ignore: cast_nullable_to_non_nullable
as List<Pericope>,pericopesSplit: null == pericopesSplit ? _self.pericopesSplit : pericopesSplit // ignore: cast_nullable_to_non_nullable
as List<Pericope>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<BibleNote>,pericopesParalels: null == pericopesParalels ? _self.pericopesParalels : pericopesParalels // ignore: cast_nullable_to_non_nullable
as List<PericopeParalel>,pericopesParalelsSplit: null == pericopesParalelsSplit ? _self.pericopesParalelsSplit : pericopesParalelsSplit // ignore: cast_nullable_to_non_nullable
as List<PericopeParalel>,currentBook: freezed == currentBook ? _self.currentBook : currentBook // ignore: cast_nullable_to_non_nullable
as BibleBook?,currentBookSplit: freezed == currentBookSplit ? _self.currentBookSplit : currentBookSplit // ignore: cast_nullable_to_non_nullable
as BibleBook?,selectedVerse: null == selectedVerse ? _self.selectedVerse : selectedVerse // ignore: cast_nullable_to_non_nullable
as List<Verse>,hightlightedVerse: null == hightlightedVerse ? _self.hightlightedVerse : hightlightedVerse // ignore: cast_nullable_to_non_nullable
as List<Verse>,todayReading: freezed == todayReading ? _self.todayReading : todayReading // ignore: cast_nullable_to_non_nullable
as Verse?,lastOpenBible: freezed == lastOpenBible ? _self.lastOpenBible : lastOpenBible // ignore: cast_nullable_to_non_nullable
as DateTime?,defaultFont: null == defaultFont ? _self.defaultFont : defaultFont // ignore: cast_nullable_to_non_nullable
as String,defaultTextScale: null == defaultTextScale ? _self.defaultTextScale : defaultTextScale // ignore: cast_nullable_to_non_nullable
as double,defaultTextHeight: null == defaultTextHeight ? _self.defaultTextHeight : defaultTextHeight // ignore: cast_nullable_to_non_nullable
as double,followGlobalFontSettings: null == followGlobalFontSettings ? _self.followGlobalFontSettings : followGlobalFontSettings // ignore: cast_nullable_to_non_nullable
as bool,sortNotesBy: null == sortNotesBy ? _self.sortNotesBy : sortNotesBy // ignore: cast_nullable_to_non_nullable
as String,enableAudio: null == enableAudio ? _self.enableAudio : enableAudio // ignore: cast_nullable_to_non_nullable
as bool,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,isSplitContentLoading: null == isSplitContentLoading ? _self.isSplitContentLoading : isSplitContentLoading // ignore: cast_nullable_to_non_nullable
as bool,currentWord: null == currentWord ? _self.currentWord : currentWord // ignore: cast_nullable_to_non_nullable
as String,currentStartWord: null == currentStartWord ? _self.currentStartWord : currentStartWord // ignore: cast_nullable_to_non_nullable
as int,currentEndWord: null == currentEndWord ? _self.currentEndWord : currentEndWord // ignore: cast_nullable_to_non_nullable
as int,selectedFilterBooks: null == selectedFilterBooks ? _self.selectedFilterBooks : selectedFilterBooks // ignore: cast_nullable_to_non_nullable
as List<BibleBook>,voices: null == voices ? _self.voices : voices // ignore: cast_nullable_to_non_nullable
as Map<String, Map>,speedRate: null == speedRate ? _self.speedRate : speedRate // ignore: cast_nullable_to_non_nullable
as double,pitchRate: null == pitchRate ? _self.pitchRate : pitchRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get currentBible {
    if (_self.currentBible == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.currentBible!, (value) {
    return _then(_self.copyWith(currentBible: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get prevBible {
    if (_self.prevBible == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.prevBible!, (value) {
    return _then(_self.copyWith(prevBible: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get currentBibleSplit {
    if (_self.currentBibleSplit == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.currentBibleSplit!, (value) {
    return _then(_self.copyWith(currentBibleSplit: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get prevBibleSplit {
    if (_self.prevBibleSplit == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.prevBibleSplit!, (value) {
    return _then(_self.copyWith(prevBibleSplit: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BibleBookCopyWith<$Res>? get currentBook {
    if (_self.currentBook == null) {
    return null;
  }

  return $BibleBookCopyWith<$Res>(_self.currentBook!, (value) {
    return _then(_self.copyWith(currentBook: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BibleBookCopyWith<$Res>? get currentBookSplit {
    if (_self.currentBookSplit == null) {
    return null;
  }

  return $BibleBookCopyWith<$Res>(_self.currentBookSplit!, (value) {
    return _then(_self.copyWith(currentBookSplit: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get todayReading {
    if (_self.todayReading == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.todayReading!, (value) {
    return _then(_self.copyWith(todayReading: value));
  });
}
}


/// Adds pattern-matching-related methods to [BibleState].
extension BibleStatePatterns on BibleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BibleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BibleState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BibleState value)  $default,){
final _that = this;
switch (_that) {
case _BibleState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BibleState value)?  $default,){
final _that = this;
switch (_that) {
case _BibleState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentBibleCode,  String splitBibleCode,  List<String> bibleCodes,  Verse? currentBible,  Verse? prevBible,  Verse? currentBibleSplit,  Verse? prevBibleSplit,  List<BibleBook> books,  List<BibleBook> booksSplit,  List<Verse> verses,  List<Verse> versesSplit,  List<BibleBookmark> bookmarks,  List<BibleRef> references,  List<BibleRef> referencesSplit,  Map<DateTime, Verse> histories,  List<Pericope> pericopes,  List<Pericope> pericopesSplit,  List<BibleNote> notes,  List<PericopeParalel> pericopesParalels,  List<PericopeParalel> pericopesParalelsSplit,  BibleBook? currentBook,  BibleBook? currentBookSplit,  List<Verse> selectedVerse,  List<Verse> hightlightedVerse,  Verse? todayReading,  DateTime? lastOpenBible,  String defaultFont,  double defaultTextScale,  double defaultTextHeight,  bool followGlobalFontSettings,  String sortNotesBy,  bool enableAudio,  bool isSpeaking,  bool isSplitContentLoading,  String currentWord,  int currentStartWord,  int currentEndWord,  List<BibleBook> selectedFilterBooks,  Map<String, Map> voices,  double speedRate,  double pitchRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BibleState() when $default != null:
return $default(_that.currentBibleCode,_that.splitBibleCode,_that.bibleCodes,_that.currentBible,_that.prevBible,_that.currentBibleSplit,_that.prevBibleSplit,_that.books,_that.booksSplit,_that.verses,_that.versesSplit,_that.bookmarks,_that.references,_that.referencesSplit,_that.histories,_that.pericopes,_that.pericopesSplit,_that.notes,_that.pericopesParalels,_that.pericopesParalelsSplit,_that.currentBook,_that.currentBookSplit,_that.selectedVerse,_that.hightlightedVerse,_that.todayReading,_that.lastOpenBible,_that.defaultFont,_that.defaultTextScale,_that.defaultTextHeight,_that.followGlobalFontSettings,_that.sortNotesBy,_that.enableAudio,_that.isSpeaking,_that.isSplitContentLoading,_that.currentWord,_that.currentStartWord,_that.currentEndWord,_that.selectedFilterBooks,_that.voices,_that.speedRate,_that.pitchRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentBibleCode,  String splitBibleCode,  List<String> bibleCodes,  Verse? currentBible,  Verse? prevBible,  Verse? currentBibleSplit,  Verse? prevBibleSplit,  List<BibleBook> books,  List<BibleBook> booksSplit,  List<Verse> verses,  List<Verse> versesSplit,  List<BibleBookmark> bookmarks,  List<BibleRef> references,  List<BibleRef> referencesSplit,  Map<DateTime, Verse> histories,  List<Pericope> pericopes,  List<Pericope> pericopesSplit,  List<BibleNote> notes,  List<PericopeParalel> pericopesParalels,  List<PericopeParalel> pericopesParalelsSplit,  BibleBook? currentBook,  BibleBook? currentBookSplit,  List<Verse> selectedVerse,  List<Verse> hightlightedVerse,  Verse? todayReading,  DateTime? lastOpenBible,  String defaultFont,  double defaultTextScale,  double defaultTextHeight,  bool followGlobalFontSettings,  String sortNotesBy,  bool enableAudio,  bool isSpeaking,  bool isSplitContentLoading,  String currentWord,  int currentStartWord,  int currentEndWord,  List<BibleBook> selectedFilterBooks,  Map<String, Map> voices,  double speedRate,  double pitchRate)  $default,) {final _that = this;
switch (_that) {
case _BibleState():
return $default(_that.currentBibleCode,_that.splitBibleCode,_that.bibleCodes,_that.currentBible,_that.prevBible,_that.currentBibleSplit,_that.prevBibleSplit,_that.books,_that.booksSplit,_that.verses,_that.versesSplit,_that.bookmarks,_that.references,_that.referencesSplit,_that.histories,_that.pericopes,_that.pericopesSplit,_that.notes,_that.pericopesParalels,_that.pericopesParalelsSplit,_that.currentBook,_that.currentBookSplit,_that.selectedVerse,_that.hightlightedVerse,_that.todayReading,_that.lastOpenBible,_that.defaultFont,_that.defaultTextScale,_that.defaultTextHeight,_that.followGlobalFontSettings,_that.sortNotesBy,_that.enableAudio,_that.isSpeaking,_that.isSplitContentLoading,_that.currentWord,_that.currentStartWord,_that.currentEndWord,_that.selectedFilterBooks,_that.voices,_that.speedRate,_that.pitchRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentBibleCode,  String splitBibleCode,  List<String> bibleCodes,  Verse? currentBible,  Verse? prevBible,  Verse? currentBibleSplit,  Verse? prevBibleSplit,  List<BibleBook> books,  List<BibleBook> booksSplit,  List<Verse> verses,  List<Verse> versesSplit,  List<BibleBookmark> bookmarks,  List<BibleRef> references,  List<BibleRef> referencesSplit,  Map<DateTime, Verse> histories,  List<Pericope> pericopes,  List<Pericope> pericopesSplit,  List<BibleNote> notes,  List<PericopeParalel> pericopesParalels,  List<PericopeParalel> pericopesParalelsSplit,  BibleBook? currentBook,  BibleBook? currentBookSplit,  List<Verse> selectedVerse,  List<Verse> hightlightedVerse,  Verse? todayReading,  DateTime? lastOpenBible,  String defaultFont,  double defaultTextScale,  double defaultTextHeight,  bool followGlobalFontSettings,  String sortNotesBy,  bool enableAudio,  bool isSpeaking,  bool isSplitContentLoading,  String currentWord,  int currentStartWord,  int currentEndWord,  List<BibleBook> selectedFilterBooks,  Map<String, Map> voices,  double speedRate,  double pitchRate)?  $default,) {final _that = this;
switch (_that) {
case _BibleState() when $default != null:
return $default(_that.currentBibleCode,_that.splitBibleCode,_that.bibleCodes,_that.currentBible,_that.prevBible,_that.currentBibleSplit,_that.prevBibleSplit,_that.books,_that.booksSplit,_that.verses,_that.versesSplit,_that.bookmarks,_that.references,_that.referencesSplit,_that.histories,_that.pericopes,_that.pericopesSplit,_that.notes,_that.pericopesParalels,_that.pericopesParalelsSplit,_that.currentBook,_that.currentBookSplit,_that.selectedVerse,_that.hightlightedVerse,_that.todayReading,_that.lastOpenBible,_that.defaultFont,_that.defaultTextScale,_that.defaultTextHeight,_that.followGlobalFontSettings,_that.sortNotesBy,_that.enableAudio,_that.isSpeaking,_that.isSplitContentLoading,_that.currentWord,_that.currentStartWord,_that.currentEndWord,_that.selectedFilterBooks,_that.voices,_that.speedRate,_that.pitchRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BibleState extends BibleState {
  const _BibleState({this.currentBibleCode = 'b_tb', this.splitBibleCode = 'b_tb', final  List<String> bibleCodes = const [], this.currentBible, this.prevBible, this.currentBibleSplit, this.prevBibleSplit, final  List<BibleBook> books = const [], final  List<BibleBook> booksSplit = const [], final  List<Verse> verses = const [], final  List<Verse> versesSplit = const [], final  List<BibleBookmark> bookmarks = const [], final  List<BibleRef> references = const [], final  List<BibleRef> referencesSplit = const [], final  Map<DateTime, Verse> histories = const {}, final  List<Pericope> pericopes = const [], final  List<Pericope> pericopesSplit = const [], final  List<BibleNote> notes = const [], final  List<PericopeParalel> pericopesParalels = const [], final  List<PericopeParalel> pericopesParalelsSplit = const [], this.currentBook, this.currentBookSplit, final  List<Verse> selectedVerse = const [], final  List<Verse> hightlightedVerse = const [], this.todayReading, this.lastOpenBible, this.defaultFont = 'EB Garamond', this.defaultTextScale = 1.2, this.defaultTextHeight = 1.5, this.followGlobalFontSettings = true, this.sortNotesBy = 'Newest', this.enableAudio = false, this.isSpeaking = false, this.isSplitContentLoading = false, this.currentWord = '', this.currentStartWord = 0, this.currentEndWord = 0, final  List<BibleBook> selectedFilterBooks = const [], final  Map<String, Map> voices = const {}, this.speedRate = .35, this.pitchRate = .90}): _bibleCodes = bibleCodes,_books = books,_booksSplit = booksSplit,_verses = verses,_versesSplit = versesSplit,_bookmarks = bookmarks,_references = references,_referencesSplit = referencesSplit,_histories = histories,_pericopes = pericopes,_pericopesSplit = pericopesSplit,_notes = notes,_pericopesParalels = pericopesParalels,_pericopesParalelsSplit = pericopesParalelsSplit,_selectedVerse = selectedVerse,_hightlightedVerse = hightlightedVerse,_selectedFilterBooks = selectedFilterBooks,_voices = voices,super._();
  factory _BibleState.fromJson(Map<String, dynamic> json) => _$BibleStateFromJson(json);

@override@JsonKey() final  String currentBibleCode;
@override@JsonKey() final  String splitBibleCode;
 final  List<String> _bibleCodes;
@override@JsonKey() List<String> get bibleCodes {
  if (_bibleCodes is EqualUnmodifiableListView) return _bibleCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bibleCodes);
}

@override final  Verse? currentBible;
@override final  Verse? prevBible;
@override final  Verse? currentBibleSplit;
@override final  Verse? prevBibleSplit;
 final  List<BibleBook> _books;
@override@JsonKey() List<BibleBook> get books {
  if (_books is EqualUnmodifiableListView) return _books;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_books);
}

 final  List<BibleBook> _booksSplit;
@override@JsonKey() List<BibleBook> get booksSplit {
  if (_booksSplit is EqualUnmodifiableListView) return _booksSplit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_booksSplit);
}

 final  List<Verse> _verses;
@override@JsonKey() List<Verse> get verses {
  if (_verses is EqualUnmodifiableListView) return _verses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_verses);
}

 final  List<Verse> _versesSplit;
@override@JsonKey() List<Verse> get versesSplit {
  if (_versesSplit is EqualUnmodifiableListView) return _versesSplit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_versesSplit);
}

 final  List<BibleBookmark> _bookmarks;
@override@JsonKey() List<BibleBookmark> get bookmarks {
  if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookmarks);
}

 final  List<BibleRef> _references;
@override@JsonKey() List<BibleRef> get references {
  if (_references is EqualUnmodifiableListView) return _references;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_references);
}

 final  List<BibleRef> _referencesSplit;
@override@JsonKey() List<BibleRef> get referencesSplit {
  if (_referencesSplit is EqualUnmodifiableListView) return _referencesSplit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_referencesSplit);
}

 final  Map<DateTime, Verse> _histories;
@override@JsonKey() Map<DateTime, Verse> get histories {
  if (_histories is EqualUnmodifiableMapView) return _histories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_histories);
}

 final  List<Pericope> _pericopes;
@override@JsonKey() List<Pericope> get pericopes {
  if (_pericopes is EqualUnmodifiableListView) return _pericopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pericopes);
}

 final  List<Pericope> _pericopesSplit;
@override@JsonKey() List<Pericope> get pericopesSplit {
  if (_pericopesSplit is EqualUnmodifiableListView) return _pericopesSplit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pericopesSplit);
}

 final  List<BibleNote> _notes;
@override@JsonKey() List<BibleNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

 final  List<PericopeParalel> _pericopesParalels;
@override@JsonKey() List<PericopeParalel> get pericopesParalels {
  if (_pericopesParalels is EqualUnmodifiableListView) return _pericopesParalels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pericopesParalels);
}

 final  List<PericopeParalel> _pericopesParalelsSplit;
@override@JsonKey() List<PericopeParalel> get pericopesParalelsSplit {
  if (_pericopesParalelsSplit is EqualUnmodifiableListView) return _pericopesParalelsSplit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pericopesParalelsSplit);
}

@override final  BibleBook? currentBook;
@override final  BibleBook? currentBookSplit;
 final  List<Verse> _selectedVerse;
@override@JsonKey() List<Verse> get selectedVerse {
  if (_selectedVerse is EqualUnmodifiableListView) return _selectedVerse;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedVerse);
}

 final  List<Verse> _hightlightedVerse;
@override@JsonKey() List<Verse> get hightlightedVerse {
  if (_hightlightedVerse is EqualUnmodifiableListView) return _hightlightedVerse;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hightlightedVerse);
}

@override final  Verse? todayReading;
@override final  DateTime? lastOpenBible;
@override@JsonKey() final  String defaultFont;
@override@JsonKey() final  double defaultTextScale;
@override@JsonKey() final  double defaultTextHeight;
@override@JsonKey() final  bool followGlobalFontSettings;
@override@JsonKey() final  String sortNotesBy;
@override@JsonKey() final  bool enableAudio;
@override@JsonKey() final  bool isSpeaking;
@override@JsonKey() final  bool isSplitContentLoading;
@override@JsonKey() final  String currentWord;
@override@JsonKey() final  int currentStartWord;
@override@JsonKey() final  int currentEndWord;
 final  List<BibleBook> _selectedFilterBooks;
@override@JsonKey() List<BibleBook> get selectedFilterBooks {
  if (_selectedFilterBooks is EqualUnmodifiableListView) return _selectedFilterBooks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedFilterBooks);
}

 final  Map<String, Map> _voices;
@override@JsonKey() Map<String, Map> get voices {
  if (_voices is EqualUnmodifiableMapView) return _voices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_voices);
}

@override@JsonKey() final  double speedRate;
@override@JsonKey() final  double pitchRate;

/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BibleStateCopyWith<_BibleState> get copyWith => __$BibleStateCopyWithImpl<_BibleState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BibleStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BibleState&&(identical(other.currentBibleCode, currentBibleCode) || other.currentBibleCode == currentBibleCode)&&(identical(other.splitBibleCode, splitBibleCode) || other.splitBibleCode == splitBibleCode)&&const DeepCollectionEquality().equals(other._bibleCodes, _bibleCodes)&&(identical(other.currentBible, currentBible) || other.currentBible == currentBible)&&(identical(other.prevBible, prevBible) || other.prevBible == prevBible)&&(identical(other.currentBibleSplit, currentBibleSplit) || other.currentBibleSplit == currentBibleSplit)&&(identical(other.prevBibleSplit, prevBibleSplit) || other.prevBibleSplit == prevBibleSplit)&&const DeepCollectionEquality().equals(other._books, _books)&&const DeepCollectionEquality().equals(other._booksSplit, _booksSplit)&&const DeepCollectionEquality().equals(other._verses, _verses)&&const DeepCollectionEquality().equals(other._versesSplit, _versesSplit)&&const DeepCollectionEquality().equals(other._bookmarks, _bookmarks)&&const DeepCollectionEquality().equals(other._references, _references)&&const DeepCollectionEquality().equals(other._referencesSplit, _referencesSplit)&&const DeepCollectionEquality().equals(other._histories, _histories)&&const DeepCollectionEquality().equals(other._pericopes, _pericopes)&&const DeepCollectionEquality().equals(other._pericopesSplit, _pericopesSplit)&&const DeepCollectionEquality().equals(other._notes, _notes)&&const DeepCollectionEquality().equals(other._pericopesParalels, _pericopesParalels)&&const DeepCollectionEquality().equals(other._pericopesParalelsSplit, _pericopesParalelsSplit)&&(identical(other.currentBook, currentBook) || other.currentBook == currentBook)&&(identical(other.currentBookSplit, currentBookSplit) || other.currentBookSplit == currentBookSplit)&&const DeepCollectionEquality().equals(other._selectedVerse, _selectedVerse)&&const DeepCollectionEquality().equals(other._hightlightedVerse, _hightlightedVerse)&&(identical(other.todayReading, todayReading) || other.todayReading == todayReading)&&(identical(other.lastOpenBible, lastOpenBible) || other.lastOpenBible == lastOpenBible)&&(identical(other.defaultFont, defaultFont) || other.defaultFont == defaultFont)&&(identical(other.defaultTextScale, defaultTextScale) || other.defaultTextScale == defaultTextScale)&&(identical(other.defaultTextHeight, defaultTextHeight) || other.defaultTextHeight == defaultTextHeight)&&(identical(other.followGlobalFontSettings, followGlobalFontSettings) || other.followGlobalFontSettings == followGlobalFontSettings)&&(identical(other.sortNotesBy, sortNotesBy) || other.sortNotesBy == sortNotesBy)&&(identical(other.enableAudio, enableAudio) || other.enableAudio == enableAudio)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking)&&(identical(other.isSplitContentLoading, isSplitContentLoading) || other.isSplitContentLoading == isSplitContentLoading)&&(identical(other.currentWord, currentWord) || other.currentWord == currentWord)&&(identical(other.currentStartWord, currentStartWord) || other.currentStartWord == currentStartWord)&&(identical(other.currentEndWord, currentEndWord) || other.currentEndWord == currentEndWord)&&const DeepCollectionEquality().equals(other._selectedFilterBooks, _selectedFilterBooks)&&const DeepCollectionEquality().equals(other._voices, _voices)&&(identical(other.speedRate, speedRate) || other.speedRate == speedRate)&&(identical(other.pitchRate, pitchRate) || other.pitchRate == pitchRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,currentBibleCode,splitBibleCode,const DeepCollectionEquality().hash(_bibleCodes),currentBible,prevBible,currentBibleSplit,prevBibleSplit,const DeepCollectionEquality().hash(_books),const DeepCollectionEquality().hash(_booksSplit),const DeepCollectionEquality().hash(_verses),const DeepCollectionEquality().hash(_versesSplit),const DeepCollectionEquality().hash(_bookmarks),const DeepCollectionEquality().hash(_references),const DeepCollectionEquality().hash(_referencesSplit),const DeepCollectionEquality().hash(_histories),const DeepCollectionEquality().hash(_pericopes),const DeepCollectionEquality().hash(_pericopesSplit),const DeepCollectionEquality().hash(_notes),const DeepCollectionEquality().hash(_pericopesParalels),const DeepCollectionEquality().hash(_pericopesParalelsSplit),currentBook,currentBookSplit,const DeepCollectionEquality().hash(_selectedVerse),const DeepCollectionEquality().hash(_hightlightedVerse),todayReading,lastOpenBible,defaultFont,defaultTextScale,defaultTextHeight,followGlobalFontSettings,sortNotesBy,enableAudio,isSpeaking,isSplitContentLoading,currentWord,currentStartWord,currentEndWord,const DeepCollectionEquality().hash(_selectedFilterBooks),const DeepCollectionEquality().hash(_voices),speedRate,pitchRate]);

@override
String toString() {
  return 'BibleState(currentBibleCode: $currentBibleCode, splitBibleCode: $splitBibleCode, bibleCodes: $bibleCodes, currentBible: $currentBible, prevBible: $prevBible, currentBibleSplit: $currentBibleSplit, prevBibleSplit: $prevBibleSplit, books: $books, booksSplit: $booksSplit, verses: $verses, versesSplit: $versesSplit, bookmarks: $bookmarks, references: $references, referencesSplit: $referencesSplit, histories: $histories, pericopes: $pericopes, pericopesSplit: $pericopesSplit, notes: $notes, pericopesParalels: $pericopesParalels, pericopesParalelsSplit: $pericopesParalelsSplit, currentBook: $currentBook, currentBookSplit: $currentBookSplit, selectedVerse: $selectedVerse, hightlightedVerse: $hightlightedVerse, todayReading: $todayReading, lastOpenBible: $lastOpenBible, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight, followGlobalFontSettings: $followGlobalFontSettings, sortNotesBy: $sortNotesBy, enableAudio: $enableAudio, isSpeaking: $isSpeaking, isSplitContentLoading: $isSplitContentLoading, currentWord: $currentWord, currentStartWord: $currentStartWord, currentEndWord: $currentEndWord, selectedFilterBooks: $selectedFilterBooks, voices: $voices, speedRate: $speedRate, pitchRate: $pitchRate)';
}


}

/// @nodoc
abstract mixin class _$BibleStateCopyWith<$Res> implements $BibleStateCopyWith<$Res> {
  factory _$BibleStateCopyWith(_BibleState value, $Res Function(_BibleState) _then) = __$BibleStateCopyWithImpl;
@override @useResult
$Res call({
 String currentBibleCode, String splitBibleCode, List<String> bibleCodes, Verse? currentBible, Verse? prevBible, Verse? currentBibleSplit, Verse? prevBibleSplit, List<BibleBook> books, List<BibleBook> booksSplit, List<Verse> verses, List<Verse> versesSplit, List<BibleBookmark> bookmarks, List<BibleRef> references, List<BibleRef> referencesSplit, Map<DateTime, Verse> histories, List<Pericope> pericopes, List<Pericope> pericopesSplit, List<BibleNote> notes, List<PericopeParalel> pericopesParalels, List<PericopeParalel> pericopesParalelsSplit, BibleBook? currentBook, BibleBook? currentBookSplit, List<Verse> selectedVerse, List<Verse> hightlightedVerse, Verse? todayReading, DateTime? lastOpenBible, String defaultFont, double defaultTextScale, double defaultTextHeight, bool followGlobalFontSettings, String sortNotesBy, bool enableAudio, bool isSpeaking, bool isSplitContentLoading, String currentWord, int currentStartWord, int currentEndWord, List<BibleBook> selectedFilterBooks, Map<String, Map> voices, double speedRate, double pitchRate
});


@override $VerseCopyWith<$Res>? get currentBible;@override $VerseCopyWith<$Res>? get prevBible;@override $VerseCopyWith<$Res>? get currentBibleSplit;@override $VerseCopyWith<$Res>? get prevBibleSplit;@override $BibleBookCopyWith<$Res>? get currentBook;@override $BibleBookCopyWith<$Res>? get currentBookSplit;@override $VerseCopyWith<$Res>? get todayReading;

}
/// @nodoc
class __$BibleStateCopyWithImpl<$Res>
    implements _$BibleStateCopyWith<$Res> {
  __$BibleStateCopyWithImpl(this._self, this._then);

  final _BibleState _self;
  final $Res Function(_BibleState) _then;

/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentBibleCode = null,Object? splitBibleCode = null,Object? bibleCodes = null,Object? currentBible = freezed,Object? prevBible = freezed,Object? currentBibleSplit = freezed,Object? prevBibleSplit = freezed,Object? books = null,Object? booksSplit = null,Object? verses = null,Object? versesSplit = null,Object? bookmarks = null,Object? references = null,Object? referencesSplit = null,Object? histories = null,Object? pericopes = null,Object? pericopesSplit = null,Object? notes = null,Object? pericopesParalels = null,Object? pericopesParalelsSplit = null,Object? currentBook = freezed,Object? currentBookSplit = freezed,Object? selectedVerse = null,Object? hightlightedVerse = null,Object? todayReading = freezed,Object? lastOpenBible = freezed,Object? defaultFont = null,Object? defaultTextScale = null,Object? defaultTextHeight = null,Object? followGlobalFontSettings = null,Object? sortNotesBy = null,Object? enableAudio = null,Object? isSpeaking = null,Object? isSplitContentLoading = null,Object? currentWord = null,Object? currentStartWord = null,Object? currentEndWord = null,Object? selectedFilterBooks = null,Object? voices = null,Object? speedRate = null,Object? pitchRate = null,}) {
  return _then(_BibleState(
currentBibleCode: null == currentBibleCode ? _self.currentBibleCode : currentBibleCode // ignore: cast_nullable_to_non_nullable
as String,splitBibleCode: null == splitBibleCode ? _self.splitBibleCode : splitBibleCode // ignore: cast_nullable_to_non_nullable
as String,bibleCodes: null == bibleCodes ? _self._bibleCodes : bibleCodes // ignore: cast_nullable_to_non_nullable
as List<String>,currentBible: freezed == currentBible ? _self.currentBible : currentBible // ignore: cast_nullable_to_non_nullable
as Verse?,prevBible: freezed == prevBible ? _self.prevBible : prevBible // ignore: cast_nullable_to_non_nullable
as Verse?,currentBibleSplit: freezed == currentBibleSplit ? _self.currentBibleSplit : currentBibleSplit // ignore: cast_nullable_to_non_nullable
as Verse?,prevBibleSplit: freezed == prevBibleSplit ? _self.prevBibleSplit : prevBibleSplit // ignore: cast_nullable_to_non_nullable
as Verse?,books: null == books ? _self._books : books // ignore: cast_nullable_to_non_nullable
as List<BibleBook>,booksSplit: null == booksSplit ? _self._booksSplit : booksSplit // ignore: cast_nullable_to_non_nullable
as List<BibleBook>,verses: null == verses ? _self._verses : verses // ignore: cast_nullable_to_non_nullable
as List<Verse>,versesSplit: null == versesSplit ? _self._versesSplit : versesSplit // ignore: cast_nullable_to_non_nullable
as List<Verse>,bookmarks: null == bookmarks ? _self._bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as List<BibleBookmark>,references: null == references ? _self._references : references // ignore: cast_nullable_to_non_nullable
as List<BibleRef>,referencesSplit: null == referencesSplit ? _self._referencesSplit : referencesSplit // ignore: cast_nullable_to_non_nullable
as List<BibleRef>,histories: null == histories ? _self._histories : histories // ignore: cast_nullable_to_non_nullable
as Map<DateTime, Verse>,pericopes: null == pericopes ? _self._pericopes : pericopes // ignore: cast_nullable_to_non_nullable
as List<Pericope>,pericopesSplit: null == pericopesSplit ? _self._pericopesSplit : pericopesSplit // ignore: cast_nullable_to_non_nullable
as List<Pericope>,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<BibleNote>,pericopesParalels: null == pericopesParalels ? _self._pericopesParalels : pericopesParalels // ignore: cast_nullable_to_non_nullable
as List<PericopeParalel>,pericopesParalelsSplit: null == pericopesParalelsSplit ? _self._pericopesParalelsSplit : pericopesParalelsSplit // ignore: cast_nullable_to_non_nullable
as List<PericopeParalel>,currentBook: freezed == currentBook ? _self.currentBook : currentBook // ignore: cast_nullable_to_non_nullable
as BibleBook?,currentBookSplit: freezed == currentBookSplit ? _self.currentBookSplit : currentBookSplit // ignore: cast_nullable_to_non_nullable
as BibleBook?,selectedVerse: null == selectedVerse ? _self._selectedVerse : selectedVerse // ignore: cast_nullable_to_non_nullable
as List<Verse>,hightlightedVerse: null == hightlightedVerse ? _self._hightlightedVerse : hightlightedVerse // ignore: cast_nullable_to_non_nullable
as List<Verse>,todayReading: freezed == todayReading ? _self.todayReading : todayReading // ignore: cast_nullable_to_non_nullable
as Verse?,lastOpenBible: freezed == lastOpenBible ? _self.lastOpenBible : lastOpenBible // ignore: cast_nullable_to_non_nullable
as DateTime?,defaultFont: null == defaultFont ? _self.defaultFont : defaultFont // ignore: cast_nullable_to_non_nullable
as String,defaultTextScale: null == defaultTextScale ? _self.defaultTextScale : defaultTextScale // ignore: cast_nullable_to_non_nullable
as double,defaultTextHeight: null == defaultTextHeight ? _self.defaultTextHeight : defaultTextHeight // ignore: cast_nullable_to_non_nullable
as double,followGlobalFontSettings: null == followGlobalFontSettings ? _self.followGlobalFontSettings : followGlobalFontSettings // ignore: cast_nullable_to_non_nullable
as bool,sortNotesBy: null == sortNotesBy ? _self.sortNotesBy : sortNotesBy // ignore: cast_nullable_to_non_nullable
as String,enableAudio: null == enableAudio ? _self.enableAudio : enableAudio // ignore: cast_nullable_to_non_nullable
as bool,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,isSplitContentLoading: null == isSplitContentLoading ? _self.isSplitContentLoading : isSplitContentLoading // ignore: cast_nullable_to_non_nullable
as bool,currentWord: null == currentWord ? _self.currentWord : currentWord // ignore: cast_nullable_to_non_nullable
as String,currentStartWord: null == currentStartWord ? _self.currentStartWord : currentStartWord // ignore: cast_nullable_to_non_nullable
as int,currentEndWord: null == currentEndWord ? _self.currentEndWord : currentEndWord // ignore: cast_nullable_to_non_nullable
as int,selectedFilterBooks: null == selectedFilterBooks ? _self._selectedFilterBooks : selectedFilterBooks // ignore: cast_nullable_to_non_nullable
as List<BibleBook>,voices: null == voices ? _self._voices : voices // ignore: cast_nullable_to_non_nullable
as Map<String, Map>,speedRate: null == speedRate ? _self.speedRate : speedRate // ignore: cast_nullable_to_non_nullable
as double,pitchRate: null == pitchRate ? _self.pitchRate : pitchRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get currentBible {
    if (_self.currentBible == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.currentBible!, (value) {
    return _then(_self.copyWith(currentBible: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get prevBible {
    if (_self.prevBible == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.prevBible!, (value) {
    return _then(_self.copyWith(prevBible: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get currentBibleSplit {
    if (_self.currentBibleSplit == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.currentBibleSplit!, (value) {
    return _then(_self.copyWith(currentBibleSplit: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get prevBibleSplit {
    if (_self.prevBibleSplit == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.prevBibleSplit!, (value) {
    return _then(_self.copyWith(prevBibleSplit: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BibleBookCopyWith<$Res>? get currentBook {
    if (_self.currentBook == null) {
    return null;
  }

  return $BibleBookCopyWith<$Res>(_self.currentBook!, (value) {
    return _then(_self.copyWith(currentBook: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BibleBookCopyWith<$Res>? get currentBookSplit {
    if (_self.currentBookSplit == null) {
    return null;
  }

  return $BibleBookCopyWith<$Res>(_self.currentBookSplit!, (value) {
    return _then(_self.copyWith(currentBookSplit: value));
  });
}/// Create a copy of BibleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerseCopyWith<$Res>? get todayReading {
    if (_self.todayReading == null) {
    return null;
  }

  return $VerseCopyWith<$Res>(_self.todayReading!, (value) {
    return _then(_self.copyWith(todayReading: value));
  });
}
}

// dart format on

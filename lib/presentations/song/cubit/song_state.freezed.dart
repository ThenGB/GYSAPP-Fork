// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SongState {

 bool get isLoading; bool get isAudioLoading; bool get isPdfLoading; String? get currentPdfPath; List<SongBook> get songBook; String get bookCode; int get pageIndex; int get verseIndex; bool get isImageMode; bool get showSizer; String get defaultAudioFormat; Song? get selectedSong; List<SongNote> get notes; String get sortNotesBy; List<SongHistory> get histories; List<int> get shuffleIndex; List<SongPlaylist> get playlists; String? get activePlaylistId; String get playlistAutoNextMode; List<int> get playlistShuffleIndex; bool get showAudio; bool get showChord; String get searchTerms; String get defaultFont; double get defaultTextScale; double get defaultTextHeight; Map<String, DateTime> get lastSync; Map<String, DateTime> get remoteLyricsUpdateAt;// New gyschordweb fields
 int get transposeStep; String get chordAccidentalMode;// Enable natural chord detection by default for automatic transpose based on family chord
 bool get preferNaturalChords; String? get originalFamilyChord; String? get originalPdfKey; int get baseTransposeOffset; double get tempoBpm; double get defaultTempoBpm; int? get midiInstrument; String get soundFont; bool get midiPreloadEnabled; int get midiPreloadNeighborCount; int get midiCacheMaxCount; bool get isAudioPlaying; bool get pdfTwoPageMode; bool get pdfVerticalScrolling; String get lyricsTextAlign; String get lyricsVerticalAlign; int get chordFontSizePercent; int get chordFillOpacityPercent; int get chordPaddingPercent; int get chordOffsetPercent; Map<int, List<ChordData>> get currentChords;
/// Create a copy of SongState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongStateCopyWith<SongState> get copyWith => _$SongStateCopyWithImpl<SongState>(this as SongState, _$identity);

  /// Serializes this SongState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SongState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isAudioLoading, isAudioLoading) || other.isAudioLoading == isAudioLoading)&&(identical(other.isPdfLoading, isPdfLoading) || other.isPdfLoading == isPdfLoading)&&(identical(other.currentPdfPath, currentPdfPath) || other.currentPdfPath == currentPdfPath)&&const DeepCollectionEquality().equals(other.songBook, songBook)&&(identical(other.bookCode, bookCode) || other.bookCode == bookCode)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.verseIndex, verseIndex) || other.verseIndex == verseIndex)&&(identical(other.isImageMode, isImageMode) || other.isImageMode == isImageMode)&&(identical(other.showSizer, showSizer) || other.showSizer == showSizer)&&(identical(other.defaultAudioFormat, defaultAudioFormat) || other.defaultAudioFormat == defaultAudioFormat)&&(identical(other.selectedSong, selectedSong) || other.selectedSong == selectedSong)&&const DeepCollectionEquality().equals(other.notes, notes)&&(identical(other.sortNotesBy, sortNotesBy) || other.sortNotesBy == sortNotesBy)&&const DeepCollectionEquality().equals(other.histories, histories)&&const DeepCollectionEquality().equals(other.shuffleIndex, shuffleIndex)&&const DeepCollectionEquality().equals(other.playlists, playlists)&&(identical(other.activePlaylistId, activePlaylistId) || other.activePlaylistId == activePlaylistId)&&(identical(other.playlistAutoNextMode, playlistAutoNextMode) || other.playlistAutoNextMode == playlistAutoNextMode)&&const DeepCollectionEquality().equals(other.playlistShuffleIndex, playlistShuffleIndex)&&(identical(other.showAudio, showAudio) || other.showAudio == showAudio)&&(identical(other.showChord, showChord) || other.showChord == showChord)&&(identical(other.searchTerms, searchTerms) || other.searchTerms == searchTerms)&&(identical(other.defaultFont, defaultFont) || other.defaultFont == defaultFont)&&(identical(other.defaultTextScale, defaultTextScale) || other.defaultTextScale == defaultTextScale)&&(identical(other.defaultTextHeight, defaultTextHeight) || other.defaultTextHeight == defaultTextHeight)&&const DeepCollectionEquality().equals(other.lastSync, lastSync)&&const DeepCollectionEquality().equals(other.remoteLyricsUpdateAt, remoteLyricsUpdateAt)&&(identical(other.transposeStep, transposeStep) || other.transposeStep == transposeStep)&&(identical(other.chordAccidentalMode, chordAccidentalMode) || other.chordAccidentalMode == chordAccidentalMode)&&(identical(other.preferNaturalChords, preferNaturalChords) || other.preferNaturalChords == preferNaturalChords)&&(identical(other.originalFamilyChord, originalFamilyChord) || other.originalFamilyChord == originalFamilyChord)&&(identical(other.originalPdfKey, originalPdfKey) || other.originalPdfKey == originalPdfKey)&&(identical(other.baseTransposeOffset, baseTransposeOffset) || other.baseTransposeOffset == baseTransposeOffset)&&(identical(other.tempoBpm, tempoBpm) || other.tempoBpm == tempoBpm)&&(identical(other.defaultTempoBpm, defaultTempoBpm) || other.defaultTempoBpm == defaultTempoBpm)&&(identical(other.midiInstrument, midiInstrument) || other.midiInstrument == midiInstrument)&&(identical(other.soundFont, soundFont) || other.soundFont == soundFont)&&(identical(other.midiPreloadEnabled, midiPreloadEnabled) || other.midiPreloadEnabled == midiPreloadEnabled)&&(identical(other.midiPreloadNeighborCount, midiPreloadNeighborCount) || other.midiPreloadNeighborCount == midiPreloadNeighborCount)&&(identical(other.midiCacheMaxCount, midiCacheMaxCount) || other.midiCacheMaxCount == midiCacheMaxCount)&&(identical(other.isAudioPlaying, isAudioPlaying) || other.isAudioPlaying == isAudioPlaying)&&(identical(other.pdfTwoPageMode, pdfTwoPageMode) || other.pdfTwoPageMode == pdfTwoPageMode)&&(identical(other.pdfVerticalScrolling, pdfVerticalScrolling) || other.pdfVerticalScrolling == pdfVerticalScrolling)&&(identical(other.lyricsTextAlign, lyricsTextAlign) || other.lyricsTextAlign == lyricsTextAlign)&&(identical(other.lyricsVerticalAlign, lyricsVerticalAlign) || other.lyricsVerticalAlign == lyricsVerticalAlign)&&(identical(other.chordFontSizePercent, chordFontSizePercent) || other.chordFontSizePercent == chordFontSizePercent)&&(identical(other.chordFillOpacityPercent, chordFillOpacityPercent) || other.chordFillOpacityPercent == chordFillOpacityPercent)&&(identical(other.chordPaddingPercent, chordPaddingPercent) || other.chordPaddingPercent == chordPaddingPercent)&&(identical(other.chordOffsetPercent, chordOffsetPercent) || other.chordOffsetPercent == chordOffsetPercent)&&const DeepCollectionEquality().equals(other.currentChords, currentChords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isAudioLoading,isPdfLoading,currentPdfPath,const DeepCollectionEquality().hash(songBook),bookCode,pageIndex,verseIndex,isImageMode,showSizer,defaultAudioFormat,selectedSong,const DeepCollectionEquality().hash(notes),sortNotesBy,const DeepCollectionEquality().hash(histories),const DeepCollectionEquality().hash(shuffleIndex),const DeepCollectionEquality().hash(playlists),activePlaylistId,playlistAutoNextMode,const DeepCollectionEquality().hash(playlistShuffleIndex),showAudio,showChord,searchTerms,defaultFont,defaultTextScale,defaultTextHeight,const DeepCollectionEquality().hash(lastSync),const DeepCollectionEquality().hash(remoteLyricsUpdateAt),transposeStep,chordAccidentalMode,preferNaturalChords,originalFamilyChord,originalPdfKey,baseTransposeOffset,tempoBpm,defaultTempoBpm,midiInstrument,soundFont,midiPreloadEnabled,midiPreloadNeighborCount,midiCacheMaxCount,isAudioPlaying,pdfTwoPageMode,pdfVerticalScrolling,lyricsTextAlign,lyricsVerticalAlign,chordFontSizePercent,chordFillOpacityPercent,chordPaddingPercent,chordOffsetPercent,const DeepCollectionEquality().hash(currentChords)]);

@override
String toString() {
  return 'SongState(isLoading: $isLoading, isAudioLoading: $isAudioLoading, isPdfLoading: $isPdfLoading, currentPdfPath: $currentPdfPath, songBook: $songBook, bookCode: $bookCode, pageIndex: $pageIndex, verseIndex: $verseIndex, isImageMode: $isImageMode, showSizer: $showSizer, defaultAudioFormat: $defaultAudioFormat, selectedSong: $selectedSong, notes: $notes, sortNotesBy: $sortNotesBy, histories: $histories, shuffleIndex: $shuffleIndex, playlists: $playlists, activePlaylistId: $activePlaylistId, playlistAutoNextMode: $playlistAutoNextMode, playlistShuffleIndex: $playlistShuffleIndex, showAudio: $showAudio, showChord: $showChord, searchTerms: $searchTerms, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight, lastSync: $lastSync, remoteLyricsUpdateAt: $remoteLyricsUpdateAt, transposeStep: $transposeStep, chordAccidentalMode: $chordAccidentalMode, preferNaturalChords: $preferNaturalChords, originalFamilyChord: $originalFamilyChord, originalPdfKey: $originalPdfKey, baseTransposeOffset: $baseTransposeOffset, tempoBpm: $tempoBpm, defaultTempoBpm: $defaultTempoBpm, midiInstrument: $midiInstrument, soundFont: $soundFont, midiPreloadEnabled: $midiPreloadEnabled, midiPreloadNeighborCount: $midiPreloadNeighborCount, midiCacheMaxCount: $midiCacheMaxCount, isAudioPlaying: $isAudioPlaying, pdfTwoPageMode: $pdfTwoPageMode, pdfVerticalScrolling: $pdfVerticalScrolling, lyricsTextAlign: $lyricsTextAlign, lyricsVerticalAlign: $lyricsVerticalAlign, chordFontSizePercent: $chordFontSizePercent, chordFillOpacityPercent: $chordFillOpacityPercent, chordPaddingPercent: $chordPaddingPercent, chordOffsetPercent: $chordOffsetPercent, currentChords: $currentChords)';
}


}

/// @nodoc
abstract mixin class $SongStateCopyWith<$Res>  {
  factory $SongStateCopyWith(SongState value, $Res Function(SongState) _then) = _$SongStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isAudioLoading, bool isPdfLoading, String? currentPdfPath, List<SongBook> songBook, String bookCode, int pageIndex, int verseIndex, bool isImageMode, bool showSizer, String defaultAudioFormat, Song? selectedSong, List<SongNote> notes, String sortNotesBy, List<SongHistory> histories, List<int> shuffleIndex, List<SongPlaylist> playlists, String? activePlaylistId, String playlistAutoNextMode, List<int> playlistShuffleIndex, bool showAudio, bool showChord, String searchTerms, String defaultFont, double defaultTextScale, double defaultTextHeight, Map<String, DateTime> lastSync, Map<String, DateTime> remoteLyricsUpdateAt, int transposeStep, String chordAccidentalMode, bool preferNaturalChords, String? originalFamilyChord, String? originalPdfKey, int baseTransposeOffset, double tempoBpm, double defaultTempoBpm, int? midiInstrument, String soundFont, bool midiPreloadEnabled, int midiPreloadNeighborCount, int midiCacheMaxCount, bool isAudioPlaying, bool pdfTwoPageMode, bool pdfVerticalScrolling, String lyricsTextAlign, String lyricsVerticalAlign, int chordFontSizePercent, int chordFillOpacityPercent, int chordPaddingPercent, int chordOffsetPercent, Map<int, List<ChordData>> currentChords
});


$SongCopyWith<$Res>? get selectedSong;

}
/// @nodoc
class _$SongStateCopyWithImpl<$Res>
    implements $SongStateCopyWith<$Res> {
  _$SongStateCopyWithImpl(this._self, this._then);

  final SongState _self;
  final $Res Function(SongState) _then;

/// Create a copy of SongState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isAudioLoading = null,Object? isPdfLoading = null,Object? currentPdfPath = freezed,Object? songBook = null,Object? bookCode = null,Object? pageIndex = null,Object? verseIndex = null,Object? isImageMode = null,Object? showSizer = null,Object? defaultAudioFormat = null,Object? selectedSong = freezed,Object? notes = null,Object? sortNotesBy = null,Object? histories = null,Object? shuffleIndex = null,Object? playlists = null,Object? activePlaylistId = freezed,Object? playlistAutoNextMode = null,Object? playlistShuffleIndex = null,Object? showAudio = null,Object? showChord = null,Object? searchTerms = null,Object? defaultFont = null,Object? defaultTextScale = null,Object? defaultTextHeight = null,Object? lastSync = null,Object? remoteLyricsUpdateAt = null,Object? transposeStep = null,Object? chordAccidentalMode = null,Object? preferNaturalChords = null,Object? originalFamilyChord = freezed,Object? originalPdfKey = freezed,Object? baseTransposeOffset = null,Object? tempoBpm = null,Object? defaultTempoBpm = null,Object? midiInstrument = freezed,Object? soundFont = null,Object? midiPreloadEnabled = null,Object? midiPreloadNeighborCount = null,Object? midiCacheMaxCount = null,Object? isAudioPlaying = null,Object? pdfTwoPageMode = null,Object? pdfVerticalScrolling = null,Object? lyricsTextAlign = null,Object? lyricsVerticalAlign = null,Object? chordFontSizePercent = null,Object? chordFillOpacityPercent = null,Object? chordPaddingPercent = null,Object? chordOffsetPercent = null,Object? currentChords = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isAudioLoading: null == isAudioLoading ? _self.isAudioLoading : isAudioLoading // ignore: cast_nullable_to_non_nullable
as bool,isPdfLoading: null == isPdfLoading ? _self.isPdfLoading : isPdfLoading // ignore: cast_nullable_to_non_nullable
as bool,currentPdfPath: freezed == currentPdfPath ? _self.currentPdfPath : currentPdfPath // ignore: cast_nullable_to_non_nullable
as String?,songBook: null == songBook ? _self.songBook : songBook // ignore: cast_nullable_to_non_nullable
as List<SongBook>,bookCode: null == bookCode ? _self.bookCode : bookCode // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,verseIndex: null == verseIndex ? _self.verseIndex : verseIndex // ignore: cast_nullable_to_non_nullable
as int,isImageMode: null == isImageMode ? _self.isImageMode : isImageMode // ignore: cast_nullable_to_non_nullable
as bool,showSizer: null == showSizer ? _self.showSizer : showSizer // ignore: cast_nullable_to_non_nullable
as bool,defaultAudioFormat: null == defaultAudioFormat ? _self.defaultAudioFormat : defaultAudioFormat // ignore: cast_nullable_to_non_nullable
as String,selectedSong: freezed == selectedSong ? _self.selectedSong : selectedSong // ignore: cast_nullable_to_non_nullable
as Song?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<SongNote>,sortNotesBy: null == sortNotesBy ? _self.sortNotesBy : sortNotesBy // ignore: cast_nullable_to_non_nullable
as String,histories: null == histories ? _self.histories : histories // ignore: cast_nullable_to_non_nullable
as List<SongHistory>,shuffleIndex: null == shuffleIndex ? _self.shuffleIndex : shuffleIndex // ignore: cast_nullable_to_non_nullable
as List<int>,playlists: null == playlists ? _self.playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<SongPlaylist>,activePlaylistId: freezed == activePlaylistId ? _self.activePlaylistId : activePlaylistId // ignore: cast_nullable_to_non_nullable
as String?,playlistAutoNextMode: null == playlistAutoNextMode ? _self.playlistAutoNextMode : playlistAutoNextMode // ignore: cast_nullable_to_non_nullable
as String,playlistShuffleIndex: null == playlistShuffleIndex ? _self.playlistShuffleIndex : playlistShuffleIndex // ignore: cast_nullable_to_non_nullable
as List<int>,showAudio: null == showAudio ? _self.showAudio : showAudio // ignore: cast_nullable_to_non_nullable
as bool,showChord: null == showChord ? _self.showChord : showChord // ignore: cast_nullable_to_non_nullable
as bool,searchTerms: null == searchTerms ? _self.searchTerms : searchTerms // ignore: cast_nullable_to_non_nullable
as String,defaultFont: null == defaultFont ? _self.defaultFont : defaultFont // ignore: cast_nullable_to_non_nullable
as String,defaultTextScale: null == defaultTextScale ? _self.defaultTextScale : defaultTextScale // ignore: cast_nullable_to_non_nullable
as double,defaultTextHeight: null == defaultTextHeight ? _self.defaultTextHeight : defaultTextHeight // ignore: cast_nullable_to_non_nullable
as double,lastSync: null == lastSync ? _self.lastSync : lastSync // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,remoteLyricsUpdateAt: null == remoteLyricsUpdateAt ? _self.remoteLyricsUpdateAt : remoteLyricsUpdateAt // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,transposeStep: null == transposeStep ? _self.transposeStep : transposeStep // ignore: cast_nullable_to_non_nullable
as int,chordAccidentalMode: null == chordAccidentalMode ? _self.chordAccidentalMode : chordAccidentalMode // ignore: cast_nullable_to_non_nullable
as String,preferNaturalChords: null == preferNaturalChords ? _self.preferNaturalChords : preferNaturalChords // ignore: cast_nullable_to_non_nullable
as bool,originalFamilyChord: freezed == originalFamilyChord ? _self.originalFamilyChord : originalFamilyChord // ignore: cast_nullable_to_non_nullable
as String?,originalPdfKey: freezed == originalPdfKey ? _self.originalPdfKey : originalPdfKey // ignore: cast_nullable_to_non_nullable
as String?,baseTransposeOffset: null == baseTransposeOffset ? _self.baseTransposeOffset : baseTransposeOffset // ignore: cast_nullable_to_non_nullable
as int,tempoBpm: null == tempoBpm ? _self.tempoBpm : tempoBpm // ignore: cast_nullable_to_non_nullable
as double,defaultTempoBpm: null == defaultTempoBpm ? _self.defaultTempoBpm : defaultTempoBpm // ignore: cast_nullable_to_non_nullable
as double,midiInstrument: freezed == midiInstrument ? _self.midiInstrument : midiInstrument // ignore: cast_nullable_to_non_nullable
as int?,soundFont: null == soundFont ? _self.soundFont : soundFont // ignore: cast_nullable_to_non_nullable
as String,midiPreloadEnabled: null == midiPreloadEnabled ? _self.midiPreloadEnabled : midiPreloadEnabled // ignore: cast_nullable_to_non_nullable
as bool,midiPreloadNeighborCount: null == midiPreloadNeighborCount ? _self.midiPreloadNeighborCount : midiPreloadNeighborCount // ignore: cast_nullable_to_non_nullable
as int,midiCacheMaxCount: null == midiCacheMaxCount ? _self.midiCacheMaxCount : midiCacheMaxCount // ignore: cast_nullable_to_non_nullable
as int,isAudioPlaying: null == isAudioPlaying ? _self.isAudioPlaying : isAudioPlaying // ignore: cast_nullable_to_non_nullable
as bool,pdfTwoPageMode: null == pdfTwoPageMode ? _self.pdfTwoPageMode : pdfTwoPageMode // ignore: cast_nullable_to_non_nullable
as bool,pdfVerticalScrolling: null == pdfVerticalScrolling ? _self.pdfVerticalScrolling : pdfVerticalScrolling // ignore: cast_nullable_to_non_nullable
as bool,lyricsTextAlign: null == lyricsTextAlign ? _self.lyricsTextAlign : lyricsTextAlign // ignore: cast_nullable_to_non_nullable
as String,lyricsVerticalAlign: null == lyricsVerticalAlign ? _self.lyricsVerticalAlign : lyricsVerticalAlign // ignore: cast_nullable_to_non_nullable
as String,chordFontSizePercent: null == chordFontSizePercent ? _self.chordFontSizePercent : chordFontSizePercent // ignore: cast_nullable_to_non_nullable
as int,chordFillOpacityPercent: null == chordFillOpacityPercent ? _self.chordFillOpacityPercent : chordFillOpacityPercent // ignore: cast_nullable_to_non_nullable
as int,chordPaddingPercent: null == chordPaddingPercent ? _self.chordPaddingPercent : chordPaddingPercent // ignore: cast_nullable_to_non_nullable
as int,chordOffsetPercent: null == chordOffsetPercent ? _self.chordOffsetPercent : chordOffsetPercent // ignore: cast_nullable_to_non_nullable
as int,currentChords: null == currentChords ? _self.currentChords : currentChords // ignore: cast_nullable_to_non_nullable
as Map<int, List<ChordData>>,
  ));
}
/// Create a copy of SongState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res>? get selectedSong {
    if (_self.selectedSong == null) {
    return null;
  }

  return $SongCopyWith<$Res>(_self.selectedSong!, (value) {
    return _then(_self.copyWith(selectedSong: value));
  });
}
}


/// Adds pattern-matching-related methods to [SongState].
extension SongStatePatterns on SongState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SongState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SongState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SongState value)  $default,){
final _that = this;
switch (_that) {
case _SongState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SongState value)?  $default,){
final _that = this;
switch (_that) {
case _SongState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isAudioLoading,  bool isPdfLoading,  String? currentPdfPath,  List<SongBook> songBook,  String bookCode,  int pageIndex,  int verseIndex,  bool isImageMode,  bool showSizer,  String defaultAudioFormat,  Song? selectedSong,  List<SongNote> notes,  String sortNotesBy,  List<SongHistory> histories,  List<int> shuffleIndex,  List<SongPlaylist> playlists,  String? activePlaylistId,  String playlistAutoNextMode,  List<int> playlistShuffleIndex,  bool showAudio,  bool showChord,  String searchTerms,  String defaultFont,  double defaultTextScale,  double defaultTextHeight,  Map<String, DateTime> lastSync,  Map<String, DateTime> remoteLyricsUpdateAt,  int transposeStep,  String chordAccidentalMode,  bool preferNaturalChords,  String? originalFamilyChord,  String? originalPdfKey,  int baseTransposeOffset,  double tempoBpm,  double defaultTempoBpm,  int? midiInstrument,  String soundFont,  bool midiPreloadEnabled,  int midiPreloadNeighborCount,  int midiCacheMaxCount,  bool isAudioPlaying,  bool pdfTwoPageMode,  bool pdfVerticalScrolling,  String lyricsTextAlign,  String lyricsVerticalAlign,  int chordFontSizePercent,  int chordFillOpacityPercent,  int chordPaddingPercent,  int chordOffsetPercent,  Map<int, List<ChordData>> currentChords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SongState() when $default != null:
return $default(_that.isLoading,_that.isAudioLoading,_that.isPdfLoading,_that.currentPdfPath,_that.songBook,_that.bookCode,_that.pageIndex,_that.verseIndex,_that.isImageMode,_that.showSizer,_that.defaultAudioFormat,_that.selectedSong,_that.notes,_that.sortNotesBy,_that.histories,_that.shuffleIndex,_that.playlists,_that.activePlaylistId,_that.playlistAutoNextMode,_that.playlistShuffleIndex,_that.showAudio,_that.showChord,_that.searchTerms,_that.defaultFont,_that.defaultTextScale,_that.defaultTextHeight,_that.lastSync,_that.remoteLyricsUpdateAt,_that.transposeStep,_that.chordAccidentalMode,_that.preferNaturalChords,_that.originalFamilyChord,_that.originalPdfKey,_that.baseTransposeOffset,_that.tempoBpm,_that.defaultTempoBpm,_that.midiInstrument,_that.soundFont,_that.midiPreloadEnabled,_that.midiPreloadNeighborCount,_that.midiCacheMaxCount,_that.isAudioPlaying,_that.pdfTwoPageMode,_that.pdfVerticalScrolling,_that.lyricsTextAlign,_that.lyricsVerticalAlign,_that.chordFontSizePercent,_that.chordFillOpacityPercent,_that.chordPaddingPercent,_that.chordOffsetPercent,_that.currentChords);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isAudioLoading,  bool isPdfLoading,  String? currentPdfPath,  List<SongBook> songBook,  String bookCode,  int pageIndex,  int verseIndex,  bool isImageMode,  bool showSizer,  String defaultAudioFormat,  Song? selectedSong,  List<SongNote> notes,  String sortNotesBy,  List<SongHistory> histories,  List<int> shuffleIndex,  List<SongPlaylist> playlists,  String? activePlaylistId,  String playlistAutoNextMode,  List<int> playlistShuffleIndex,  bool showAudio,  bool showChord,  String searchTerms,  String defaultFont,  double defaultTextScale,  double defaultTextHeight,  Map<String, DateTime> lastSync,  Map<String, DateTime> remoteLyricsUpdateAt,  int transposeStep,  String chordAccidentalMode,  bool preferNaturalChords,  String? originalFamilyChord,  String? originalPdfKey,  int baseTransposeOffset,  double tempoBpm,  double defaultTempoBpm,  int? midiInstrument,  String soundFont,  bool midiPreloadEnabled,  int midiPreloadNeighborCount,  int midiCacheMaxCount,  bool isAudioPlaying,  bool pdfTwoPageMode,  bool pdfVerticalScrolling,  String lyricsTextAlign,  String lyricsVerticalAlign,  int chordFontSizePercent,  int chordFillOpacityPercent,  int chordPaddingPercent,  int chordOffsetPercent,  Map<int, List<ChordData>> currentChords)  $default,) {final _that = this;
switch (_that) {
case _SongState():
return $default(_that.isLoading,_that.isAudioLoading,_that.isPdfLoading,_that.currentPdfPath,_that.songBook,_that.bookCode,_that.pageIndex,_that.verseIndex,_that.isImageMode,_that.showSizer,_that.defaultAudioFormat,_that.selectedSong,_that.notes,_that.sortNotesBy,_that.histories,_that.shuffleIndex,_that.playlists,_that.activePlaylistId,_that.playlistAutoNextMode,_that.playlistShuffleIndex,_that.showAudio,_that.showChord,_that.searchTerms,_that.defaultFont,_that.defaultTextScale,_that.defaultTextHeight,_that.lastSync,_that.remoteLyricsUpdateAt,_that.transposeStep,_that.chordAccidentalMode,_that.preferNaturalChords,_that.originalFamilyChord,_that.originalPdfKey,_that.baseTransposeOffset,_that.tempoBpm,_that.defaultTempoBpm,_that.midiInstrument,_that.soundFont,_that.midiPreloadEnabled,_that.midiPreloadNeighborCount,_that.midiCacheMaxCount,_that.isAudioPlaying,_that.pdfTwoPageMode,_that.pdfVerticalScrolling,_that.lyricsTextAlign,_that.lyricsVerticalAlign,_that.chordFontSizePercent,_that.chordFillOpacityPercent,_that.chordPaddingPercent,_that.chordOffsetPercent,_that.currentChords);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isAudioLoading,  bool isPdfLoading,  String? currentPdfPath,  List<SongBook> songBook,  String bookCode,  int pageIndex,  int verseIndex,  bool isImageMode,  bool showSizer,  String defaultAudioFormat,  Song? selectedSong,  List<SongNote> notes,  String sortNotesBy,  List<SongHistory> histories,  List<int> shuffleIndex,  List<SongPlaylist> playlists,  String? activePlaylistId,  String playlistAutoNextMode,  List<int> playlistShuffleIndex,  bool showAudio,  bool showChord,  String searchTerms,  String defaultFont,  double defaultTextScale,  double defaultTextHeight,  Map<String, DateTime> lastSync,  Map<String, DateTime> remoteLyricsUpdateAt,  int transposeStep,  String chordAccidentalMode,  bool preferNaturalChords,  String? originalFamilyChord,  String? originalPdfKey,  int baseTransposeOffset,  double tempoBpm,  double defaultTempoBpm,  int? midiInstrument,  String soundFont,  bool midiPreloadEnabled,  int midiPreloadNeighborCount,  int midiCacheMaxCount,  bool isAudioPlaying,  bool pdfTwoPageMode,  bool pdfVerticalScrolling,  String lyricsTextAlign,  String lyricsVerticalAlign,  int chordFontSizePercent,  int chordFillOpacityPercent,  int chordPaddingPercent,  int chordOffsetPercent,  Map<int, List<ChordData>> currentChords)?  $default,) {final _that = this;
switch (_that) {
case _SongState() when $default != null:
return $default(_that.isLoading,_that.isAudioLoading,_that.isPdfLoading,_that.currentPdfPath,_that.songBook,_that.bookCode,_that.pageIndex,_that.verseIndex,_that.isImageMode,_that.showSizer,_that.defaultAudioFormat,_that.selectedSong,_that.notes,_that.sortNotesBy,_that.histories,_that.shuffleIndex,_that.playlists,_that.activePlaylistId,_that.playlistAutoNextMode,_that.playlistShuffleIndex,_that.showAudio,_that.showChord,_that.searchTerms,_that.defaultFont,_that.defaultTextScale,_that.defaultTextHeight,_that.lastSync,_that.remoteLyricsUpdateAt,_that.transposeStep,_that.chordAccidentalMode,_that.preferNaturalChords,_that.originalFamilyChord,_that.originalPdfKey,_that.baseTransposeOffset,_that.tempoBpm,_that.defaultTempoBpm,_that.midiInstrument,_that.soundFont,_that.midiPreloadEnabled,_that.midiPreloadNeighborCount,_that.midiCacheMaxCount,_that.isAudioPlaying,_that.pdfTwoPageMode,_that.pdfVerticalScrolling,_that.lyricsTextAlign,_that.lyricsVerticalAlign,_that.chordFontSizePercent,_that.chordFillOpacityPercent,_that.chordPaddingPercent,_that.chordOffsetPercent,_that.currentChords);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SongState extends SongState {
  const _SongState({this.isLoading = false, this.isAudioLoading = false, this.isPdfLoading = false, this.currentPdfPath, final  List<SongBook> songBook = const [], this.bookCode = 'KR', this.pageIndex = 0, this.verseIndex = 0, this.isImageMode = false, this.showSizer = false, this.defaultAudioFormat = 'mid', this.selectedSong, final  List<SongNote> notes = const [], this.sortNotesBy = 'Newest', final  List<SongHistory> histories = const [], final  List<int> shuffleIndex = const [], final  List<SongPlaylist> playlists = const [], this.activePlaylistId, this.playlistAutoNextMode = SongPlaylistAutoNextMode.off, final  List<int> playlistShuffleIndex = const [], this.showAudio = false, this.showChord = false, this.searchTerms = '', this.defaultFont = 'Roboto', this.defaultTextScale = 1.2, this.defaultTextHeight = 1.5, final  Map<String, DateTime> lastSync = const {}, final  Map<String, DateTime> remoteLyricsUpdateAt = const {}, this.transposeStep = 0, this.chordAccidentalMode = 'sharp', this.preferNaturalChords = true, this.originalFamilyChord, this.originalPdfKey, this.baseTransposeOffset = 0, this.tempoBpm = 76.0, this.defaultTempoBpm = 76.0, this.midiInstrument, this.soundFont = 'TimGM6mb.sf2', this.midiPreloadEnabled = true, this.midiPreloadNeighborCount = 1, this.midiCacheMaxCount = 12, this.isAudioPlaying = false, this.pdfTwoPageMode = false, this.pdfVerticalScrolling = false, this.lyricsTextAlign = 'left', this.lyricsVerticalAlign = 'top', this.chordFontSizePercent = 100, this.chordFillOpacityPercent = 94, this.chordPaddingPercent = 100, this.chordOffsetPercent = 100, final  Map<int, List<ChordData>> currentChords = const {}}): _songBook = songBook,_notes = notes,_histories = histories,_shuffleIndex = shuffleIndex,_playlists = playlists,_playlistShuffleIndex = playlistShuffleIndex,_lastSync = lastSync,_remoteLyricsUpdateAt = remoteLyricsUpdateAt,_currentChords = currentChords,super._();
  factory _SongState.fromJson(Map<String, dynamic> json) => _$SongStateFromJson(json);

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isAudioLoading;
@override@JsonKey() final  bool isPdfLoading;
@override final  String? currentPdfPath;
 final  List<SongBook> _songBook;
@override@JsonKey() List<SongBook> get songBook {
  if (_songBook is EqualUnmodifiableListView) return _songBook;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_songBook);
}

@override@JsonKey() final  String bookCode;
@override@JsonKey() final  int pageIndex;
@override@JsonKey() final  int verseIndex;
@override@JsonKey() final  bool isImageMode;
@override@JsonKey() final  bool showSizer;
@override@JsonKey() final  String defaultAudioFormat;
@override final  Song? selectedSong;
 final  List<SongNote> _notes;
@override@JsonKey() List<SongNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

@override@JsonKey() final  String sortNotesBy;
 final  List<SongHistory> _histories;
@override@JsonKey() List<SongHistory> get histories {
  if (_histories is EqualUnmodifiableListView) return _histories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_histories);
}

 final  List<int> _shuffleIndex;
@override@JsonKey() List<int> get shuffleIndex {
  if (_shuffleIndex is EqualUnmodifiableListView) return _shuffleIndex;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shuffleIndex);
}

 final  List<SongPlaylist> _playlists;
@override@JsonKey() List<SongPlaylist> get playlists {
  if (_playlists is EqualUnmodifiableListView) return _playlists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playlists);
}

@override final  String? activePlaylistId;
@override@JsonKey() final  String playlistAutoNextMode;
 final  List<int> _playlistShuffleIndex;
@override@JsonKey() List<int> get playlistShuffleIndex {
  if (_playlistShuffleIndex is EqualUnmodifiableListView) return _playlistShuffleIndex;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playlistShuffleIndex);
}

@override@JsonKey() final  bool showAudio;
@override@JsonKey() final  bool showChord;
@override@JsonKey() final  String searchTerms;
@override@JsonKey() final  String defaultFont;
@override@JsonKey() final  double defaultTextScale;
@override@JsonKey() final  double defaultTextHeight;
 final  Map<String, DateTime> _lastSync;
@override@JsonKey() Map<String, DateTime> get lastSync {
  if (_lastSync is EqualUnmodifiableMapView) return _lastSync;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lastSync);
}

 final  Map<String, DateTime> _remoteLyricsUpdateAt;
@override@JsonKey() Map<String, DateTime> get remoteLyricsUpdateAt {
  if (_remoteLyricsUpdateAt is EqualUnmodifiableMapView) return _remoteLyricsUpdateAt;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_remoteLyricsUpdateAt);
}

// New gyschordweb fields
@override@JsonKey() final  int transposeStep;
@override@JsonKey() final  String chordAccidentalMode;
// Enable natural chord detection by default for automatic transpose based on family chord
@override@JsonKey() final  bool preferNaturalChords;
@override final  String? originalFamilyChord;
@override final  String? originalPdfKey;
@override@JsonKey() final  int baseTransposeOffset;
@override@JsonKey() final  double tempoBpm;
@override@JsonKey() final  double defaultTempoBpm;
@override final  int? midiInstrument;
@override@JsonKey() final  String soundFont;
@override@JsonKey() final  bool midiPreloadEnabled;
@override@JsonKey() final  int midiPreloadNeighborCount;
@override@JsonKey() final  int midiCacheMaxCount;
@override@JsonKey() final  bool isAudioPlaying;
@override@JsonKey() final  bool pdfTwoPageMode;
@override@JsonKey() final  bool pdfVerticalScrolling;
@override@JsonKey() final  String lyricsTextAlign;
@override@JsonKey() final  String lyricsVerticalAlign;
@override@JsonKey() final  int chordFontSizePercent;
@override@JsonKey() final  int chordFillOpacityPercent;
@override@JsonKey() final  int chordPaddingPercent;
@override@JsonKey() final  int chordOffsetPercent;
 final  Map<int, List<ChordData>> _currentChords;
@override@JsonKey() Map<int, List<ChordData>> get currentChords {
  if (_currentChords is EqualUnmodifiableMapView) return _currentChords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_currentChords);
}


/// Create a copy of SongState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongStateCopyWith<_SongState> get copyWith => __$SongStateCopyWithImpl<_SongState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SongState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isAudioLoading, isAudioLoading) || other.isAudioLoading == isAudioLoading)&&(identical(other.isPdfLoading, isPdfLoading) || other.isPdfLoading == isPdfLoading)&&(identical(other.currentPdfPath, currentPdfPath) || other.currentPdfPath == currentPdfPath)&&const DeepCollectionEquality().equals(other._songBook, _songBook)&&(identical(other.bookCode, bookCode) || other.bookCode == bookCode)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.verseIndex, verseIndex) || other.verseIndex == verseIndex)&&(identical(other.isImageMode, isImageMode) || other.isImageMode == isImageMode)&&(identical(other.showSizer, showSizer) || other.showSizer == showSizer)&&(identical(other.defaultAudioFormat, defaultAudioFormat) || other.defaultAudioFormat == defaultAudioFormat)&&(identical(other.selectedSong, selectedSong) || other.selectedSong == selectedSong)&&const DeepCollectionEquality().equals(other._notes, _notes)&&(identical(other.sortNotesBy, sortNotesBy) || other.sortNotesBy == sortNotesBy)&&const DeepCollectionEquality().equals(other._histories, _histories)&&const DeepCollectionEquality().equals(other._shuffleIndex, _shuffleIndex)&&const DeepCollectionEquality().equals(other._playlists, _playlists)&&(identical(other.activePlaylistId, activePlaylistId) || other.activePlaylistId == activePlaylistId)&&(identical(other.playlistAutoNextMode, playlistAutoNextMode) || other.playlistAutoNextMode == playlistAutoNextMode)&&const DeepCollectionEquality().equals(other._playlistShuffleIndex, _playlistShuffleIndex)&&(identical(other.showAudio, showAudio) || other.showAudio == showAudio)&&(identical(other.showChord, showChord) || other.showChord == showChord)&&(identical(other.searchTerms, searchTerms) || other.searchTerms == searchTerms)&&(identical(other.defaultFont, defaultFont) || other.defaultFont == defaultFont)&&(identical(other.defaultTextScale, defaultTextScale) || other.defaultTextScale == defaultTextScale)&&(identical(other.defaultTextHeight, defaultTextHeight) || other.defaultTextHeight == defaultTextHeight)&&const DeepCollectionEquality().equals(other._lastSync, _lastSync)&&const DeepCollectionEquality().equals(other._remoteLyricsUpdateAt, _remoteLyricsUpdateAt)&&(identical(other.transposeStep, transposeStep) || other.transposeStep == transposeStep)&&(identical(other.chordAccidentalMode, chordAccidentalMode) || other.chordAccidentalMode == chordAccidentalMode)&&(identical(other.preferNaturalChords, preferNaturalChords) || other.preferNaturalChords == preferNaturalChords)&&(identical(other.originalFamilyChord, originalFamilyChord) || other.originalFamilyChord == originalFamilyChord)&&(identical(other.originalPdfKey, originalPdfKey) || other.originalPdfKey == originalPdfKey)&&(identical(other.baseTransposeOffset, baseTransposeOffset) || other.baseTransposeOffset == baseTransposeOffset)&&(identical(other.tempoBpm, tempoBpm) || other.tempoBpm == tempoBpm)&&(identical(other.defaultTempoBpm, defaultTempoBpm) || other.defaultTempoBpm == defaultTempoBpm)&&(identical(other.midiInstrument, midiInstrument) || other.midiInstrument == midiInstrument)&&(identical(other.soundFont, soundFont) || other.soundFont == soundFont)&&(identical(other.midiPreloadEnabled, midiPreloadEnabled) || other.midiPreloadEnabled == midiPreloadEnabled)&&(identical(other.midiPreloadNeighborCount, midiPreloadNeighborCount) || other.midiPreloadNeighborCount == midiPreloadNeighborCount)&&(identical(other.midiCacheMaxCount, midiCacheMaxCount) || other.midiCacheMaxCount == midiCacheMaxCount)&&(identical(other.isAudioPlaying, isAudioPlaying) || other.isAudioPlaying == isAudioPlaying)&&(identical(other.pdfTwoPageMode, pdfTwoPageMode) || other.pdfTwoPageMode == pdfTwoPageMode)&&(identical(other.pdfVerticalScrolling, pdfVerticalScrolling) || other.pdfVerticalScrolling == pdfVerticalScrolling)&&(identical(other.lyricsTextAlign, lyricsTextAlign) || other.lyricsTextAlign == lyricsTextAlign)&&(identical(other.lyricsVerticalAlign, lyricsVerticalAlign) || other.lyricsVerticalAlign == lyricsVerticalAlign)&&(identical(other.chordFontSizePercent, chordFontSizePercent) || other.chordFontSizePercent == chordFontSizePercent)&&(identical(other.chordFillOpacityPercent, chordFillOpacityPercent) || other.chordFillOpacityPercent == chordFillOpacityPercent)&&(identical(other.chordPaddingPercent, chordPaddingPercent) || other.chordPaddingPercent == chordPaddingPercent)&&(identical(other.chordOffsetPercent, chordOffsetPercent) || other.chordOffsetPercent == chordOffsetPercent)&&const DeepCollectionEquality().equals(other._currentChords, _currentChords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,isLoading,isAudioLoading,isPdfLoading,currentPdfPath,const DeepCollectionEquality().hash(_songBook),bookCode,pageIndex,verseIndex,isImageMode,showSizer,defaultAudioFormat,selectedSong,const DeepCollectionEquality().hash(_notes),sortNotesBy,const DeepCollectionEquality().hash(_histories),const DeepCollectionEquality().hash(_shuffleIndex),const DeepCollectionEquality().hash(_playlists),activePlaylistId,playlistAutoNextMode,const DeepCollectionEquality().hash(_playlistShuffleIndex),showAudio,showChord,searchTerms,defaultFont,defaultTextScale,defaultTextHeight,const DeepCollectionEquality().hash(_lastSync),const DeepCollectionEquality().hash(_remoteLyricsUpdateAt),transposeStep,chordAccidentalMode,preferNaturalChords,originalFamilyChord,originalPdfKey,baseTransposeOffset,tempoBpm,defaultTempoBpm,midiInstrument,soundFont,midiPreloadEnabled,midiPreloadNeighborCount,midiCacheMaxCount,isAudioPlaying,pdfTwoPageMode,pdfVerticalScrolling,lyricsTextAlign,lyricsVerticalAlign,chordFontSizePercent,chordFillOpacityPercent,chordPaddingPercent,chordOffsetPercent,const DeepCollectionEquality().hash(_currentChords)]);

@override
String toString() {
  return 'SongState(isLoading: $isLoading, isAudioLoading: $isAudioLoading, isPdfLoading: $isPdfLoading, currentPdfPath: $currentPdfPath, songBook: $songBook, bookCode: $bookCode, pageIndex: $pageIndex, verseIndex: $verseIndex, isImageMode: $isImageMode, showSizer: $showSizer, defaultAudioFormat: $defaultAudioFormat, selectedSong: $selectedSong, notes: $notes, sortNotesBy: $sortNotesBy, histories: $histories, shuffleIndex: $shuffleIndex, playlists: $playlists, activePlaylistId: $activePlaylistId, playlistAutoNextMode: $playlistAutoNextMode, playlistShuffleIndex: $playlistShuffleIndex, showAudio: $showAudio, showChord: $showChord, searchTerms: $searchTerms, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight, lastSync: $lastSync, remoteLyricsUpdateAt: $remoteLyricsUpdateAt, transposeStep: $transposeStep, chordAccidentalMode: $chordAccidentalMode, preferNaturalChords: $preferNaturalChords, originalFamilyChord: $originalFamilyChord, originalPdfKey: $originalPdfKey, baseTransposeOffset: $baseTransposeOffset, tempoBpm: $tempoBpm, defaultTempoBpm: $defaultTempoBpm, midiInstrument: $midiInstrument, soundFont: $soundFont, midiPreloadEnabled: $midiPreloadEnabled, midiPreloadNeighborCount: $midiPreloadNeighborCount, midiCacheMaxCount: $midiCacheMaxCount, isAudioPlaying: $isAudioPlaying, pdfTwoPageMode: $pdfTwoPageMode, pdfVerticalScrolling: $pdfVerticalScrolling, lyricsTextAlign: $lyricsTextAlign, lyricsVerticalAlign: $lyricsVerticalAlign, chordFontSizePercent: $chordFontSizePercent, chordFillOpacityPercent: $chordFillOpacityPercent, chordPaddingPercent: $chordPaddingPercent, chordOffsetPercent: $chordOffsetPercent, currentChords: $currentChords)';
}


}

/// @nodoc
abstract mixin class _$SongStateCopyWith<$Res> implements $SongStateCopyWith<$Res> {
  factory _$SongStateCopyWith(_SongState value, $Res Function(_SongState) _then) = __$SongStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isAudioLoading, bool isPdfLoading, String? currentPdfPath, List<SongBook> songBook, String bookCode, int pageIndex, int verseIndex, bool isImageMode, bool showSizer, String defaultAudioFormat, Song? selectedSong, List<SongNote> notes, String sortNotesBy, List<SongHistory> histories, List<int> shuffleIndex, List<SongPlaylist> playlists, String? activePlaylistId, String playlistAutoNextMode, List<int> playlistShuffleIndex, bool showAudio, bool showChord, String searchTerms, String defaultFont, double defaultTextScale, double defaultTextHeight, Map<String, DateTime> lastSync, Map<String, DateTime> remoteLyricsUpdateAt, int transposeStep, String chordAccidentalMode, bool preferNaturalChords, String? originalFamilyChord, String? originalPdfKey, int baseTransposeOffset, double tempoBpm, double defaultTempoBpm, int? midiInstrument, String soundFont, bool midiPreloadEnabled, int midiPreloadNeighborCount, int midiCacheMaxCount, bool isAudioPlaying, bool pdfTwoPageMode, bool pdfVerticalScrolling, String lyricsTextAlign, String lyricsVerticalAlign, int chordFontSizePercent, int chordFillOpacityPercent, int chordPaddingPercent, int chordOffsetPercent, Map<int, List<ChordData>> currentChords
});


@override $SongCopyWith<$Res>? get selectedSong;

}
/// @nodoc
class __$SongStateCopyWithImpl<$Res>
    implements _$SongStateCopyWith<$Res> {
  __$SongStateCopyWithImpl(this._self, this._then);

  final _SongState _self;
  final $Res Function(_SongState) _then;

/// Create a copy of SongState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isAudioLoading = null,Object? isPdfLoading = null,Object? currentPdfPath = freezed,Object? songBook = null,Object? bookCode = null,Object? pageIndex = null,Object? verseIndex = null,Object? isImageMode = null,Object? showSizer = null,Object? defaultAudioFormat = null,Object? selectedSong = freezed,Object? notes = null,Object? sortNotesBy = null,Object? histories = null,Object? shuffleIndex = null,Object? playlists = null,Object? activePlaylistId = freezed,Object? playlistAutoNextMode = null,Object? playlistShuffleIndex = null,Object? showAudio = null,Object? showChord = null,Object? searchTerms = null,Object? defaultFont = null,Object? defaultTextScale = null,Object? defaultTextHeight = null,Object? lastSync = null,Object? remoteLyricsUpdateAt = null,Object? transposeStep = null,Object? chordAccidentalMode = null,Object? preferNaturalChords = null,Object? originalFamilyChord = freezed,Object? originalPdfKey = freezed,Object? baseTransposeOffset = null,Object? tempoBpm = null,Object? defaultTempoBpm = null,Object? midiInstrument = freezed,Object? soundFont = null,Object? midiPreloadEnabled = null,Object? midiPreloadNeighborCount = null,Object? midiCacheMaxCount = null,Object? isAudioPlaying = null,Object? pdfTwoPageMode = null,Object? pdfVerticalScrolling = null,Object? lyricsTextAlign = null,Object? lyricsVerticalAlign = null,Object? chordFontSizePercent = null,Object? chordFillOpacityPercent = null,Object? chordPaddingPercent = null,Object? chordOffsetPercent = null,Object? currentChords = null,}) {
  return _then(_SongState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isAudioLoading: null == isAudioLoading ? _self.isAudioLoading : isAudioLoading // ignore: cast_nullable_to_non_nullable
as bool,isPdfLoading: null == isPdfLoading ? _self.isPdfLoading : isPdfLoading // ignore: cast_nullable_to_non_nullable
as bool,currentPdfPath: freezed == currentPdfPath ? _self.currentPdfPath : currentPdfPath // ignore: cast_nullable_to_non_nullable
as String?,songBook: null == songBook ? _self._songBook : songBook // ignore: cast_nullable_to_non_nullable
as List<SongBook>,bookCode: null == bookCode ? _self.bookCode : bookCode // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,verseIndex: null == verseIndex ? _self.verseIndex : verseIndex // ignore: cast_nullable_to_non_nullable
as int,isImageMode: null == isImageMode ? _self.isImageMode : isImageMode // ignore: cast_nullable_to_non_nullable
as bool,showSizer: null == showSizer ? _self.showSizer : showSizer // ignore: cast_nullable_to_non_nullable
as bool,defaultAudioFormat: null == defaultAudioFormat ? _self.defaultAudioFormat : defaultAudioFormat // ignore: cast_nullable_to_non_nullable
as String,selectedSong: freezed == selectedSong ? _self.selectedSong : selectedSong // ignore: cast_nullable_to_non_nullable
as Song?,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<SongNote>,sortNotesBy: null == sortNotesBy ? _self.sortNotesBy : sortNotesBy // ignore: cast_nullable_to_non_nullable
as String,histories: null == histories ? _self._histories : histories // ignore: cast_nullable_to_non_nullable
as List<SongHistory>,shuffleIndex: null == shuffleIndex ? _self._shuffleIndex : shuffleIndex // ignore: cast_nullable_to_non_nullable
as List<int>,playlists: null == playlists ? _self._playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<SongPlaylist>,activePlaylistId: freezed == activePlaylistId ? _self.activePlaylistId : activePlaylistId // ignore: cast_nullable_to_non_nullable
as String?,playlistAutoNextMode: null == playlistAutoNextMode ? _self.playlistAutoNextMode : playlistAutoNextMode // ignore: cast_nullable_to_non_nullable
as String,playlistShuffleIndex: null == playlistShuffleIndex ? _self._playlistShuffleIndex : playlistShuffleIndex // ignore: cast_nullable_to_non_nullable
as List<int>,showAudio: null == showAudio ? _self.showAudio : showAudio // ignore: cast_nullable_to_non_nullable
as bool,showChord: null == showChord ? _self.showChord : showChord // ignore: cast_nullable_to_non_nullable
as bool,searchTerms: null == searchTerms ? _self.searchTerms : searchTerms // ignore: cast_nullable_to_non_nullable
as String,defaultFont: null == defaultFont ? _self.defaultFont : defaultFont // ignore: cast_nullable_to_non_nullable
as String,defaultTextScale: null == defaultTextScale ? _self.defaultTextScale : defaultTextScale // ignore: cast_nullable_to_non_nullable
as double,defaultTextHeight: null == defaultTextHeight ? _self.defaultTextHeight : defaultTextHeight // ignore: cast_nullable_to_non_nullable
as double,lastSync: null == lastSync ? _self._lastSync : lastSync // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,remoteLyricsUpdateAt: null == remoteLyricsUpdateAt ? _self._remoteLyricsUpdateAt : remoteLyricsUpdateAt // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,transposeStep: null == transposeStep ? _self.transposeStep : transposeStep // ignore: cast_nullable_to_non_nullable
as int,chordAccidentalMode: null == chordAccidentalMode ? _self.chordAccidentalMode : chordAccidentalMode // ignore: cast_nullable_to_non_nullable
as String,preferNaturalChords: null == preferNaturalChords ? _self.preferNaturalChords : preferNaturalChords // ignore: cast_nullable_to_non_nullable
as bool,originalFamilyChord: freezed == originalFamilyChord ? _self.originalFamilyChord : originalFamilyChord // ignore: cast_nullable_to_non_nullable
as String?,originalPdfKey: freezed == originalPdfKey ? _self.originalPdfKey : originalPdfKey // ignore: cast_nullable_to_non_nullable
as String?,baseTransposeOffset: null == baseTransposeOffset ? _self.baseTransposeOffset : baseTransposeOffset // ignore: cast_nullable_to_non_nullable
as int,tempoBpm: null == tempoBpm ? _self.tempoBpm : tempoBpm // ignore: cast_nullable_to_non_nullable
as double,defaultTempoBpm: null == defaultTempoBpm ? _self.defaultTempoBpm : defaultTempoBpm // ignore: cast_nullable_to_non_nullable
as double,midiInstrument: freezed == midiInstrument ? _self.midiInstrument : midiInstrument // ignore: cast_nullable_to_non_nullable
as int?,soundFont: null == soundFont ? _self.soundFont : soundFont // ignore: cast_nullable_to_non_nullable
as String,midiPreloadEnabled: null == midiPreloadEnabled ? _self.midiPreloadEnabled : midiPreloadEnabled // ignore: cast_nullable_to_non_nullable
as bool,midiPreloadNeighborCount: null == midiPreloadNeighborCount ? _self.midiPreloadNeighborCount : midiPreloadNeighborCount // ignore: cast_nullable_to_non_nullable
as int,midiCacheMaxCount: null == midiCacheMaxCount ? _self.midiCacheMaxCount : midiCacheMaxCount // ignore: cast_nullable_to_non_nullable
as int,isAudioPlaying: null == isAudioPlaying ? _self.isAudioPlaying : isAudioPlaying // ignore: cast_nullable_to_non_nullable
as bool,pdfTwoPageMode: null == pdfTwoPageMode ? _self.pdfTwoPageMode : pdfTwoPageMode // ignore: cast_nullable_to_non_nullable
as bool,pdfVerticalScrolling: null == pdfVerticalScrolling ? _self.pdfVerticalScrolling : pdfVerticalScrolling // ignore: cast_nullable_to_non_nullable
as bool,lyricsTextAlign: null == lyricsTextAlign ? _self.lyricsTextAlign : lyricsTextAlign // ignore: cast_nullable_to_non_nullable
as String,lyricsVerticalAlign: null == lyricsVerticalAlign ? _self.lyricsVerticalAlign : lyricsVerticalAlign // ignore: cast_nullable_to_non_nullable
as String,chordFontSizePercent: null == chordFontSizePercent ? _self.chordFontSizePercent : chordFontSizePercent // ignore: cast_nullable_to_non_nullable
as int,chordFillOpacityPercent: null == chordFillOpacityPercent ? _self.chordFillOpacityPercent : chordFillOpacityPercent // ignore: cast_nullable_to_non_nullable
as int,chordPaddingPercent: null == chordPaddingPercent ? _self.chordPaddingPercent : chordPaddingPercent // ignore: cast_nullable_to_non_nullable
as int,chordOffsetPercent: null == chordOffsetPercent ? _self.chordOffsetPercent : chordOffsetPercent // ignore: cast_nullable_to_non_nullable
as int,currentChords: null == currentChords ? _self._currentChords : currentChords // ignore: cast_nullable_to_non_nullable
as Map<int, List<ChordData>>,
  ));
}

/// Create a copy of SongState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res>? get selectedSong {
    if (_self.selectedSong == null) {
    return null;
  }

  return $SongCopyWith<$Res>(_self.selectedSong!, (value) {
    return _then(_self.copyWith(selectedSong: value));
  });
}
}

// dart format on

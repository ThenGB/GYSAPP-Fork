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
  bool get isLoading;
  bool get isAudioLoading;
  List<SongBook> get songBook;
  List<SongBook> get favoriteSongBook;
  String get bookCode;
  int get pageIndex;
  int get verseIndex;
  dynamic get isImageMode;
  bool get showSizer;
  String get defaultAudioFormat;
  Song? get selectedSong;
  List<SongNote> get notes;
  String get sortNotesBy;
  List<SongHistory> get histories;
  bool get playOnlyFavorite;
  bool get shuffleMode;
  List<int> get shuffleIndex;
  bool get showAudio;
  bool get showChord;
  String get searchTerms;
  String get defaultFont;
  double get defaultTextScale;
  double get defaultTextHeight;
  Map<String, DateTime> get lastSync;
  Map<String, DateTime> get remoteLyricsUpdateAt; // New gyschordweb fields
  int get transposeStep;
  String get chordAccidentalMode;
  bool get preferNaturalChords;
  String? get originalFamilyChord;
  String? get originalPdfKey;
  int get baseTransposeOffset;
  double get tempoBpm;
  double get defaultTempoBpm;
  int? get midiInstrument;
  String get soundFont;
  bool get isAudioPlaying;

  /// Create a copy of SongState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SongStateCopyWith<SongState> get copyWith =>
      _$SongStateCopyWithImpl<SongState>(this as SongState, _$identity);

  /// Serializes this SongState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SongState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isAudioLoading, isAudioLoading) ||
                other.isAudioLoading == isAudioLoading) &&
            const DeepCollectionEquality().equals(other.songBook, songBook) &&
            const DeepCollectionEquality()
                .equals(other.favoriteSongBook, favoriteSongBook) &&
            (identical(other.bookCode, bookCode) ||
                other.bookCode == bookCode) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex) &&
            (identical(other.verseIndex, verseIndex) ||
                other.verseIndex == verseIndex) &&
            const DeepCollectionEquality()
                .equals(other.isImageMode, isImageMode) &&
            (identical(other.showSizer, showSizer) ||
                other.showSizer == showSizer) &&
            (identical(other.defaultAudioFormat, defaultAudioFormat) ||
                other.defaultAudioFormat == defaultAudioFormat) &&
            (identical(other.selectedSong, selectedSong) ||
                other.selectedSong == selectedSong) &&
            const DeepCollectionEquality().equals(other.notes, notes) &&
            (identical(other.sortNotesBy, sortNotesBy) ||
                other.sortNotesBy == sortNotesBy) &&
            const DeepCollectionEquality().equals(other.histories, histories) &&
            (identical(other.playOnlyFavorite, playOnlyFavorite) ||
                other.playOnlyFavorite == playOnlyFavorite) &&
            (identical(other.shuffleMode, shuffleMode) ||
                other.shuffleMode == shuffleMode) &&
            const DeepCollectionEquality()
                .equals(other.shuffleIndex, shuffleIndex) &&
            (identical(other.showAudio, showAudio) ||
                other.showAudio == showAudio) &&
            (identical(other.showChord, showChord) ||
                other.showChord == showChord) &&
            (identical(other.searchTerms, searchTerms) ||
                other.searchTerms == searchTerms) &&
            (identical(other.defaultFont, defaultFont) ||
                other.defaultFont == defaultFont) &&
            (identical(other.defaultTextScale, defaultTextScale) ||
                other.defaultTextScale == defaultTextScale) &&
            (identical(other.defaultTextHeight, defaultTextHeight) ||
                other.defaultTextHeight == defaultTextHeight) &&
            const DeepCollectionEquality().equals(other.lastSync, lastSync) &&
            const DeepCollectionEquality()
                .equals(other.remoteLyricsUpdateAt, remoteLyricsUpdateAt) &&
            (identical(other.transposeStep, transposeStep) ||
                other.transposeStep == transposeStep) &&
            (identical(other.chordAccidentalMode, chordAccidentalMode) ||
                other.chordAccidentalMode == chordAccidentalMode) &&
            (identical(other.preferNaturalChords, preferNaturalChords) ||
                other.preferNaturalChords == preferNaturalChords) &&
            (identical(other.originalFamilyChord, originalFamilyChord) ||
                other.originalFamilyChord == originalFamilyChord) &&
            (identical(other.originalPdfKey, originalPdfKey) ||
                other.originalPdfKey == originalPdfKey) &&
            (identical(other.baseTransposeOffset, baseTransposeOffset) ||
                other.baseTransposeOffset == baseTransposeOffset) &&
            (identical(other.tempoBpm, tempoBpm) ||
                other.tempoBpm == tempoBpm) &&
            (identical(other.defaultTempoBpm, defaultTempoBpm) ||
                other.defaultTempoBpm == defaultTempoBpm) &&
            (identical(other.midiInstrument, midiInstrument) ||
                other.midiInstrument == midiInstrument) &&
            (identical(other.soundFont, soundFont) ||
                other.soundFont == soundFont) &&
            (identical(other.isAudioPlaying, isAudioPlaying) ||
                other.isAudioPlaying == isAudioPlaying));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isLoading,
        isAudioLoading,
        const DeepCollectionEquality().hash(songBook),
        const DeepCollectionEquality().hash(favoriteSongBook),
        bookCode,
        pageIndex,
        verseIndex,
        const DeepCollectionEquality().hash(isImageMode),
        showSizer,
        defaultAudioFormat,
        selectedSong,
        const DeepCollectionEquality().hash(notes),
        sortNotesBy,
        const DeepCollectionEquality().hash(histories),
        playOnlyFavorite,
        shuffleMode,
        const DeepCollectionEquality().hash(shuffleIndex),
        showAudio,
        showChord,
        searchTerms,
        defaultFont,
        defaultTextScale,
        defaultTextHeight,
        const DeepCollectionEquality().hash(lastSync),
        const DeepCollectionEquality().hash(remoteLyricsUpdateAt),
        transposeStep,
        chordAccidentalMode,
        preferNaturalChords,
        originalFamilyChord,
        originalPdfKey,
        baseTransposeOffset,
        tempoBpm,
        defaultTempoBpm,
        midiInstrument,
        soundFont,
        isAudioPlaying
      ]);

  @override
  String toString() {
    return 'SongState(isLoading: $isLoading, isAudioLoading: $isAudioLoading, songBook: $songBook, favoriteSongBook: $favoriteSongBook, bookCode: $bookCode, pageIndex: $pageIndex, verseIndex: $verseIndex, isImageMode: $isImageMode, showSizer: $showSizer, defaultAudioFormat: $defaultAudioFormat, selectedSong: $selectedSong, notes: $notes, sortNotesBy: $sortNotesBy, histories: $histories, playOnlyFavorite: $playOnlyFavorite, shuffleMode: $shuffleMode, shuffleIndex: $shuffleIndex, showAudio: $showAudio, showChord: $showChord, searchTerms: $searchTerms, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight, lastSync: $lastSync, remoteLyricsUpdateAt: $remoteLyricsUpdateAt, transposeStep: $transposeStep, chordAccidentalMode: $chordAccidentalMode, preferNaturalChords: $preferNaturalChords, originalFamilyChord: $originalFamilyChord, originalPdfKey: $originalPdfKey, baseTransposeOffset: $baseTransposeOffset, tempoBpm: $tempoBpm, defaultTempoBpm: $defaultTempoBpm, midiInstrument: $midiInstrument, soundFont: $soundFont, isAudioPlaying: $isAudioPlaying)';
  }
}

/// @nodoc
abstract mixin class $SongStateCopyWith<$Res> {
  factory $SongStateCopyWith(SongState value, $Res Function(SongState) _then) =
      _$SongStateCopyWithImpl;
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
      bool showChord,
      String searchTerms,
      String defaultFont,
      double defaultTextScale,
      double defaultTextHeight,
      Map<String, DateTime> lastSync,
      Map<String, DateTime> remoteLyricsUpdateAt,
      int transposeStep,
      String chordAccidentalMode,
      bool preferNaturalChords,
      String? originalFamilyChord,
      String? originalPdfKey,
      int baseTransposeOffset,
      double tempoBpm,
      double defaultTempoBpm,
      int? midiInstrument,
      String soundFont,
      bool isAudioPlaying});

  $SongCopyWith<$Res>? get selectedSong;
}

/// @nodoc
class _$SongStateCopyWithImpl<$Res> implements $SongStateCopyWith<$Res> {
  _$SongStateCopyWithImpl(this._self, this._then);

  final SongState _self;
  final $Res Function(SongState) _then;

  /// Create a copy of SongState
  /// with the given fields replaced by the non-null parameter values.
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
    Object? showChord = null,
    Object? searchTerms = null,
    Object? defaultFont = null,
    Object? defaultTextScale = null,
    Object? defaultTextHeight = null,
    Object? lastSync = null,
    Object? remoteLyricsUpdateAt = null,
    Object? transposeStep = null,
    Object? chordAccidentalMode = null,
    Object? preferNaturalChords = null,
    Object? originalFamilyChord = freezed,
    Object? originalPdfKey = freezed,
    Object? baseTransposeOffset = null,
    Object? tempoBpm = null,
    Object? defaultTempoBpm = null,
    Object? midiInstrument = freezed,
    Object? soundFont = null,
    Object? isAudioPlaying = null,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isAudioLoading: null == isAudioLoading
          ? _self.isAudioLoading
          : isAudioLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      songBook: null == songBook
          ? _self.songBook
          : songBook // ignore: cast_nullable_to_non_nullable
              as List<SongBook>,
      favoriteSongBook: null == favoriteSongBook
          ? _self.favoriteSongBook
          : favoriteSongBook // ignore: cast_nullable_to_non_nullable
              as List<SongBook>,
      bookCode: null == bookCode
          ? _self.bookCode
          : bookCode // ignore: cast_nullable_to_non_nullable
              as String,
      pageIndex: null == pageIndex
          ? _self.pageIndex
          : pageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      verseIndex: null == verseIndex
          ? _self.verseIndex
          : verseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isImageMode: freezed == isImageMode
          ? _self.isImageMode
          : isImageMode // ignore: cast_nullable_to_non_nullable
              as dynamic,
      showSizer: null == showSizer
          ? _self.showSizer
          : showSizer // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultAudioFormat: null == defaultAudioFormat
          ? _self.defaultAudioFormat
          : defaultAudioFormat // ignore: cast_nullable_to_non_nullable
              as String,
      selectedSong: freezed == selectedSong
          ? _self.selectedSong
          : selectedSong // ignore: cast_nullable_to_non_nullable
              as Song?,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<SongNote>,
      sortNotesBy: null == sortNotesBy
          ? _self.sortNotesBy
          : sortNotesBy // ignore: cast_nullable_to_non_nullable
              as String,
      histories: null == histories
          ? _self.histories
          : histories // ignore: cast_nullable_to_non_nullable
              as List<SongHistory>,
      playOnlyFavorite: null == playOnlyFavorite
          ? _self.playOnlyFavorite
          : playOnlyFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      shuffleMode: null == shuffleMode
          ? _self.shuffleMode
          : shuffleMode // ignore: cast_nullable_to_non_nullable
              as bool,
      shuffleIndex: null == shuffleIndex
          ? _self.shuffleIndex
          : shuffleIndex // ignore: cast_nullable_to_non_nullable
              as List<int>,
      showAudio: null == showAudio
          ? _self.showAudio
          : showAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      showChord: null == showChord
          ? _self.showChord
          : showChord // ignore: cast_nullable_to_non_nullable
              as bool,
      searchTerms: null == searchTerms
          ? _self.searchTerms
          : searchTerms // ignore: cast_nullable_to_non_nullable
              as String,
      defaultFont: null == defaultFont
          ? _self.defaultFont
          : defaultFont // ignore: cast_nullable_to_non_nullable
              as String,
      defaultTextScale: null == defaultTextScale
          ? _self.defaultTextScale
          : defaultTextScale // ignore: cast_nullable_to_non_nullable
              as double,
      defaultTextHeight: null == defaultTextHeight
          ? _self.defaultTextHeight
          : defaultTextHeight // ignore: cast_nullable_to_non_nullable
              as double,
      lastSync: null == lastSync
          ? _self.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      remoteLyricsUpdateAt: null == remoteLyricsUpdateAt
          ? _self.remoteLyricsUpdateAt
          : remoteLyricsUpdateAt // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      transposeStep: null == transposeStep
          ? _self.transposeStep
          : transposeStep // ignore: cast_nullable_to_non_nullable
              as int,
      chordAccidentalMode: null == chordAccidentalMode
          ? _self.chordAccidentalMode
          : chordAccidentalMode // ignore: cast_nullable_to_non_nullable
              as String,
      preferNaturalChords: null == preferNaturalChords
          ? _self.preferNaturalChords
          : preferNaturalChords // ignore: cast_nullable_to_non_nullable
              as bool,
      originalFamilyChord: freezed == originalFamilyChord
          ? _self.originalFamilyChord
          : originalFamilyChord // ignore: cast_nullable_to_non_nullable
              as String?,
      originalPdfKey: freezed == originalPdfKey
          ? _self.originalPdfKey
          : originalPdfKey // ignore: cast_nullable_to_non_nullable
              as String?,
      baseTransposeOffset: null == baseTransposeOffset
          ? _self.baseTransposeOffset
          : baseTransposeOffset // ignore: cast_nullable_to_non_nullable
              as int,
      tempoBpm: null == tempoBpm
          ? _self.tempoBpm
          : tempoBpm // ignore: cast_nullable_to_non_nullable
              as double,
      defaultTempoBpm: null == defaultTempoBpm
          ? _self.defaultTempoBpm
          : defaultTempoBpm // ignore: cast_nullable_to_non_nullable
              as double,
      midiInstrument: freezed == midiInstrument
          ? _self.midiInstrument
          : midiInstrument // ignore: cast_nullable_to_non_nullable
              as int?,
      soundFont: null == soundFont
          ? _self.soundFont
          : soundFont // ignore: cast_nullable_to_non_nullable
              as String,
      isAudioPlaying: null == isAudioPlaying
          ? _self.isAudioPlaying
          : isAudioPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SongState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SongState() when $default != null:
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
    TResult Function(_SongState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongState():
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
    TResult? Function(_SongState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongState() when $default != null:
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
            bool isLoading,
            bool isAudioLoading,
            List<SongBook> songBook,
            List<SongBook> favoriteSongBook,
            String bookCode,
            int pageIndex,
            int verseIndex,
            dynamic isImageMode,
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
            bool showChord,
            String searchTerms,
            String defaultFont,
            double defaultTextScale,
            double defaultTextHeight,
            Map<String, DateTime> lastSync,
            Map<String, DateTime> remoteLyricsUpdateAt,
            int transposeStep,
            String chordAccidentalMode,
            bool preferNaturalChords,
            String? originalFamilyChord,
            String? originalPdfKey,
            int baseTransposeOffset,
            double tempoBpm,
            double defaultTempoBpm,
            int? midiInstrument,
            String soundFont,
            bool isAudioPlaying)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SongState() when $default != null:
        return $default(
            _that.isLoading,
            _that.isAudioLoading,
            _that.songBook,
            _that.favoriteSongBook,
            _that.bookCode,
            _that.pageIndex,
            _that.verseIndex,
            _that.isImageMode,
            _that.showSizer,
            _that.defaultAudioFormat,
            _that.selectedSong,
            _that.notes,
            _that.sortNotesBy,
            _that.histories,
            _that.playOnlyFavorite,
            _that.shuffleMode,
            _that.shuffleIndex,
            _that.showAudio,
            _that.showChord,
            _that.searchTerms,
            _that.defaultFont,
            _that.defaultTextScale,
            _that.defaultTextHeight,
            _that.lastSync,
            _that.remoteLyricsUpdateAt,
            _that.transposeStep,
            _that.chordAccidentalMode,
            _that.preferNaturalChords,
            _that.originalFamilyChord,
            _that.originalPdfKey,
            _that.baseTransposeOffset,
            _that.tempoBpm,
            _that.defaultTempoBpm,
            _that.midiInstrument,
            _that.soundFont,
            _that.isAudioPlaying);
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
            bool isLoading,
            bool isAudioLoading,
            List<SongBook> songBook,
            List<SongBook> favoriteSongBook,
            String bookCode,
            int pageIndex,
            int verseIndex,
            dynamic isImageMode,
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
            bool showChord,
            String searchTerms,
            String defaultFont,
            double defaultTextScale,
            double defaultTextHeight,
            Map<String, DateTime> lastSync,
            Map<String, DateTime> remoteLyricsUpdateAt,
            int transposeStep,
            String chordAccidentalMode,
            bool preferNaturalChords,
            String? originalFamilyChord,
            String? originalPdfKey,
            int baseTransposeOffset,
            double tempoBpm,
            double defaultTempoBpm,
            int? midiInstrument,
            String soundFont,
            bool isAudioPlaying)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongState():
        return $default(
            _that.isLoading,
            _that.isAudioLoading,
            _that.songBook,
            _that.favoriteSongBook,
            _that.bookCode,
            _that.pageIndex,
            _that.verseIndex,
            _that.isImageMode,
            _that.showSizer,
            _that.defaultAudioFormat,
            _that.selectedSong,
            _that.notes,
            _that.sortNotesBy,
            _that.histories,
            _that.playOnlyFavorite,
            _that.shuffleMode,
            _that.shuffleIndex,
            _that.showAudio,
            _that.showChord,
            _that.searchTerms,
            _that.defaultFont,
            _that.defaultTextScale,
            _that.defaultTextHeight,
            _that.lastSync,
            _that.remoteLyricsUpdateAt,
            _that.transposeStep,
            _that.chordAccidentalMode,
            _that.preferNaturalChords,
            _that.originalFamilyChord,
            _that.originalPdfKey,
            _that.baseTransposeOffset,
            _that.tempoBpm,
            _that.defaultTempoBpm,
            _that.midiInstrument,
            _that.soundFont,
            _that.isAudioPlaying);
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
            bool isLoading,
            bool isAudioLoading,
            List<SongBook> songBook,
            List<SongBook> favoriteSongBook,
            String bookCode,
            int pageIndex,
            int verseIndex,
            dynamic isImageMode,
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
            bool showChord,
            String searchTerms,
            String defaultFont,
            double defaultTextScale,
            double defaultTextHeight,
            Map<String, DateTime> lastSync,
            Map<String, DateTime> remoteLyricsUpdateAt,
            int transposeStep,
            String chordAccidentalMode,
            bool preferNaturalChords,
            String? originalFamilyChord,
            String? originalPdfKey,
            int baseTransposeOffset,
            double tempoBpm,
            double defaultTempoBpm,
            int? midiInstrument,
            String soundFont,
            bool isAudioPlaying)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongState() when $default != null:
        return $default(
            _that.isLoading,
            _that.isAudioLoading,
            _that.songBook,
            _that.favoriteSongBook,
            _that.bookCode,
            _that.pageIndex,
            _that.verseIndex,
            _that.isImageMode,
            _that.showSizer,
            _that.defaultAudioFormat,
            _that.selectedSong,
            _that.notes,
            _that.sortNotesBy,
            _that.histories,
            _that.playOnlyFavorite,
            _that.shuffleMode,
            _that.shuffleIndex,
            _that.showAudio,
            _that.showChord,
            _that.searchTerms,
            _that.defaultFont,
            _that.defaultTextScale,
            _that.defaultTextHeight,
            _that.lastSync,
            _that.remoteLyricsUpdateAt,
            _that.transposeStep,
            _that.chordAccidentalMode,
            _that.preferNaturalChords,
            _that.originalFamilyChord,
            _that.originalPdfKey,
            _that.baseTransposeOffset,
            _that.tempoBpm,
            _that.defaultTempoBpm,
            _that.midiInstrument,
            _that.soundFont,
            _that.isAudioPlaying);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SongState extends SongState {
  const _SongState(
      {this.isLoading = false,
      this.isAudioLoading = false,
      final List<SongBook> songBook = const [],
      final List<SongBook> favoriteSongBook = const [],
      this.bookCode = 'KR',
      this.pageIndex = 0,
      this.verseIndex = 0,
      this.isImageMode = false,
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
      this.showChord = false,
      this.searchTerms = '',
      this.defaultFont = 'Roboto',
      this.defaultTextScale = 1.2,
      this.defaultTextHeight = 1.5,
      final Map<String, DateTime> lastSync = const {},
      final Map<String, DateTime> remoteLyricsUpdateAt = const {},
      this.transposeStep = 0,
      this.chordAccidentalMode = 'sharp',
      this.preferNaturalChords = false,
      this.originalFamilyChord,
      this.originalPdfKey,
      this.baseTransposeOffset = 0,
      this.tempoBpm = 76.0,
      this.defaultTempoBpm = 76.0,
      this.midiInstrument,
      this.soundFont = 'GeneralUser-GS.sf2',
      this.isAudioPlaying = false})
      : _songBook = songBook,
        _favoriteSongBook = favoriteSongBook,
        _notes = notes,
        _histories = histories,
        _shuffleIndex = shuffleIndex,
        _lastSync = lastSync,
        _remoteLyricsUpdateAt = remoteLyricsUpdateAt,
        super._();
  factory _SongState.fromJson(Map<String, dynamic> json) =>
      _$SongStateFromJson(json);

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
  final bool showChord;
  @override
  @JsonKey()
  final String searchTerms;
  @override
  @JsonKey()
  final String defaultFont;
  @override
  @JsonKey()
  final double defaultTextScale;
  @override
  @JsonKey()
  final double defaultTextHeight;
  final Map<String, DateTime> _lastSync;
  @override
  @JsonKey()
  Map<String, DateTime> get lastSync {
    if (_lastSync is EqualUnmodifiableMapView) return _lastSync;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lastSync);
  }

  final Map<String, DateTime> _remoteLyricsUpdateAt;
  @override
  @JsonKey()
  Map<String, DateTime> get remoteLyricsUpdateAt {
    if (_remoteLyricsUpdateAt is EqualUnmodifiableMapView)
      return _remoteLyricsUpdateAt;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_remoteLyricsUpdateAt);
  }

// New gyschordweb fields
  @override
  @JsonKey()
  final int transposeStep;
  @override
  @JsonKey()
  final String chordAccidentalMode;
  @override
  @JsonKey()
  final bool preferNaturalChords;
  @override
  final String? originalFamilyChord;
  @override
  final String? originalPdfKey;
  @override
  @JsonKey()
  final int baseTransposeOffset;
  @override
  @JsonKey()
  final double tempoBpm;
  @override
  @JsonKey()
  final double defaultTempoBpm;
  @override
  final int? midiInstrument;
  @override
  @JsonKey()
  final String soundFont;
  @override
  @JsonKey()
  final bool isAudioPlaying;

  /// Create a copy of SongState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SongStateCopyWith<_SongState> get copyWith =>
      __$SongStateCopyWithImpl<_SongState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SongStateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SongState &&
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
            (identical(other.showChord, showChord) ||
                other.showChord == showChord) &&
            (identical(other.searchTerms, searchTerms) ||
                other.searchTerms == searchTerms) &&
            (identical(other.defaultFont, defaultFont) ||
                other.defaultFont == defaultFont) &&
            (identical(other.defaultTextScale, defaultTextScale) ||
                other.defaultTextScale == defaultTextScale) &&
            (identical(other.defaultTextHeight, defaultTextHeight) ||
                other.defaultTextHeight == defaultTextHeight) &&
            const DeepCollectionEquality().equals(other._lastSync, _lastSync) &&
            const DeepCollectionEquality()
                .equals(other._remoteLyricsUpdateAt, _remoteLyricsUpdateAt) &&
            (identical(other.transposeStep, transposeStep) ||
                other.transposeStep == transposeStep) &&
            (identical(other.chordAccidentalMode, chordAccidentalMode) ||
                other.chordAccidentalMode == chordAccidentalMode) &&
            (identical(other.preferNaturalChords, preferNaturalChords) ||
                other.preferNaturalChords == preferNaturalChords) &&
            (identical(other.originalFamilyChord, originalFamilyChord) ||
                other.originalFamilyChord == originalFamilyChord) &&
            (identical(other.originalPdfKey, originalPdfKey) ||
                other.originalPdfKey == originalPdfKey) &&
            (identical(other.baseTransposeOffset, baseTransposeOffset) ||
                other.baseTransposeOffset == baseTransposeOffset) &&
            (identical(other.tempoBpm, tempoBpm) ||
                other.tempoBpm == tempoBpm) &&
            (identical(other.defaultTempoBpm, defaultTempoBpm) ||
                other.defaultTempoBpm == defaultTempoBpm) &&
            (identical(other.midiInstrument, midiInstrument) ||
                other.midiInstrument == midiInstrument) &&
            (identical(other.soundFont, soundFont) ||
                other.soundFont == soundFont) &&
            (identical(other.isAudioPlaying, isAudioPlaying) ||
                other.isAudioPlaying == isAudioPlaying));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
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
        showChord,
        searchTerms,
        defaultFont,
        defaultTextScale,
        defaultTextHeight,
        const DeepCollectionEquality().hash(_lastSync),
        const DeepCollectionEquality().hash(_remoteLyricsUpdateAt),
        transposeStep,
        chordAccidentalMode,
        preferNaturalChords,
        originalFamilyChord,
        originalPdfKey,
        baseTransposeOffset,
        tempoBpm,
        defaultTempoBpm,
        midiInstrument,
        soundFont,
        isAudioPlaying
      ]);

  @override
  String toString() {
    return 'SongState(isLoading: $isLoading, isAudioLoading: $isAudioLoading, songBook: $songBook, favoriteSongBook: $favoriteSongBook, bookCode: $bookCode, pageIndex: $pageIndex, verseIndex: $verseIndex, isImageMode: $isImageMode, showSizer: $showSizer, defaultAudioFormat: $defaultAudioFormat, selectedSong: $selectedSong, notes: $notes, sortNotesBy: $sortNotesBy, histories: $histories, playOnlyFavorite: $playOnlyFavorite, shuffleMode: $shuffleMode, shuffleIndex: $shuffleIndex, showAudio: $showAudio, showChord: $showChord, searchTerms: $searchTerms, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight, lastSync: $lastSync, remoteLyricsUpdateAt: $remoteLyricsUpdateAt, transposeStep: $transposeStep, chordAccidentalMode: $chordAccidentalMode, preferNaturalChords: $preferNaturalChords, originalFamilyChord: $originalFamilyChord, originalPdfKey: $originalPdfKey, baseTransposeOffset: $baseTransposeOffset, tempoBpm: $tempoBpm, defaultTempoBpm: $defaultTempoBpm, midiInstrument: $midiInstrument, soundFont: $soundFont, isAudioPlaying: $isAudioPlaying)';
  }
}

/// @nodoc
abstract mixin class _$SongStateCopyWith<$Res>
    implements $SongStateCopyWith<$Res> {
  factory _$SongStateCopyWith(
          _SongState value, $Res Function(_SongState) _then) =
      __$SongStateCopyWithImpl;
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
      bool showChord,
      String searchTerms,
      String defaultFont,
      double defaultTextScale,
      double defaultTextHeight,
      Map<String, DateTime> lastSync,
      Map<String, DateTime> remoteLyricsUpdateAt,
      int transposeStep,
      String chordAccidentalMode,
      bool preferNaturalChords,
      String? originalFamilyChord,
      String? originalPdfKey,
      int baseTransposeOffset,
      double tempoBpm,
      double defaultTempoBpm,
      int? midiInstrument,
      String soundFont,
      bool isAudioPlaying});

  @override
  $SongCopyWith<$Res>? get selectedSong;
}

/// @nodoc
class __$SongStateCopyWithImpl<$Res> implements _$SongStateCopyWith<$Res> {
  __$SongStateCopyWithImpl(this._self, this._then);

  final _SongState _self;
  final $Res Function(_SongState) _then;

  /// Create a copy of SongState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? isAudioLoading = null,
    Object? songBook = null,
    Object? favoriteSongBook = null,
    Object? bookCode = null,
    Object? pageIndex = null,
    Object? verseIndex = null,
    Object? isImageMode = freezed,
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
    Object? showChord = null,
    Object? searchTerms = null,
    Object? defaultFont = null,
    Object? defaultTextScale = null,
    Object? defaultTextHeight = null,
    Object? lastSync = null,
    Object? remoteLyricsUpdateAt = null,
    Object? transposeStep = null,
    Object? chordAccidentalMode = null,
    Object? preferNaturalChords = null,
    Object? originalFamilyChord = freezed,
    Object? originalPdfKey = freezed,
    Object? baseTransposeOffset = null,
    Object? tempoBpm = null,
    Object? defaultTempoBpm = null,
    Object? midiInstrument = freezed,
    Object? soundFont = null,
    Object? isAudioPlaying = null,
  }) {
    return _then(_SongState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isAudioLoading: null == isAudioLoading
          ? _self.isAudioLoading
          : isAudioLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      songBook: null == songBook
          ? _self._songBook
          : songBook // ignore: cast_nullable_to_non_nullable
              as List<SongBook>,
      favoriteSongBook: null == favoriteSongBook
          ? _self._favoriteSongBook
          : favoriteSongBook // ignore: cast_nullable_to_non_nullable
              as List<SongBook>,
      bookCode: null == bookCode
          ? _self.bookCode
          : bookCode // ignore: cast_nullable_to_non_nullable
              as String,
      pageIndex: null == pageIndex
          ? _self.pageIndex
          : pageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      verseIndex: null == verseIndex
          ? _self.verseIndex
          : verseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isImageMode: freezed == isImageMode
          ? _self.isImageMode
          : isImageMode // ignore: cast_nullable_to_non_nullable
              as dynamic,
      showSizer: null == showSizer
          ? _self.showSizer
          : showSizer // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultAudioFormat: null == defaultAudioFormat
          ? _self.defaultAudioFormat
          : defaultAudioFormat // ignore: cast_nullable_to_non_nullable
              as String,
      selectedSong: freezed == selectedSong
          ? _self.selectedSong
          : selectedSong // ignore: cast_nullable_to_non_nullable
              as Song?,
      notes: null == notes
          ? _self._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<SongNote>,
      sortNotesBy: null == sortNotesBy
          ? _self.sortNotesBy
          : sortNotesBy // ignore: cast_nullable_to_non_nullable
              as String,
      histories: null == histories
          ? _self._histories
          : histories // ignore: cast_nullable_to_non_nullable
              as List<SongHistory>,
      playOnlyFavorite: null == playOnlyFavorite
          ? _self.playOnlyFavorite
          : playOnlyFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      shuffleMode: null == shuffleMode
          ? _self.shuffleMode
          : shuffleMode // ignore: cast_nullable_to_non_nullable
              as bool,
      shuffleIndex: null == shuffleIndex
          ? _self._shuffleIndex
          : shuffleIndex // ignore: cast_nullable_to_non_nullable
              as List<int>,
      showAudio: null == showAudio
          ? _self.showAudio
          : showAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      showChord: null == showChord
          ? _self.showChord
          : showChord // ignore: cast_nullable_to_non_nullable
              as bool,
      searchTerms: null == searchTerms
          ? _self.searchTerms
          : searchTerms // ignore: cast_nullable_to_non_nullable
              as String,
      defaultFont: null == defaultFont
          ? _self.defaultFont
          : defaultFont // ignore: cast_nullable_to_non_nullable
              as String,
      defaultTextScale: null == defaultTextScale
          ? _self.defaultTextScale
          : defaultTextScale // ignore: cast_nullable_to_non_nullable
              as double,
      defaultTextHeight: null == defaultTextHeight
          ? _self.defaultTextHeight
          : defaultTextHeight // ignore: cast_nullable_to_non_nullable
              as double,
      lastSync: null == lastSync
          ? _self._lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      remoteLyricsUpdateAt: null == remoteLyricsUpdateAt
          ? _self._remoteLyricsUpdateAt
          : remoteLyricsUpdateAt // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      transposeStep: null == transposeStep
          ? _self.transposeStep
          : transposeStep // ignore: cast_nullable_to_non_nullable
              as int,
      chordAccidentalMode: null == chordAccidentalMode
          ? _self.chordAccidentalMode
          : chordAccidentalMode // ignore: cast_nullable_to_non_nullable
              as String,
      preferNaturalChords: null == preferNaturalChords
          ? _self.preferNaturalChords
          : preferNaturalChords // ignore: cast_nullable_to_non_nullable
              as bool,
      originalFamilyChord: freezed == originalFamilyChord
          ? _self.originalFamilyChord
          : originalFamilyChord // ignore: cast_nullable_to_non_nullable
              as String?,
      originalPdfKey: freezed == originalPdfKey
          ? _self.originalPdfKey
          : originalPdfKey // ignore: cast_nullable_to_non_nullable
              as String?,
      baseTransposeOffset: null == baseTransposeOffset
          ? _self.baseTransposeOffset
          : baseTransposeOffset // ignore: cast_nullable_to_non_nullable
              as int,
      tempoBpm: null == tempoBpm
          ? _self.tempoBpm
          : tempoBpm // ignore: cast_nullable_to_non_nullable
              as double,
      defaultTempoBpm: null == defaultTempoBpm
          ? _self.defaultTempoBpm
          : defaultTempoBpm // ignore: cast_nullable_to_non_nullable
              as double,
      midiInstrument: freezed == midiInstrument
          ? _self.midiInstrument
          : midiInstrument // ignore: cast_nullable_to_non_nullable
              as int?,
      soundFont: null == soundFont
          ? _self.soundFont
          : soundFont // ignore: cast_nullable_to_non_nullable
              as String,
      isAudioPlaying: null == isAudioPlaying
          ? _self.isAudioPlaying
          : isAudioPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
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

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faith_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FaithState {

 List<int> get selectedFaith; List<FaithNote> get notes; Set<int> get pdfLoadingList; String get sortNotesBy; String get language; String get defaultFont; double get defaultTextScale; double get defaultTextHeight;
/// Create a copy of FaithState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FaithStateCopyWith<FaithState> get copyWith => _$FaithStateCopyWithImpl<FaithState>(this as FaithState, _$identity);

  /// Serializes this FaithState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FaithState&&const DeepCollectionEquality().equals(other.selectedFaith, selectedFaith)&&const DeepCollectionEquality().equals(other.notes, notes)&&const DeepCollectionEquality().equals(other.pdfLoadingList, pdfLoadingList)&&(identical(other.sortNotesBy, sortNotesBy) || other.sortNotesBy == sortNotesBy)&&(identical(other.language, language) || other.language == language)&&(identical(other.defaultFont, defaultFont) || other.defaultFont == defaultFont)&&(identical(other.defaultTextScale, defaultTextScale) || other.defaultTextScale == defaultTextScale)&&(identical(other.defaultTextHeight, defaultTextHeight) || other.defaultTextHeight == defaultTextHeight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedFaith),const DeepCollectionEquality().hash(notes),const DeepCollectionEquality().hash(pdfLoadingList),sortNotesBy,language,defaultFont,defaultTextScale,defaultTextHeight);

@override
String toString() {
  return 'FaithState(selectedFaith: $selectedFaith, notes: $notes, pdfLoadingList: $pdfLoadingList, sortNotesBy: $sortNotesBy, language: $language, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight)';
}


}

/// @nodoc
abstract mixin class $FaithStateCopyWith<$Res>  {
  factory $FaithStateCopyWith(FaithState value, $Res Function(FaithState) _then) = _$FaithStateCopyWithImpl;
@useResult
$Res call({
 List<int> selectedFaith, List<FaithNote> notes, Set<int> pdfLoadingList, String sortNotesBy, String language, String defaultFont, double defaultTextScale, double defaultTextHeight
});




}
/// @nodoc
class _$FaithStateCopyWithImpl<$Res>
    implements $FaithStateCopyWith<$Res> {
  _$FaithStateCopyWithImpl(this._self, this._then);

  final FaithState _self;
  final $Res Function(FaithState) _then;

/// Create a copy of FaithState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedFaith = null,Object? notes = null,Object? pdfLoadingList = null,Object? sortNotesBy = null,Object? language = null,Object? defaultFont = null,Object? defaultTextScale = null,Object? defaultTextHeight = null,}) {
  return _then(_self.copyWith(
selectedFaith: null == selectedFaith ? _self.selectedFaith : selectedFaith // ignore: cast_nullable_to_non_nullable
as List<int>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<FaithNote>,pdfLoadingList: null == pdfLoadingList ? _self.pdfLoadingList : pdfLoadingList // ignore: cast_nullable_to_non_nullable
as Set<int>,sortNotesBy: null == sortNotesBy ? _self.sortNotesBy : sortNotesBy // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,defaultFont: null == defaultFont ? _self.defaultFont : defaultFont // ignore: cast_nullable_to_non_nullable
as String,defaultTextScale: null == defaultTextScale ? _self.defaultTextScale : defaultTextScale // ignore: cast_nullable_to_non_nullable
as double,defaultTextHeight: null == defaultTextHeight ? _self.defaultTextHeight : defaultTextHeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FaithState].
extension FaithStatePatterns on FaithState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FaithState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FaithState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FaithState value)  $default,){
final _that = this;
switch (_that) {
case _FaithState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FaithState value)?  $default,){
final _that = this;
switch (_that) {
case _FaithState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> selectedFaith,  List<FaithNote> notes,  Set<int> pdfLoadingList,  String sortNotesBy,  String language,  String defaultFont,  double defaultTextScale,  double defaultTextHeight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FaithState() when $default != null:
return $default(_that.selectedFaith,_that.notes,_that.pdfLoadingList,_that.sortNotesBy,_that.language,_that.defaultFont,_that.defaultTextScale,_that.defaultTextHeight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> selectedFaith,  List<FaithNote> notes,  Set<int> pdfLoadingList,  String sortNotesBy,  String language,  String defaultFont,  double defaultTextScale,  double defaultTextHeight)  $default,) {final _that = this;
switch (_that) {
case _FaithState():
return $default(_that.selectedFaith,_that.notes,_that.pdfLoadingList,_that.sortNotesBy,_that.language,_that.defaultFont,_that.defaultTextScale,_that.defaultTextHeight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> selectedFaith,  List<FaithNote> notes,  Set<int> pdfLoadingList,  String sortNotesBy,  String language,  String defaultFont,  double defaultTextScale,  double defaultTextHeight)?  $default,) {final _that = this;
switch (_that) {
case _FaithState() when $default != null:
return $default(_that.selectedFaith,_that.notes,_that.pdfLoadingList,_that.sortNotesBy,_that.language,_that.defaultFont,_that.defaultTextScale,_that.defaultTextHeight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FaithState extends FaithState {
  const _FaithState({final  List<int> selectedFaith = const [], final  List<FaithNote> notes = const [], final  Set<int> pdfLoadingList = const {}, this.sortNotesBy = 'Newest', this.language = 'id', this.defaultFont = 'Roboto', this.defaultTextScale = 1.2, this.defaultTextHeight = 1.5}): _selectedFaith = selectedFaith,_notes = notes,_pdfLoadingList = pdfLoadingList,super._();
  factory _FaithState.fromJson(Map<String, dynamic> json) => _$FaithStateFromJson(json);

 final  List<int> _selectedFaith;
@override@JsonKey() List<int> get selectedFaith {
  if (_selectedFaith is EqualUnmodifiableListView) return _selectedFaith;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedFaith);
}

 final  List<FaithNote> _notes;
@override@JsonKey() List<FaithNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

 final  Set<int> _pdfLoadingList;
@override@JsonKey() Set<int> get pdfLoadingList {
  if (_pdfLoadingList is EqualUnmodifiableSetView) return _pdfLoadingList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_pdfLoadingList);
}

@override@JsonKey() final  String sortNotesBy;
@override@JsonKey() final  String language;
@override@JsonKey() final  String defaultFont;
@override@JsonKey() final  double defaultTextScale;
@override@JsonKey() final  double defaultTextHeight;

/// Create a copy of FaithState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FaithStateCopyWith<_FaithState> get copyWith => __$FaithStateCopyWithImpl<_FaithState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FaithStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FaithState&&const DeepCollectionEquality().equals(other._selectedFaith, _selectedFaith)&&const DeepCollectionEquality().equals(other._notes, _notes)&&const DeepCollectionEquality().equals(other._pdfLoadingList, _pdfLoadingList)&&(identical(other.sortNotesBy, sortNotesBy) || other.sortNotesBy == sortNotesBy)&&(identical(other.language, language) || other.language == language)&&(identical(other.defaultFont, defaultFont) || other.defaultFont == defaultFont)&&(identical(other.defaultTextScale, defaultTextScale) || other.defaultTextScale == defaultTextScale)&&(identical(other.defaultTextHeight, defaultTextHeight) || other.defaultTextHeight == defaultTextHeight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedFaith),const DeepCollectionEquality().hash(_notes),const DeepCollectionEquality().hash(_pdfLoadingList),sortNotesBy,language,defaultFont,defaultTextScale,defaultTextHeight);

@override
String toString() {
  return 'FaithState(selectedFaith: $selectedFaith, notes: $notes, pdfLoadingList: $pdfLoadingList, sortNotesBy: $sortNotesBy, language: $language, defaultFont: $defaultFont, defaultTextScale: $defaultTextScale, defaultTextHeight: $defaultTextHeight)';
}


}

/// @nodoc
abstract mixin class _$FaithStateCopyWith<$Res> implements $FaithStateCopyWith<$Res> {
  factory _$FaithStateCopyWith(_FaithState value, $Res Function(_FaithState) _then) = __$FaithStateCopyWithImpl;
@override @useResult
$Res call({
 List<int> selectedFaith, List<FaithNote> notes, Set<int> pdfLoadingList, String sortNotesBy, String language, String defaultFont, double defaultTextScale, double defaultTextHeight
});




}
/// @nodoc
class __$FaithStateCopyWithImpl<$Res>
    implements _$FaithStateCopyWith<$Res> {
  __$FaithStateCopyWithImpl(this._self, this._then);

  final _FaithState _self;
  final $Res Function(_FaithState) _then;

/// Create a copy of FaithState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedFaith = null,Object? notes = null,Object? pdfLoadingList = null,Object? sortNotesBy = null,Object? language = null,Object? defaultFont = null,Object? defaultTextScale = null,Object? defaultTextHeight = null,}) {
  return _then(_FaithState(
selectedFaith: null == selectedFaith ? _self._selectedFaith : selectedFaith // ignore: cast_nullable_to_non_nullable
as List<int>,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<FaithNote>,pdfLoadingList: null == pdfLoadingList ? _self._pdfLoadingList : pdfLoadingList // ignore: cast_nullable_to_non_nullable
as Set<int>,sortNotesBy: null == sortNotesBy ? _self.sortNotesBy : sortNotesBy // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,defaultFont: null == defaultFont ? _self.defaultFont : defaultFont // ignore: cast_nullable_to_non_nullable
as String,defaultTextScale: null == defaultTextScale ? _self.defaultTextScale : defaultTextScale // ignore: cast_nullable_to_non_nullable
as double,defaultTextHeight: null == defaultTextHeight ? _self.defaultTextHeight : defaultTextHeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

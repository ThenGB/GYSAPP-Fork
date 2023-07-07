// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faith_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

FaithState _$FaithStateFromJson(Map<String, dynamic> json) {
  return _FaithState.fromJson(json);
}

/// @nodoc
mixin _$FaithState {
  List<int> get selectedFaith => throw _privateConstructorUsedError;
  List<FaithNote> get notes => throw _privateConstructorUsedError;
  String get sortNotesBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FaithStateCopyWith<FaithState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaithStateCopyWith<$Res> {
  factory $FaithStateCopyWith(
          FaithState value, $Res Function(FaithState) then) =
      _$FaithStateCopyWithImpl<$Res, FaithState>;
  @useResult
  $Res call(
      {List<int> selectedFaith, List<FaithNote> notes, String sortNotesBy});
}

/// @nodoc
class _$FaithStateCopyWithImpl<$Res, $Val extends FaithState>
    implements $FaithStateCopyWith<$Res> {
  _$FaithStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedFaith = null,
    Object? notes = null,
    Object? sortNotesBy = null,
  }) {
    return _then(_value.copyWith(
      selectedFaith: null == selectedFaith
          ? _value.selectedFaith
          : selectedFaith // ignore: cast_nullable_to_non_nullable
              as List<int>,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<FaithNote>,
      sortNotesBy: null == sortNotesBy
          ? _value.sortNotesBy
          : sortNotesBy // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_FaithStateCopyWith<$Res>
    implements $FaithStateCopyWith<$Res> {
  factory _$$_FaithStateCopyWith(
          _$_FaithState value, $Res Function(_$_FaithState) then) =
      __$$_FaithStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<int> selectedFaith, List<FaithNote> notes, String sortNotesBy});
}

/// @nodoc
class __$$_FaithStateCopyWithImpl<$Res>
    extends _$FaithStateCopyWithImpl<$Res, _$_FaithState>
    implements _$$_FaithStateCopyWith<$Res> {
  __$$_FaithStateCopyWithImpl(
      _$_FaithState _value, $Res Function(_$_FaithState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedFaith = null,
    Object? notes = null,
    Object? sortNotesBy = null,
  }) {
    return _then(_$_FaithState(
      selectedFaith: null == selectedFaith
          ? _value._selectedFaith
          : selectedFaith // ignore: cast_nullable_to_non_nullable
              as List<int>,
      notes: null == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<FaithNote>,
      sortNotesBy: null == sortNotesBy
          ? _value.sortNotesBy
          : sortNotesBy // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_FaithState extends _FaithState {
  const _$_FaithState(
      {final List<int> selectedFaith = const [],
      final List<FaithNote> notes = const [],
      this.sortNotesBy = 'Newest'})
      : _selectedFaith = selectedFaith,
        _notes = notes,
        super._();

  factory _$_FaithState.fromJson(Map<String, dynamic> json) =>
      _$$_FaithStateFromJson(json);

  final List<int> _selectedFaith;
  @override
  @JsonKey()
  List<int> get selectedFaith {
    if (_selectedFaith is EqualUnmodifiableListView) return _selectedFaith;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedFaith);
  }

  final List<FaithNote> _notes;
  @override
  @JsonKey()
  List<FaithNote> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  @JsonKey()
  final String sortNotesBy;

  @override
  String toString() {
    return 'FaithState(selectedFaith: $selectedFaith, notes: $notes, sortNotesBy: $sortNotesBy)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_FaithState &&
            const DeepCollectionEquality()
                .equals(other._selectedFaith, _selectedFaith) &&
            const DeepCollectionEquality().equals(other._notes, _notes) &&
            (identical(other.sortNotesBy, sortNotesBy) ||
                other.sortNotesBy == sortNotesBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_selectedFaith),
      const DeepCollectionEquality().hash(_notes),
      sortNotesBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_FaithStateCopyWith<_$_FaithState> get copyWith =>
      __$$_FaithStateCopyWithImpl<_$_FaithState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FaithStateToJson(
      this,
    );
  }
}

abstract class _FaithState extends FaithState {
  const factory _FaithState(
      {final List<int> selectedFaith,
      final List<FaithNote> notes,
      final String sortNotesBy}) = _$_FaithState;
  const _FaithState._() : super._();

  factory _FaithState.fromJson(Map<String, dynamic> json) =
      _$_FaithState.fromJson;

  @override
  List<int> get selectedFaith;
  @override
  List<FaithNote> get notes;
  @override
  String get sortNotesBy;
  @override
  @JsonKey(ignore: true)
  _$$_FaithStateCopyWith<_$_FaithState> get copyWith =>
      throw _privateConstructorUsedError;
}

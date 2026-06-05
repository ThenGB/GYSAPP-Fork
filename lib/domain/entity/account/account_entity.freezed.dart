// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Account {

@JsonKey(name: 'id') int get id;@JsonKey(name: 'email') String? get email;@JsonKey(name: 'name') String? get name;@JsonKey(name: 'type') String? get type;@JsonKey(name: 'mobilephone') String? get mobilePhone;@JsonKey(name: 'profilepicture') String? get profilePicture;@JsonKey(name: 'status') String? get status;@JsonKey(name: 'branchid') int get branchId;@JsonKey(name: 'baptized') dynamic get baptized;@JsonKey(name: 'member_type') String? get memberType;@JsonKey(name: 'jenis_anggota') String? get jenisAnggota;@JsonKey(name: 'wilayah') String? get wilayah;@JsonKey(name: 'branchname') String? get branchName;@JsonKey(name: 'branch') String? get branch;
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCopyWith<Account> get copyWith => _$AccountCopyWithImpl<Account>(this as Account, _$identity);

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Account&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.mobilePhone, mobilePhone) || other.mobilePhone == mobilePhone)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.status, status) || other.status == status)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&const DeepCollectionEquality().equals(other.baptized, baptized)&&(identical(other.memberType, memberType) || other.memberType == memberType)&&(identical(other.jenisAnggota, jenisAnggota) || other.jenisAnggota == jenisAnggota)&&(identical(other.wilayah, wilayah) || other.wilayah == wilayah)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,type,mobilePhone,profilePicture,status,branchId,const DeepCollectionEquality().hash(baptized),memberType,jenisAnggota,wilayah,branchName,branch);

@override
String toString() {
  return 'Account(id: $id, email: $email, name: $name, type: $type, mobilePhone: $mobilePhone, profilePicture: $profilePicture, status: $status, branchId: $branchId, baptized: $baptized, memberType: $memberType, jenisAnggota: $jenisAnggota, wilayah: $wilayah, branchName: $branchName, branch: $branch)';
}


}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res>  {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) = _$AccountCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'email') String? email,@JsonKey(name: 'name') String? name,@JsonKey(name: 'type') String? type,@JsonKey(name: 'mobilephone') String? mobilePhone,@JsonKey(name: 'profilepicture') String? profilePicture,@JsonKey(name: 'status') String? status,@JsonKey(name: 'branchid') int branchId,@JsonKey(name: 'baptized') dynamic baptized,@JsonKey(name: 'member_type') String? memberType,@JsonKey(name: 'jenis_anggota') String? jenisAnggota,@JsonKey(name: 'wilayah') String? wilayah,@JsonKey(name: 'branchname') String? branchName,@JsonKey(name: 'branch') String? branch
});




}
/// @nodoc
class _$AccountCopyWithImpl<$Res>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = freezed,Object? name = freezed,Object? type = freezed,Object? mobilePhone = freezed,Object? profilePicture = freezed,Object? status = freezed,Object? branchId = null,Object? baptized = freezed,Object? memberType = freezed,Object? jenisAnggota = freezed,Object? wilayah = freezed,Object? branchName = freezed,Object? branch = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,mobilePhone: freezed == mobilePhone ? _self.mobilePhone : mobilePhone // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as int,baptized: freezed == baptized ? _self.baptized : baptized // ignore: cast_nullable_to_non_nullable
as dynamic,memberType: freezed == memberType ? _self.memberType : memberType // ignore: cast_nullable_to_non_nullable
as String?,jenisAnggota: freezed == jenisAnggota ? _self.jenisAnggota : jenisAnggota // ignore: cast_nullable_to_non_nullable
as String?,wilayah: freezed == wilayah ? _self.wilayah : wilayah // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Account value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Account value)  $default,){
final _that = this;
switch (_that) {
case _Account():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Account value)?  $default,){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'type')  String? type, @JsonKey(name: 'mobilephone')  String? mobilePhone, @JsonKey(name: 'profilepicture')  String? profilePicture, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'branchid')  int branchId, @JsonKey(name: 'baptized')  dynamic baptized, @JsonKey(name: 'member_type')  String? memberType, @JsonKey(name: 'jenis_anggota')  String? jenisAnggota, @JsonKey(name: 'wilayah')  String? wilayah, @JsonKey(name: 'branchname')  String? branchName, @JsonKey(name: 'branch')  String? branch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.type,_that.mobilePhone,_that.profilePicture,_that.status,_that.branchId,_that.baptized,_that.memberType,_that.jenisAnggota,_that.wilayah,_that.branchName,_that.branch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'type')  String? type, @JsonKey(name: 'mobilephone')  String? mobilePhone, @JsonKey(name: 'profilepicture')  String? profilePicture, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'branchid')  int branchId, @JsonKey(name: 'baptized')  dynamic baptized, @JsonKey(name: 'member_type')  String? memberType, @JsonKey(name: 'jenis_anggota')  String? jenisAnggota, @JsonKey(name: 'wilayah')  String? wilayah, @JsonKey(name: 'branchname')  String? branchName, @JsonKey(name: 'branch')  String? branch)  $default,) {final _that = this;
switch (_that) {
case _Account():
return $default(_that.id,_that.email,_that.name,_that.type,_that.mobilePhone,_that.profilePicture,_that.status,_that.branchId,_that.baptized,_that.memberType,_that.jenisAnggota,_that.wilayah,_that.branchName,_that.branch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'type')  String? type, @JsonKey(name: 'mobilephone')  String? mobilePhone, @JsonKey(name: 'profilepicture')  String? profilePicture, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'branchid')  int branchId, @JsonKey(name: 'baptized')  dynamic baptized, @JsonKey(name: 'member_type')  String? memberType, @JsonKey(name: 'jenis_anggota')  String? jenisAnggota, @JsonKey(name: 'wilayah')  String? wilayah, @JsonKey(name: 'branchname')  String? branchName, @JsonKey(name: 'branch')  String? branch)?  $default,) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.type,_that.mobilePhone,_that.profilePicture,_that.status,_that.branchId,_that.baptized,_that.memberType,_that.jenisAnggota,_that.wilayah,_that.branchName,_that.branch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Account extends Account {
  const _Account({@JsonKey(name: 'id') this.id = 0, @JsonKey(name: 'email') this.email, @JsonKey(name: 'name') this.name, @JsonKey(name: 'type') this.type, @JsonKey(name: 'mobilephone') this.mobilePhone, @JsonKey(name: 'profilepicture') this.profilePicture, @JsonKey(name: 'status') this.status, @JsonKey(name: 'branchid') this.branchId = 0, @JsonKey(name: 'baptized') this.baptized, @JsonKey(name: 'member_type') this.memberType, @JsonKey(name: 'jenis_anggota') this.jenisAnggota, @JsonKey(name: 'wilayah') this.wilayah, @JsonKey(name: 'branchname') this.branchName, @JsonKey(name: 'branch') this.branch}): super._();
  factory _Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

@override@JsonKey(name: 'id') final  int id;
@override@JsonKey(name: 'email') final  String? email;
@override@JsonKey(name: 'name') final  String? name;
@override@JsonKey(name: 'type') final  String? type;
@override@JsonKey(name: 'mobilephone') final  String? mobilePhone;
@override@JsonKey(name: 'profilepicture') final  String? profilePicture;
@override@JsonKey(name: 'status') final  String? status;
@override@JsonKey(name: 'branchid') final  int branchId;
@override@JsonKey(name: 'baptized') final  dynamic baptized;
@override@JsonKey(name: 'member_type') final  String? memberType;
@override@JsonKey(name: 'jenis_anggota') final  String? jenisAnggota;
@override@JsonKey(name: 'wilayah') final  String? wilayah;
@override@JsonKey(name: 'branchname') final  String? branchName;
@override@JsonKey(name: 'branch') final  String? branch;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCopyWith<_Account> get copyWith => __$AccountCopyWithImpl<_Account>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Account&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.mobilePhone, mobilePhone) || other.mobilePhone == mobilePhone)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.status, status) || other.status == status)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&const DeepCollectionEquality().equals(other.baptized, baptized)&&(identical(other.memberType, memberType) || other.memberType == memberType)&&(identical(other.jenisAnggota, jenisAnggota) || other.jenisAnggota == jenisAnggota)&&(identical(other.wilayah, wilayah) || other.wilayah == wilayah)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,type,mobilePhone,profilePicture,status,branchId,const DeepCollectionEquality().hash(baptized),memberType,jenisAnggota,wilayah,branchName,branch);

@override
String toString() {
  return 'Account(id: $id, email: $email, name: $name, type: $type, mobilePhone: $mobilePhone, profilePicture: $profilePicture, status: $status, branchId: $branchId, baptized: $baptized, memberType: $memberType, jenisAnggota: $jenisAnggota, wilayah: $wilayah, branchName: $branchName, branch: $branch)';
}


}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) = __$AccountCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'email') String? email,@JsonKey(name: 'name') String? name,@JsonKey(name: 'type') String? type,@JsonKey(name: 'mobilephone') String? mobilePhone,@JsonKey(name: 'profilepicture') String? profilePicture,@JsonKey(name: 'status') String? status,@JsonKey(name: 'branchid') int branchId,@JsonKey(name: 'baptized') dynamic baptized,@JsonKey(name: 'member_type') String? memberType,@JsonKey(name: 'jenis_anggota') String? jenisAnggota,@JsonKey(name: 'wilayah') String? wilayah,@JsonKey(name: 'branchname') String? branchName,@JsonKey(name: 'branch') String? branch
});




}
/// @nodoc
class __$AccountCopyWithImpl<$Res>
    implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = freezed,Object? name = freezed,Object? type = freezed,Object? mobilePhone = freezed,Object? profilePicture = freezed,Object? status = freezed,Object? branchId = null,Object? baptized = freezed,Object? memberType = freezed,Object? jenisAnggota = freezed,Object? wilayah = freezed,Object? branchName = freezed,Object? branch = freezed,}) {
  return _then(_Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,mobilePhone: freezed == mobilePhone ? _self.mobilePhone : mobilePhone // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as int,baptized: freezed == baptized ? _self.baptized : baptized // ignore: cast_nullable_to_non_nullable
as dynamic,memberType: freezed == memberType ? _self.memberType : memberType // ignore: cast_nullable_to_non_nullable
as String?,jenisAnggota: freezed == jenisAnggota ? _self.jenisAnggota : jenisAnggota // ignore: cast_nullable_to_non_nullable
as String?,wilayah: freezed == wilayah ? _self.wilayah : wilayah // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

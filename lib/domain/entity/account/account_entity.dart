import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_entity.freezed.dart';
part 'account_entity.g.dart';

@freezed
class Account with _$Account {
  const Account._();
  const factory Account({
    @JsonKey(name: 'id') @Default(0) int id,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'mobilephone') String? mobilePhone,
    @JsonKey(name: 'profilepicture') String? profilePicture,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'branchid') @Default(0) int branchId,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}

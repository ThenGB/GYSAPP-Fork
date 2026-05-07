import 'package:freezed_annotation/freezed_annotation.dart';

part 'bcvbc.freezed.dart';
part 'bcvbc.g.dart';

@freezed
abstract class Bcvbc with _$Bcvbc {
  const Bcvbc._();
  const factory Bcvbc({
    @JsonKey(name: 'b') String? b,
    @JsonKey(name: 'c') String? c,
    @JsonKey(name: 'v') String? v,
    @JsonKey(name: 'bc') int? bc,
  }) = _Bcvbc;

  factory Bcvbc.fromJson(Map<String, dynamic> json) => _$BcvbcFromJson(json);

  factory Bcvbc.fromBibleId(int bibleId) {
    final bcv = bibleId.toString();
    var b = bcv.substring(0, 2);
    if (bcv.length == 7) {
      b = bcv.substring(0, 1);
    } else if (bcv.length == 8) {
      b = bcv.substring(0, 2);
    } else {
      b = bcv.substring(0, 3);
    }
    var c = bcv.substring(bcv.length - 6, bcv.length).substring(0, 3);
    var v = bcv.substring(bcv.length - 3, bcv.length);
    var bc = int.tryParse(b + c);
    return Bcvbc(
      b: b,
      c: c,
      v: v,
      bc: bc,
    );
  }
}


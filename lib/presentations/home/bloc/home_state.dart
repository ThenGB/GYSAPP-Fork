import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/menulink/menulink_entity.dart';
import '../../../domain/entity/sauh/sauh_entity.dart';
import '../../../domain/entity/truevoice/truevoice_entity.dart';

part 'home_state.freezed.dart';
part 'home_state.g.dart';

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default([]) List<Sauh> sauhs,
    @Default([]) List<TrueVoice> trueVoices,
    @Default([]) List<Menulink> menuLinks,
    @Default(true) bool isSuaraSejatiEnabled,
    @Default(true) bool isSauhEnabled,
    OurMannaVerse? todayVerse,
  }) = _HomeState;

  bool get isSauhEmpty => sauhs.isEmpty;
  bool get hasTodayVerse => todayVerse != null && todayVerse!.text.isNotEmpty;

  factory HomeState.fromJson(Map<String, dynamic> json) =>
      _$HomeStateFromJson(json);
}

class OurMannaVerse {
  final String text;
  final String reference;
  final String? bibleCodeName;
  final String? originalReference;

  OurMannaVerse({required this.text, required this.reference, this.bibleCodeName, this.originalReference});

  factory OurMannaVerse.fromJson(Map<String, dynamic> json) {
    return OurMannaVerse(
      text: json['text'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      bibleCodeName: json['bibleCodeName'] as String?,
      originalReference: json['originalReference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'reference': reference, 'bibleCodeName': bibleCodeName, 'originalReference': originalReference};
}

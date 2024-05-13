// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faith_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FaithStateImpl _$$FaithStateImplFromJson(Map<String, dynamic> json) =>
    _$FaithStateImpl(
      selectedFaith: (json['selectedFaith'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => FaithNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pdfLoadingList: (json['pdfLoadingList'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toSet() ??
          const {},
      sortNotesBy: json['sortNotesBy'] as String? ?? 'Newest',
      language: json['language'] as String? ?? 'id',
      defaultFont: json['defaultFont'] as String? ?? 'Roboto',
      defaultTextScale: (json['defaultTextScale'] as num?)?.toDouble() ?? 1.2,
      defaultTextHeight: (json['defaultTextHeight'] as num?)?.toDouble() ?? 1.5,
    );

Map<String, dynamic> _$$FaithStateImplToJson(_$FaithStateImpl instance) =>
    <String, dynamic>{
      'selectedFaith': instance.selectedFaith,
      'notes': instance.notes,
      'pdfLoadingList': instance.pdfLoadingList.toList(),
      'sortNotesBy': instance.sortNotesBy,
      'language': instance.language,
      'defaultFont': instance.defaultFont,
      'defaultTextScale': instance.defaultTextScale,
      'defaultTextHeight': instance.defaultTextHeight,
    };

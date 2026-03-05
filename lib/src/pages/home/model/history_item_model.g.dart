// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryItemModel _$HistoryItemModelFromJson(Map<String, dynamic> json) =>
    HistoryItemModel(
      id: json['id'] as String,
      processingType: $enumDecode(
        _$ProcessingTypeEnumMap,
        json['processingType'],
      ),
      date: DateTime.parse(json['date'] as String),
      thumbnailPath: json['thumbnailPath'] as String?,
    );

Map<String, dynamic> _$HistoryItemModelToJson(HistoryItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'processingType': _$ProcessingTypeEnumMap[instance.processingType]!,
      'date': instance.date.toIso8601String(),
      'thumbnailPath': instance.thumbnailPath,
    };

const _$ProcessingTypeEnumMap = {
  ProcessingType.face: 'face',
  ProcessingType.document: 'document',
};

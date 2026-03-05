// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_args_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultArgsModel _$ResultArgsModelFromJson(Map<String, dynamic> json) =>
    ResultArgsModel(
      originalImagePath: json['originalImagePath'] as String,
      processingType: $enumDecode(
        _$ProcessingTypeEnumMap,
        json['processingType'],
      ),
      processedImagePath: json['processedImagePath'] as String?,
    );

Map<String, dynamic> _$ResultArgsModelToJson(ResultArgsModel instance) =>
    <String, dynamic>{
      'originalImagePath': instance.originalImagePath,
      'processedImagePath': instance.processedImagePath,
      'processingType': _$ProcessingTypeEnumMap[instance.processingType]!,
    };

const _$ProcessingTypeEnumMap = {
  ProcessingType.face: 'face',
  ProcessingType.document: 'document',
};

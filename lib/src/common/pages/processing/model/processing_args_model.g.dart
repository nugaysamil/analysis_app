// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processing_args_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProcessingArgsModel _$ProcessingArgsModelFromJson(Map<String, dynamic> json) =>
    ProcessingArgsModel(
      imagePath: json['imagePath'] as String,
      processingType: $enumDecode(
        _$ProcessingTypeEnumMap,
        json['processingType'],
      ),
    );

Map<String, dynamic> _$ProcessingArgsModelToJson(
  ProcessingArgsModel instance,
) => <String, dynamic>{
  'imagePath': instance.imagePath,
  'processingType': _$ProcessingTypeEnumMap[instance.processingType]!,
};

const _$ProcessingTypeEnumMap = {
  ProcessingType.face: 'face',
  ProcessingType.document: 'document',
};

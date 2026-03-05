// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_processing_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaceProcessingResultModel _$FaceProcessingResultModelFromJson(
  Map<String, dynamic> json,
) => FaceProcessingResultModel(
  originalPath: json['originalPath'] as String,
  processedPath: json['processedPath'] as String,
  facesDetected: (json['facesDetected'] as num).toInt(),
);

Map<String, dynamic> _$FaceProcessingResultModelToJson(
  FaceProcessingResultModel instance,
) => <String, dynamic>{
  'originalPath': instance.originalPath,
  'processedPath': instance.processedPath,
  'facesDetected': instance.facesDetected,
};

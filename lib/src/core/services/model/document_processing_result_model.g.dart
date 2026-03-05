// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_processing_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentProcessingResultModel _$DocumentProcessingResultModelFromJson(
  Map<String, dynamic> json,
) => DocumentProcessingResultModel(
  originalPath: json['originalPath'] as String,
  processedImagePath: json['processedImagePath'] as String,
  pdfPath: json['pdfPath'] as String,
  recognizedText: json['recognizedText'] as String,
);

Map<String, dynamic> _$DocumentProcessingResultModelToJson(
  DocumentProcessingResultModel instance,
) => <String, dynamic>{
  'originalPath': instance.originalPath,
  'processedImagePath': instance.processedImagePath,
  'pdfPath': instance.pdfPath,
  'recognizedText': instance.recognizedText,
};

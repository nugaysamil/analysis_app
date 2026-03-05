import 'package:json_annotation/json_annotation.dart';

part 'document_processing_result_model.g.dart';

@JsonSerializable()
class DocumentProcessingResultModel {
  const DocumentProcessingResultModel({
    required this.originalPath,
    required this.processedImagePath,
    required this.pdfPath,
    required this.recognizedText,
  });

  factory DocumentProcessingResultModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentProcessingResultModelFromJson(json);

  final String originalPath;
  final String processedImagePath;
  final String pdfPath;
  final String recognizedText;

  Map<String, dynamic> toJson() => _$DocumentProcessingResultModelToJson(this);
}

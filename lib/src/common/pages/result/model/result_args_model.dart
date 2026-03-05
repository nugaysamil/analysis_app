import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'result_args_model.g.dart';

@JsonSerializable()
class ResultArgsModel {
  const ResultArgsModel({
    required this.originalImagePath,
    required this.processingType,
    this.processedImagePath,
    this.pdfPath,
  });

  factory ResultArgsModel.fromJson(Map<String, dynamic> json) =>
      _$ResultArgsModelFromJson(json);

  final String originalImagePath;
  final String? processedImagePath;
  final String? pdfPath;
  final ProcessingType processingType;

  Map<String, dynamic> toJson() => _$ResultArgsModelToJson(this);
}

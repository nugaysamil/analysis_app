import 'package:json_annotation/json_annotation.dart';

part 'face_processing_result_model.g.dart';

@JsonSerializable()
class FaceProcessingResultModel {
  const FaceProcessingResultModel({
    required this.originalPath,
    required this.processedPath,
    required this.facesDetected,
  });

  factory FaceProcessingResultModel.fromJson(Map<String, dynamic> json) =>
      _$FaceProcessingResultModelFromJson(json);

  final String originalPath;
  final String processedPath;
  final int facesDetected;

  Map<String, dynamic> toJson() => _$FaceProcessingResultModelToJson(this);
}

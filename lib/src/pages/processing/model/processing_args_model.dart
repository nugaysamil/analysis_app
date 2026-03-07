import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'processing_args_model.g.dart';

@JsonSerializable()
class ProcessingArgsModel {
  const ProcessingArgsModel({
    required this.imagePath,
    this.processingType,
  });

  factory ProcessingArgsModel.fromJson(Map<String, dynamic> json) =>
      _$ProcessingArgsModelFromJson(json);

  final String imagePath;
  final ProcessingType? processingType;

  Map<String, dynamic> toJson() => _$ProcessingArgsModelToJson(this);
}

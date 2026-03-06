import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_item_model.g.dart';

@JsonSerializable()
class HistoryItemModel {
  const HistoryItemModel({
    required this.id,
    required this.processingType,
    required this.date,
    this.thumbnailPath,
    this.processedImagePath,
    this.pdfPath,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryItemModelFromJson(json);

  final String id;
  final ProcessingType processingType;
  final DateTime date;
  final String? thumbnailPath;
  final String? processedImagePath;
  final String? pdfPath;

  Map<String, dynamic> toJson() => _$HistoryItemModelToJson(this);
}

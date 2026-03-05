
import 'package:analysis_app/src/core/enum/processing_type.dart';

class HistoryItemModel {

  const HistoryItemModel({
    required this.id,
    required this.processingType,
    required this.date,
    this.thumbnailPath,
  });
    
  final String id;
  final ProcessingType processingType;
  final DateTime date;
  final String? thumbnailPath;

}

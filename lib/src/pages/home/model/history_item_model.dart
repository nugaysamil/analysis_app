enum ProcessingType { face, document }

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

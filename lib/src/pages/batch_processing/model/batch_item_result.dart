import 'package:analysis_app/src/core/enum/processing_type.dart';

// Holds the result of a single image within a batch processing run.

class BatchItemResult {
  const BatchItemResult({
    required this.originalPath,
    required this.processingType,
    this.processedImagePath,
    this.pdfPath,
    this.error,
  });

  final String originalPath;
  final ProcessingType processingType;
  final String? processedImagePath;
  final String? pdfPath;
  final String? error;

  bool get isSuccess => error == null;
}

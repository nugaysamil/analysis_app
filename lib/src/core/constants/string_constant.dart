// Non-translatable string constants (app name, formats, box names, etc.).
class StringConstant {
  StringConstant._();

  static const String appTitle = 'ImageFlow';
  static const String dateFormat = 'MMM dd, yyyy';
  static const String pdf = 'PDF';

  // Hive box names
  static const String historyBox = 'history_box';

  // Log tags
  static const String tagContentDetectionService = 'ContentDetectionService';
  static const String tagDocumentProcessingService = 'DocumentProcessingService';
  static const String tagFaceProcessingService = 'FaceProcessingService';
  static const String tagImageProcessingHelper = 'ImageProcessingHelper';
  static const String tagHistoryDetailViewModel = 'HistoryDetailViewModel';
  static const String tagHomeViewModel = 'HomeViewModel';
  static const String tagPdfResultViewModel = 'PdfResultViewModel';
  static const String tagProcessingViewModel = 'ProcessingViewModel';
}

import 'package:analysis_app/src/core/enum/processing_type.dart';

class ProcessingArgsModel {
  const ProcessingArgsModel({
    required this.imagePath,
    required this.processingType,
  });

  final String imagePath;
  final ProcessingType processingType;
}

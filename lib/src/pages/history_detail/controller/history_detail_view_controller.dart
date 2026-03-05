import 'dart:io';

import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/localization/locale_keys.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Manages History Detail screen state and metadata.
class HistoryDetailViewModel extends GetxController {
  // Retrieves navigation arguments as a typed model, null-safe.
  HistoryItemModel? get args => Get.arguments as HistoryItemModel?;

  // Page title based on processing type.
  String get pageTitle => args?.processingType == ProcessingType.face
      ? LocaleKeys.faceResult.tr
      : LocaleKeys.pdfCreated.tr;

  // Whether the item is a face processing result.
  bool get isFace => args?.processingType == ProcessingType.face;

  // Original image path from the history item.
  String get imagePath => args?.thumbnailPath ?? '';

  // Formatted date for metadata display.
  String get formattedDate =>
      DateFormat(StringConstant.dateFormat).format(args?.date ?? DateTime.now());

  // Processing type label for metadata display.
  String get processingTypeLabel => isFace
      ? LocaleKeys.faceProcessed.tr
      : LocaleKeys.documentScan.tr;

  // Calculates the file size from the image path.
  String get fileSize {
    if (imagePath.isEmpty) return '-';
    final file = File(imagePath);
    if (!file.existsSync()) return '-';
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  void onInit() {
    super.onInit();
    if (args == null) {
      Get.back<void>();
    }
  }

  // Navigates back to the home screen.
  void onBackTap() {
    Get.back<void>();
  }

  // Opens the PDF in an external viewer (document flow only).
  void onOpenPdfTap() {
    // TODO(pdf): Implement external PDF viewer launch
  }
}

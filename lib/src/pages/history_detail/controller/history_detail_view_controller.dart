import 'dart:io';

import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/error/app_error_handler.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

// Manages History Detail screen state and metadata.
class HistoryDetailViewController extends GetxController {
  bool isFace = false;
  String imagePath = '';
  String processedImagePath = '';
  String pdfPath = '';
  String formattedDate = '';
  String fileSize = '-';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as HistoryItemModel?;
    if (args == null) {
      Get.back<void>();
      return;
    }
    _initFromArgs(args);
  }

  // Parses navigation arguments and populates local state.
  void _initFromArgs(HistoryItemModel args) {
    isFace = args.processingType == ProcessingType.face;
    imagePath = args.thumbnailPath ?? '';
    processedImagePath = args.processedImagePath ?? '';
    pdfPath = args.pdfPath ?? '';
    formattedDate = DateFormat(StringConstant.dateFormat).format(args.date);
    fileSize = _calculateFileSize(
      isFace ? processedImagePath : pdfPath,
    );
  }

  // Computes human-readable file size from the given path.
  String _calculateFileSize(String path) {
    if (path.isEmpty) return '-';
    try {
      final file = File(path);
      if (!file.existsSync()) return '-';
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e, stack) {
      AppErrorHandler.log(StringConstant.tagHistoryDetailViewModel, e, stack);
      return '-';
    }
  }

  // Navigates back to the home screen.
  void onBackTap() {
    Get.back<void>();
  }

  // Copies PDF to temp dir and opens in external viewer.
  Future<void> onOpenPdfTap() async {
    try {
      if (pdfPath.isEmpty) return;
      final file = File(pdfPath);
      if (!await file.exists()) return;
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await file.copy(tempPath);
      OpenFile.open(tempPath);
    } catch (e, stack) {
      AppErrorHandler.log(StringConstant.tagHistoryDetailViewModel, e, stack);
    }
  }
}

import 'dart:io';

import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/error/app_error_handler.dart';
import 'package:analysis_app/src/pages/result/controller/base_result_controller.dart';
import 'package:analysis_app/src/pages/result/model/result_args_model.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

// Manages PDF Result screen state, extends the shared base.
class PdfResultViewModel extends BaseResultController {
  String pdfPath = '';
  String originalImagePath = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as ResultArgsModel?;
    if (args == null) {
      Get.back<void>();
      return;
    }
    _initFromArgs(args);
  }

  // Parses navigation arguments and populates local state.
  void _initFromArgs(ResultArgsModel args) {
    pdfPath = args.pdfPath ?? '';
    originalImagePath = args.originalImagePath;
  }

  // Copies PDF to temp dir and opens in external viewer (fixes iOS sandbox access).
  @override
  Future<void> onActionTap() async {
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
      AppErrorHandler.log(StringConstant.tagPdfResultViewModel, e, stack);
    }
  }
}

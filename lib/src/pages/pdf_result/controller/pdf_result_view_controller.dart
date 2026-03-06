import 'dart:io';

import 'package:analysis_app/src/common/pages/result/controller/base_result_view_controller.dart';
import 'package:analysis_app/src/common/pages/result/model/result_args_model.dart';
import 'package:analysis_app/src/core/localization/locale_keys.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

// Manages PDF Result screen state, extends the shared base.
class PdfResultViewModel extends BaseResultViewModel {
  ResultArgsModel? get args => Get.arguments as ResultArgsModel?;

  @override
  String get pageTitle => LocaleKeys.pdfCreated.tr;

  @override
  String get actionButtonText => LocaleKeys.openPdf.tr;

  @override
  String get originalImagePath => args?.originalImagePath ?? '';

  // Path to the generated PDF file.
  String get pdfPath => args?.pdfPath ?? '';

  // Document title for display.
  String get documentTitle => LocaleKeys.documentTitle.tr;

  @override
  void onInit() {
    super.onInit();
    if (args == null) {
      Get.back<void>();
    }
  }

  // Copies PDF to temp dir and opens in external viewer (fixes iOS sandbox access).
  @override
  void onActionTap() async {
    if (pdfPath.isEmpty) return;
    final file = File(pdfPath);
    if (!await file.exists()) return;
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await file.copy(tempPath);
    OpenFile.open(tempPath);
  }
}

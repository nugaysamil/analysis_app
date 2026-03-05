import 'package:analysis_app/src/common/pages/result/controller/base_result_view_controller.dart';
import 'package:analysis_app/src/common/pages/result/model/result_args_model.dart';
import 'package:analysis_app/src/core/localization/locale_keys.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

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

  // Opens the generated PDF in an external viewer.
  @override
  void onActionTap() {
    if (pdfPath.isNotEmpty) {
      OpenFile.open(pdfPath);
    }
  }
}

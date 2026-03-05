import 'package:analysis_app/src/common/pages/result/controller/base_result_view_controller.dart';
import 'package:analysis_app/src/common/pages/result/model/result_args_model.dart';
import 'package:analysis_app/src/core/localization/locale_keys.dart';
import 'package:get/get.dart';

// Manages PDF Result screen state, extends the shared base.
class PdfResultViewModel extends BaseResultViewModel {
  // Retrieves navigation arguments as a typed model, null-safe.
  ResultArgsModel? get args => Get.arguments as ResultArgsModel?;

  @override
  String get pageTitle => LocaleKeys.pdfCreated.tr;

  @override
  String get actionButtonText => LocaleKeys.openPdf.tr;

  @override
  String get originalImagePath => args?.originalImagePath ?? '';

  // Document title derived from the file name.
  String get documentTitle => LocaleKeys.documentTitle.tr;

  @override
  void onInit() {
    super.onInit();
    if (args == null) {
      Get.back<void>();
    }
  }

  // Opens the generated PDF file.
  @override
  void onActionTap() {
    // TODO(pdf): Implement PDF open logic
  }
}

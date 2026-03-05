import 'package:analysis_app/src/common/pages/result/controller/base_result_view_controller.dart';
import 'package:analysis_app/src/common/pages/result/model/result_args_model.dart';
import 'package:analysis_app/src/core/localization/locale_keys.dart';
import 'package:get/get.dart';

// Manages Face Result screen state, extends the shared base.
class FaceResultViewModel extends BaseResultViewModel {
  // Retrieves navigation arguments as a typed model, null-safe.
  ResultArgsModel? get args => Get.arguments as ResultArgsModel?;

  @override
  String get pageTitle => LocaleKeys.faceResult.tr;

  @override
  String get actionButtonText => LocaleKeys.done.tr;

  @override
  String get originalImagePath => args?.originalImagePath ?? '';

  // Path of the processed (B&W) face image.
  String get processedImagePath => args?.processedImagePath ?? '';

  @override
  void onInit() {
    super.onInit();
    if (args == null) {
      Get.back<void>();
    }
  }

  // Navigates back to home after user confirms the result.
  @override
  void onActionTap() {
    Get.back<void>();
  }
}

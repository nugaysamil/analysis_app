import 'package:analysis_app/src/common/pages/processing/model/processing_args_model.dart';
import 'package:analysis_app/src/common/pages/result/model/result_args_model.dart';
import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/localization/locale_keys.dart';
import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:get/get.dart';

// Manages image processing state and progress.
class ProcessingViewModel extends GetxController {
  final RxDouble progress = 0.0.obs;
  final RxString stepDescription = ''.obs;

  // Retrieves navigation arguments as a typed model, null-safe.
  ProcessingArgsModel? get args => Get.arguments as ProcessingArgsModel?;

  @override
  void onInit() {
    super.onInit();
    if (args == null) {
      Get.back<void>();
      return;
    }
    _startProcessing();
  }

  // Simulates processing with progress updates, then navigates to result.
  Future<void> _startProcessing() async {
    stepDescription.value = args?.processingType == ProcessingType.face
        ? LocaleKeys.detectingFaces.tr
        : LocaleKeys.scanningDocument.tr;

    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      progress.value = i / 10;
    }

    _navigateToResult();
  }

  // Determines the result route based on processing type and navigates.
  void _navigateToResult() {
    final resultArgs = ResultArgsModel(
      originalImagePath: args?.imagePath ?? '',
      processingType: args?.processingType ?? ProcessingType.face,
    );

    final route = args?.processingType == ProcessingType.face
        ? AppRoutes.faceResult
        : AppRoutes.pdfResult;

    Get.offNamed<void>(route, arguments: resultArgs);
  }
}

import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:analysis_app/src/pages/batch_processing/model/batch_item_result.dart';
import 'package:analysis_app/src/pages/result/model/result_args_model.dart';
import 'package:get/get.dart';

// Manages the batch summary screen state after all images are processed.
class BatchSummaryController extends GetxController {
  List<BatchItemResult> get results =>
      (Get.arguments as List<BatchItemResult>?) ?? [];

  int get successCount => results.where((r) => r.isSuccess).length;
  int get failedCount => results.where((r) => !r.isSuccess).length;

  // Opens the individual result screen for a successful item.
  void onItemTap(BatchItemResult item) {
    if (!item.isSuccess) return;

    final resultArgs = ResultArgsModel(
      originalImagePath: item.originalPath,
      processingType: item.processingType,
      processedImagePath: item.processedImagePath,
      pdfPath: item.pdfPath,
    );

    final route = item.processingType == ProcessingType.face
        ? AppRoutes.faceResult
        : AppRoutes.pdfResult;

    Get.toNamed<void>(route, arguments: resultArgs);
  }

  void goHome() {
    Get.until((route) => route.settings.name == AppRoutes.home);
  }
}

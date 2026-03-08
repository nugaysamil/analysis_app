import 'package:analysis_app/src/core/cache/local_cache_service.dart';
import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/error/app_error_handler.dart';
import 'package:analysis_app/src/core/localization/locale_keys.dart';
import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:analysis_app/src/core/services/content_detection_service.dart';
import 'package:analysis_app/src/core/services/document_processing_service.dart';
import 'package:analysis_app/src/core/services/face_processing_service.dart';
import 'package:analysis_app/src/pages/batch_processing/model/batch_item_result.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:get/get.dart';

// Manages queue-based batch processing of multiple images with
// per-item and overall progress tracking.
class BatchProcessingController extends GetxController {
  List<String> get imagePaths => (Get.arguments as List<String>?) ?? [];

  // Overall progress.
  final RxInt currentIndex = 0.obs;
  final RxDouble itemProgress = 0.0.obs;
  final RxString stepDescription = ''.obs;
  final RxBool isComplete = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Results collected as each image finishes.
  final RxList<BatchItemResult> results = <BatchItemResult>[].obs;

  int get totalImages => imagePaths.length;
  double get overallProgress =>
      totalImages == 0 ? 0 : (currentIndex.value + itemProgress.value) / totalImages;

  ({bool isCurrent, bool isDone, bool hasFailed}) tileState(int index) {
    final isCurrent = currentIndex.value == index;
    final isDone = index < currentIndex.value || isComplete.value;
    final hasFailed =
        isDone && index < results.length && !results[index].isSuccess;

    return (isCurrent: isCurrent, isDone: isDone, hasFailed: hasFailed);
  }

  @override
  void onInit() {
    super.onInit();
    if (imagePaths.isEmpty) {
      Get.back<void>();
      return;
    }
    Future<void>.delayed(
      const Duration(milliseconds: 400),
      _processQueue,
    );
  }

  // Processes each image sequentially in FIFO order.
  Future<void> _processQueue() async {
    for (var i = 0; i < imagePaths.length; i++) {
      currentIndex.value = i;
      itemProgress.value = 0;
      stepDescription.value = LocaleKeys.processingImageOf.tr
          .replaceAll('@current', '${i + 1}')
          .replaceAll('@total', '$totalImages');

      try {
        final path = imagePaths[i];

        // Detect content type.
        final type = await ContentDetectionService.instance.detect(path);

        BatchItemResult result;
        if (type == ProcessingType.face) {
          result = await _processFace(path);
        } else {
          result = await _processDocument(path);
        }

        results.add(result);

        // Save to history.
        await _saveToHistory(result);
      } catch (e, stack) {
        AppErrorHandler.log(
          StringConstant.tagBatchProcessingViewModel,
          e,
          stack,
        );
        results.add(BatchItemResult(
          originalPath: imagePaths[i],
          processingType: ProcessingType.document,
          error: e.toString(),
        ));
      }
    }

    // All done — mark complete and navigate to summary.
    isComplete.value = true;
    stepDescription.value = LocaleKeys.batchComplete.tr;
    itemProgress.value = 0;

    await Future<void>.delayed(const Duration(milliseconds: 600));
    _navigateToSummary();
  }

  Future<BatchItemResult> _processFace(String path) async {
    final result = await FaceProcessingService.instance.process(
      path,
      onProgress: (p) => itemProgress.value = p,
    );
    return BatchItemResult(
      originalPath: path,
      processingType: ProcessingType.face,
      processedImagePath: result.processedPath,
    );
  }

  Future<BatchItemResult> _processDocument(String path) async {
    final result = await DocumentProcessingService.instance.process(
      path,
      onProgress: (p) => itemProgress.value = p,
    );
    return BatchItemResult(
      originalPath: path,
      processingType: ProcessingType.document,
      processedImagePath: result.processedImagePath,
      pdfPath: result.pdfPath,
    );
  }

  Future<void> _saveToHistory(BatchItemResult result) async {
    final item = HistoryItemModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      processingType: result.processingType,
      date: DateTime.now(),
      thumbnailPath: result.originalPath,
      processedImagePath: result.processedImagePath,
      pdfPath: result.pdfPath,
    );
    await LocalCacheService.instance.saveHistoryItem(item);
  }

  void _navigateToSummary() {
    Get.offNamed<void>(
      AppRoutes.batchSummary,
      arguments: results.toList(),
    );
  }

  void goBack() => Get.back<void>();
}

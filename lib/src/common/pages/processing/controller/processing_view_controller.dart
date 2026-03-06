import 'dart:developer';

import 'package:analysis_app/src/common/pages/processing/model/processing_args_model.dart';
import 'package:analysis_app/src/common/pages/result/model/result_args_model.dart';
import 'package:analysis_app/src/core/cache/local_cache_service.dart';
import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/localization/locale_keys.dart';
import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:analysis_app/src/core/services/document_processing_service.dart';
import 'package:analysis_app/src/core/services/face_processing_service.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:get/get.dart';

// Manages image processing state, delegates to the correct service,
// and reports live progress to the UI.
class ProcessingViewModel extends GetxController {
  final RxDouble progress = 0.0.obs;
  final RxString stepDescription = ''.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

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

  // Dispatches to the correct processing pipeline based on type.
  Future<void> _startProcessing() async {
    try {
      if (args?.processingType == ProcessingType.face) {
        await _processFace();
      } else {
        await _processDocument();
      }
    } catch (e) {
      log('Processing failed: $e', name: 'ProcessingViewModel');
      hasError.value = true;
      errorMessage.value = e.toString();
      stepDescription.value = LocaleKeys.processingError.tr;

      await Future<void>.delayed(const Duration(seconds: 3));
      Get.back<void>();
    }
  }

  // Runs the face processing pipeline with live progress updates.
  Future<void> _processFace() async {
    stepDescription.value = LocaleKeys.detectingFaces.tr;
    final result = await FaceProcessingService.instance.process(
      args!.imagePath,
      onProgress: (p) => progress.value = p,
    );

    await _saveToHistory(
      processedImagePath: result.processedPath,
    );

    _navigateToResult(processedImagePath: result.processedPath);
  }

  // Runs the document processing pipeline with live progress updates.
  Future<void> _processDocument() async {
    stepDescription.value = LocaleKeys.scanningDocument.tr;
    final result = await DocumentProcessingService.instance.process(
      args!.imagePath,
      onProgress: (p) => progress.value = p,
    );

    await _saveToHistory(
      processedImagePath: result.processedImagePath,
      pdfPath: result.pdfPath,
    );

    _navigateToResult(
      processedImagePath: result.processedImagePath,
      pdfPath: result.pdfPath,
    );
  }

  // Persists the processing result as a history entry in local cache.
  Future<void> _saveToHistory({
    String? processedImagePath,
    String? pdfPath,
  }) async {
    final item = HistoryItemModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      processingType: args!.processingType,
      date: DateTime.now(),
      thumbnailPath: args!.imagePath,
      processedImagePath: processedImagePath,
      pdfPath: pdfPath,
    );
    await LocalCacheService.instance.saveHistoryItem(item);
  }

  // Builds result args and navigates to the appropriate result screen.
  void _navigateToResult({String? processedImagePath, String? pdfPath}) {
    final resultArgs = ResultArgsModel(
      originalImagePath: args?.imagePath ?? '',
      processingType: args?.processingType ?? ProcessingType.face,
      processedImagePath: processedImagePath,
      pdfPath: pdfPath,
    );

    final route = args?.processingType == ProcessingType.face
        ? AppRoutes.faceResult
        : AppRoutes.pdfResult;

    Get.offNamed<void>(route, arguments: resultArgs);
  }
}

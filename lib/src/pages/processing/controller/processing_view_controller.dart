import 'package:analysis_app/src/core/cache/local_cache_service.dart';
import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/error/app_error_handler.dart';
import 'package:analysis_app/src/core/localization/locale_keys.dart';
import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:analysis_app/src/core/services/content_detection_service.dart';
import 'package:analysis_app/src/core/services/document_processing_service.dart';
import 'package:analysis_app/src/core/services/face_processing_service.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:analysis_app/src/pages/processing/model/processing_args_model.dart';
import 'package:analysis_app/src/pages/result/model/result_args_model.dart';
import 'package:get/get.dart';

// Manages image processing state, delegates to the correct service,
// and reports live progress to the UI.
class ProgressingViewController extends GetxController {
  final RxDouble progress = 0.0.obs;
  final RxString stepDescription = ''.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  ProcessingArgsModel? get args => Get.arguments as ProcessingArgsModel?;

  ProcessingType? _resolvedType;

  @override
  void onInit() {
    super.onInit();
    if (args == null) {
      Get.back<void>();
      return;
    }
    // Wait for the route transition animation to fully complete
    // before starting heavy ML Kit work. addPostFrameCallback alone
    // is not enough — the platform channel work blocks the main
    // isolate and freezes the transition mid-animation.
    Future<void>.delayed(const Duration(milliseconds: 400), _startProcessing);
  }

  // Detects content type (if not provided) then dispatches to the
  // correct processing pipeline.
  Future<void> _startProcessing() async {
    try {
      // If the caller already knows the type, use it; otherwise detect.
      _resolvedType = args?.processingType;
      if (_resolvedType == null) {
        stepDescription.value = LocaleKeys.detectingContent.tr;
        _resolvedType = await ContentDetectionService.instance.detect(
          args!.imagePath,
        );
      }

      if (_resolvedType == ProcessingType.face) {
        await _processFace();
      } else {
        await _processDocument();
      }
    } catch (e, stack) {
      AppErrorHandler.log(StringConstant.tagProcessingViewModel, e, stack);
      hasError.value = true;
      errorMessage.value = e.toString();
      stepDescription.value = LocaleKeys.processingError.tr;
    }
  }

  // Called by the UI back button when an error occurs.
  void goBack() => Get.back<void>();

  // Runs the face processing pipeline with live progress updates.
  Future<void> _processFace() async {
    stepDescription.value = LocaleKeys.detectingFaces.tr;
    final result = await FaceProcessingService.instance.process(
      args!.imagePath,
      onProgress: (p) => progress.value = p,
    );

    await _saveToHistory(processedImagePath: result.processedPath);
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
      processingType: _resolvedType ?? ProcessingType.face,
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
      processingType: _resolvedType ?? ProcessingType.face,
      processedImagePath: processedImagePath,
      pdfPath: pdfPath,
    );

    final route = _resolvedType == ProcessingType.face
        ? AppRoutes.faceResult
        : AppRoutes.pdfResult;

    Get.offNamed<void>(route, arguments: resultArgs);
  }
}

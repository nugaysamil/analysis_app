import 'dart:math';

import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/error/app_error_handler.dart';
import 'package:analysis_app/src/core/services/base/base_processing_service.dart';
import 'package:analysis_app/src/core/services/base/image_processing_helper.dart';
import 'package:analysis_app/src/core/services/model/face_processing_result_model.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

// Handles the full face processing pipeline:
// detect -> crop -> grayscale -> composite -> save.
class FaceProcessingService
    extends BaseProcessingService<FaceProcessingResultModel> {
  FaceProcessingService._();

  static final FaceProcessingService instance = FaceProcessingService._();

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  @override
  Future<FaceProcessingResultModel> process(
    String imagePath, {
    ProgressCallback? onProgress,
  }) async {
    try {
      // Load, decode and apply EXIF orientation correction.
      onProgress?.call(0.1);
      final original = await ImageProcessingHelper.loadImage(imagePath);
      if (original == null) {
        return FaceProcessingResultModel(
          originalPath: imagePath,
          processedPath: imagePath,
          facesDetected: 0,
        );
      }

      // Save the orientation-corrected image so ML Kit coordinates
      // match the decoded pixel data exactly.
      final bakedPath = await ImageProcessingHelper.saveTempBaked(original);

      // Run ML Kit face detection on the corrected image.
      onProgress?.call(0.25);
      final inputImage = InputImage.fromFilePath(bakedPath);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return FaceProcessingResultModel(
          originalPath: imagePath,
          processedPath: imagePath,
          facesDetected: 0,
        );
      }

      // Apply grayscale filter to each detected face region.
      onProgress?.call(0.5);
      final composite = img.Image.from(original);

      for (final face in faces) {
        final rect = face.boundingBox;

        // Clamp coordinates to image bounds.
        final x = max(0, rect.left.toInt());
        final y = max(0, rect.top.toInt());
        final w = min(rect.width.toInt(), composite.width - x);
        final h = min(rect.height.toInt(), composite.height - y);

        if (w <= 0 || h <= 0) continue;

        final faceCrop =
            img.copyCrop(composite, x: x, y: y, width: w, height: h);
        final grayscaleFace = img.grayscale(faceCrop);

        img.compositeImage(composite, grayscaleFace, dstX: x, dstY: y);
      }

      // Encode and save the composite result as JPEG.
      onProgress?.call(0.85);
      final outputPath = await ImageProcessingHelper.saveImage(
        composite,
        prefix: 'face_result',
      );

      // Processing complete.
      onProgress?.call(1.0);

      return FaceProcessingResultModel(
        originalPath: imagePath,
        processedPath: outputPath,
        facesDetected: faces.length,
      );
    } catch (e, stack) {
      AppErrorHandler.log(StringConstant.tagFaceProcessingService, e, stack);
      rethrow;
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
  }
}

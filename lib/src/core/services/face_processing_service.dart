import 'dart:io';
import 'dart:math';

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
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  @override
  Future<FaceProcessingResultModel> process(
    String imagePath, {
    ProgressCallback? onProgress,
  }) async {
    // Load and decode the source image from disk.
    onProgress?.call(0.1);
    final original = await ImageProcessingHelper.loadImage(imagePath);

    // Run ML Kit face detection on the input image.
    onProgress?.call(0.25);
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) throw Exception('No faces detected');

    // Apply grayscale filter to each detected face region.
    onProgress?.call(0.5);
    final composite = img.Image.from(original);

    // Scale factor between ML Kit coordinate space and actual image pixels.
    final imageFile = File(imagePath);
    final decodedForSize = img.decodeImage(await imageFile.readAsBytes());
    final scaleX = decodedForSize!.width / decodedForSize.width;
    final scaleY = decodedForSize.height / decodedForSize.height;

    for (final face in faces) {
      final rect = face.boundingBox;

      // Clamp coordinates to image bounds.
      final x = max(0, (rect.left * scaleX).toInt());
      final y = max(0, (rect.top * scaleY).toInt());
      final w = min((rect.width * scaleX).toInt(), composite.width - x);
      final h = min((rect.height * scaleY).toInt(), composite.height - y);

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
  }

  @override
  void dispose() {
    _faceDetector.close();
  }
}

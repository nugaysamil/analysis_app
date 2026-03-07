import 'dart:developer' as dev;

import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/error/app_error_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Analyzes an image to determine whether it contains faces or documents.
// Uses ML Kit Face Detection and Text Recognition under the hood.
class ContentDetectionService {
  ContentDetectionService._();

  static final ContentDetectionService instance = ContentDetectionService._();

  // Fast mode without landmarks for quicker, more tolerant detection.
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  final TextRecognizer _textRecognizer = TextRecognizer();

  // Minimum character count to consider an image as a document.
  static const int _minDocumentTextLength = 20;

  // Detects content type by running face and text detection in parallel.
  // Prioritizes face detection; falls back to document only if
  // meaningful amount of text is found.
  Future<ProcessingType> detect(String imagePath) async {
    final stopwatch = Stopwatch()..start();
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      final results = await Future.wait([
        _faceDetector.processImage(inputImage),
        _textRecognizer.processImage(inputImage),
      ]);

      final faces = results[0] as List<Face>;
      final recognizedText = results[1] as RecognizedText;

      stopwatch.stop();
      final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;

      if (faces.isNotEmpty) {
        dev.log(
          'Content detection completed in ${elapsedSeconds.toStringAsFixed(2)}s -> face (${faces.length} face(s) found)',
          name: StringConstant.tagContentDetectionService,
        );
        return ProcessingType.face;
      }
      if (recognizedText.text.trim().length >= _minDocumentTextLength) {
        dev.log(
          'Content detection completed in ${elapsedSeconds.toStringAsFixed(2)}s -> document (${recognizedText.text.trim().length} chars found)',
          name: StringConstant.tagContentDetectionService,
        );
        return ProcessingType.document;
      }

      dev.log(
        'Content detection completed in ${elapsedSeconds.toStringAsFixed(2)}s -> fallback to face (no significant content)',
        name: StringConstant.tagContentDetectionService,
      );
    } catch (e, stack) {
      stopwatch.stop();
      dev.log(
        'Content detection failed after ${(stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2)}s',
        name: StringConstant.tagContentDetectionService,
      );
      AppErrorHandler.log(StringConstant.tagContentDetectionService, e, stack);
    }

    return ProcessingType.face;
  }

  // Releases ML Kit resources when no longer needed.
  Future<void> dispose() async {
    _faceDetector.close();
    _textRecognizer.close();
  }
}

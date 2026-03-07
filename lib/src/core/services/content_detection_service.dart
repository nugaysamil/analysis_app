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
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      final results = await Future.wait([
        _faceDetector.processImage(inputImage),
        _textRecognizer.processImage(inputImage),
      ]);

      final faces = results[0] as List<Face>;
      final recognizedText = results[1] as RecognizedText;

      if (faces.isNotEmpty) return ProcessingType.face;
      if (recognizedText.text.trim().length >= _minDocumentTextLength) {
        return ProcessingType.document;
      }
    } catch (e, stack) {
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

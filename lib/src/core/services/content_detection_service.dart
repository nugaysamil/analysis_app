import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Analyzes an image to determine whether it contains faces or documents.
// Uses ML Kit Face Detection and Text Recognition under the hood.
class ContentDetectionService {
  ContentDetectionService._();

  static final ContentDetectionService instance = ContentDetectionService._();

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  final TextRecognizer _textRecognizer = TextRecognizer();

  // Detects content type by running face and text detection in parallel.
  // Prioritizes face detection; falls back to document if text is found.
  Future<ProcessingType> detect(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    final results = await Future.wait([
      _faceDetector.processImage(inputImage),
      _textRecognizer.processImage(inputImage),
    ]);

    final faces = results[0] as List<Face>;
    final recognizedText = results[1] as RecognizedText;

    if (faces.isNotEmpty) return ProcessingType.face;
    if (recognizedText.text.trim().isNotEmpty) return ProcessingType.document;

    // Default to face if nothing detected (user can re-pick).
    return ProcessingType.face;
  }

  // Releases ML Kit resources when no longer needed.
  Future<void> dispose() async {
    _faceDetector.close();
    _textRecognizer.close();
  }
}

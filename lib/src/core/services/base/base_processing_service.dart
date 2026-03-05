import 'package:analysis_app/src/core/services/base/image_processing_helper.dart';

// Abstract contract for all image processing services.
// [T] represents the result model type returned after processing.
abstract class BaseProcessingService<T> {
  // Runs the full processing pipeline on the given image.
  Future<T> process(
    String imagePath, {
    ProgressCallback? onProgress,
  });

  // Releases ML Kit resources held by the service.
  void dispose();
}

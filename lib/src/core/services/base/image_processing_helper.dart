import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(double progress);

// Shared utility for common image processing operations
// used by both FaceProcessingService and DocumentProcessingService.
class ImageProcessingHelper {
  ImageProcessingHelper._();

  // Reads the file bytes, decodes to an img.Image instance,
  // and applies EXIF orientation so pixel data matches the visual orientation.
  // Returns null if the image cannot be decoded.
  static Future<img.Image?> loadImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    return img.bakeOrientation(decoded);
  }

  // Saves the baked (EXIF-corrected) image to a temp file so ML Kit
  // reads pixel data in the same orientation as the decoded image.
  static Future<String> saveTempBaked(img.Image image) async {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/temp_baked.jpg';
        await File(path).writeAsBytes(img.encodeJpg(image, quality: 95));
        return path;
  }

  // Encodes the image as JPEG and saves to the app documents directory.
  static Future<String> saveImage(
    img.Image image, {
    required String prefix,
    int quality = 90,
  }) async {
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${dir.path}/${prefix}_$timestamp.jpg';
        await File(path).writeAsBytes(img.encodeJpg(image, quality: quality));
        return path;
  }

  // Returns the app documents directory path.
  static Future<String> getOutputDirectory() async {
        final dir = await getApplicationDocumentsDirectory();
        return dir.path;
  }
}

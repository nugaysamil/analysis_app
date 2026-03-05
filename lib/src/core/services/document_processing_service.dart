import 'dart:io';

import 'package:analysis_app/src/core/services/base/base_processing_service.dart';
import 'package:analysis_app/src/core/services/base/image_processing_helper.dart';
import 'package:analysis_app/src/core/services/model/document_processing_result_model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Handles the full document processing pipeline:
// text recognition -> contrast enhance -> crop -> PDF export.
class DocumentProcessingService
    extends BaseProcessingService<DocumentProcessingResultModel> {
  DocumentProcessingService._();

  static final DocumentProcessingService instance =
      DocumentProcessingService._();

  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  Future<DocumentProcessingResultModel> process(
    String imagePath, {
    ProgressCallback? onProgress,
  }) async {
    // Load and decode the source image from disk.
    onProgress?.call(0.1);
    final original = await ImageProcessingHelper.loadImage(imagePath);

    // Run ML Kit text recognition (OCR) on the input image.
    onProgress?.call(0.2);
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    // Detect document boundaries from text blocks and crop.
    onProgress?.call(0.4);
    final cropped = _detectAndCropDocument(original, recognizedText);

    // Enhance contrast and brightness for better readability.
    onProgress?.call(0.6);
    final enhanced = _enhanceContrast(cropped);

    // Encode and save the processed image as JPEG.
    onProgress?.call(0.75);
    final processedPath = await ImageProcessingHelper.saveImage(
      enhanced,
      prefix: 'doc_processed',
      quality: 95,
    );

    // Generate a PDF containing the processed image and recognized text.
    onProgress?.call(0.9);
    final dirPath = await ImageProcessingHelper.getOutputDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final pdfPath = await _generatePdf(
      processedPath,
      recognizedText.text,
      dirPath,
      timestamp,
    );

    // Processing complete.
    onProgress?.call(1.0);

    return DocumentProcessingResultModel(
      originalPath: imagePath,
      processedImagePath: processedPath,
      pdfPath: pdfPath,
      recognizedText: recognizedText.text,
    );
  }

  // Crops the image to text region boundaries if text blocks are found.
  img.Image _detectAndCropDocument(
    img.Image image,
    RecognizedText recognizedText,
  ) {
    if (recognizedText.blocks.isEmpty) return image;

    var minX = image.width;
    var minY = image.height;
    var maxX = 0;
    var maxY = 0;

    for (final block in recognizedText.blocks) {
      final rect = block.boundingBox;
      if (rect.left < minX) minX = rect.left.toInt();
      if (rect.top < minY) minY = rect.top.toInt();
      if (rect.right > maxX) maxX = rect.right.toInt();
      if (rect.bottom > maxY) maxY = rect.bottom.toInt();
    }

    // Add padding around the detected text area.
    const padding = 40;
    minX = (minX - padding).clamp(0, image.width);
    minY = (minY - padding).clamp(0, image.height);
    maxX = (maxX + padding).clamp(0, image.width);
    maxY = (maxY + padding).clamp(0, image.height);

    final w = maxX - minX;
    final h = maxY - minY;

    if (w <= 0 || h <= 0) return image;

    return img.copyCrop(image, x: minX, y: minY, width: w, height: h);
  }

  // Applies contrast enhancement and slight brightness boost for readability.
  img.Image _enhanceContrast(img.Image image) {
    var result = img.adjustColor(image, contrast: 1.3);
    result = img.adjustColor(result, brightness: 1.05);
    return result;
  }

  // Generates a PDF with the processed image and recognized text.
  Future<String> _generatePdf(
    String processedImagePath,
    String text,
    String dirPath,
    int timestamp,
  ) async {
    final pdf = pw.Document();
    final imageBytes = await File(processedImagePath).readAsBytes();
    final pdfImage = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Image(pdfImage, fit: pw.BoxFit.fitWidth),
          pw.SizedBox(height: 20),
          if (text.isNotEmpty)
            pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 12),
            ),
        ],
      ),
    );

    final pdfPath = '$dirPath/document_$timestamp.pdf';
    await File(pdfPath).writeAsBytes(await pdf.save());
    return pdfPath;
  }

  @override
  void dispose() {
    _textRecognizer.close();
  }
}

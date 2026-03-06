import 'dart:developer';
import 'dart:io';

import 'package:analysis_app/src/core/services/base/base_processing_service.dart';
import 'package:analysis_app/src/core/services/base/image_processing_helper.dart';
import 'package:analysis_app/src/core/services/model/document_processing_result_model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
    // Load, decode and apply EXIF orientation correction.
    onProgress?.call(0.1);
    final original = await ImageProcessingHelper.loadImage(imagePath);

    // Prepare OCR-optimized image: grayscale + sharpen + high contrast
    // so ML Kit reads characters more accurately.
    onProgress?.call(0.15);
    final ocrImage = _prepareForOcr(original);
    final ocrPath = await ImageProcessingHelper.saveTempBaked(ocrImage);

    // Run ML Kit text recognition (OCR) on the optimized image.
    onProgress?.call(0.3);
    final inputImage = InputImage.fromFilePath(ocrPath);
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
    final normalizedText = _normalizeOcrText(recognizedText.text);
    final pdfPath = await _generatePdf(
      processedPath,
      normalizedText,
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

  // Converts image to grayscale, sharpens, and boosts contrast
  // to maximize ML Kit text recognition accuracy.
  img.Image _prepareForOcr(img.Image image) {
    var result = img.grayscale(image);
    result = img.adjustColor(result, contrast: 1.5, brightness: 1.1);
    return result;
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

    // Page 1: image only (full page, scaled to fit — avoids overflow).
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) =>
            pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain)),
      ),
    );

    // Load Roboto font for Turkish character support.
    pw.TextStyle textStyle = const pw.TextStyle(fontSize: 12);
    try {
      final font = await PdfGoogleFonts.robotoRegular();
      textStyle = pw.TextStyle(font: font, fontSize: 12);
    } catch (_) {
      // Use default font if Google Font fails.
    }

    // Page 2+: OCR text as paragraphs.
    if (text.isNotEmpty) {
      try {
        // Split by double newline (paragraphs), then by length.
        const maxChunkLength = 400;
        final paragraphs = text.split(RegExp(r'\n\n+'));
        final textWidgets = <pw.Widget>[];

        for (var p = 0; p < paragraphs.length; p++) {
          final para = paragraphs[p].trim();
          if (para.isEmpty) continue;

          if (p > 0) textWidgets.add(pw.SizedBox(height: 10));

          if (para.length <= maxChunkLength) {
            textWidgets.add(pw.Text(para, style: textStyle));
          } else {
            for (var i = 0; i < para.length; i += maxChunkLength) {
              final end = (i + maxChunkLength).clamp(0, para.length);
              if (end > i) {
                textWidgets.add(
                  pw.Text(para.substring(i, end), style: textStyle),
                );
              }
            }
          }
        }

        if (textWidgets.isNotEmpty) {
          pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              build: (context) => textWidgets,
            ),
          );
        }
      } catch (_) {
        // Skip text if rendering fails.
      }
    }

    final pdfPath = '$dirPath/document_$timestamp.pdf';
    final bytes = await pdf.save();
    await File(pdfPath).writeAsBytes(bytes);
    log(
      'PDF written: $pdfPath, size: ${bytes.length} bytes, '
      'image: ${imageBytes.length} bytes, text length: ${text.length}',
      name: 'DocumentProcessing',
    );
    return pdfPath;
  }

  // Normalizes OCR output: collapse extra whitespace, join broken lines
  // within the same paragraph while preserving actual paragraph breaks.
  String _normalizeOcrText(String text) {
    if (text.trim().isEmpty) return text;

    final lines = text
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
        .toList();

    const sentenceEnds = '.!?:';
    final paragraphs = <String>[];
    var current = '';

    for (final line in lines) {
      if (line.isEmpty) {
        if (current.isNotEmpty) {
          paragraphs.add(current);
          current = '';
        }
        continue;
      }

      if (current.isEmpty) {
        current = line;
      } else {
        final endsWithSentence = sentenceEnds.contains(
          current[current.length - 1],
        );
        if (endsWithSentence) {
          paragraphs.add(current);
          current = line;
        } else {
          current = '$current $line';
        }
      }
    }
    if (current.isNotEmpty) paragraphs.add(current);

    return paragraphs.join('\n\n');
  }

  @override
  void dispose() {
    _textRecognizer.close();
  }
}

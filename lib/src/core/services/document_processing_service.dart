import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/error/app_error_handler.dart';
import 'package:analysis_app/src/core/services/base/base_processing_service.dart';
import 'package:analysis_app/src/core/services/base/image_processing_helper.dart';
import 'package:analysis_app/src/core/services/model/document_processing_result_model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_pdf/pdf.dart';

// Handles the full document processing pipeline:
// text recognition -> contrast enhance -> crop -> PDF export.
class DocumentProcessingService
    extends BaseProcessingService<DocumentProcessingResultModel> {
  DocumentProcessingService._();

  static final DocumentProcessingService instance =
      DocumentProcessingService._();

  final TextRecognizer _textRecognizer = TextRecognizer();
  List<int>? _cachedFontBytes;

  @override
  Future<DocumentProcessingResultModel> process(
    String imagePath, {
    ProgressCallback? onProgress,
  }) async {
    // Load, decode and apply EXIF orientation correction.
    onProgress?.call(0.1);
    await Future<void>.delayed(Duration.zero);
    final loaded = await ImageProcessingHelper.loadImage(imagePath);
    if (loaded == null) {
      return DocumentProcessingResultModel(
        originalPath: imagePath,
        processedImagePath: imagePath,
        pdfPath: '',
        recognizedText: '',
      );
    }

    // Downscale large originals so every subsequent operation (perspective
    // correction, contrast enhance, JPEG encode) runs on a bounded canvas.
    final original = _capResolution(loaded, 2500);

    // Prepare a smaller OCR-optimized copy — filters are O(px) so capping
    // at 1400px makes gaussianBlur + convolution ~6-18× faster.
    onProgress?.call(0.15);
    final ocrImage = _prepareForOcr(img.Image.from(original));
    final ocrPath = await ImageProcessingHelper.saveTempBaked(ocrImage);

    // Run ML Kit text recognition (OCR) on the optimized image.
    onProgress?.call(0.3);
    await Future<void>.delayed(Duration.zero);
    final inputImage = InputImage.fromFilePath(ocrPath);
    var recognizedText = await _textRecognizer.processImage(inputImage);

    // Fallback: if the preprocessed image yielded no text, retry on the
    // original file directly — no extra disk write needed.
    if (recognizedText.text.trim().isEmpty) {
      recognizedText = await _textRecognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
    }

    // Detect document boundaries from text blocks and crop.
    onProgress?.call(0.4);
    final cropped = _detectAndCropDocument(
      original,
      recognizedText,
      ocrWidth: ocrImage.width,
      ocrHeight: ocrImage.height,
    );

    // Enhance contrast and brightness for better readability.
    onProgress?.call(0.6);
    final enhanced = _enhanceContrast(cropped);

    // Encode and save the processed image as JPEG.
    onProgress?.call(0.75);
    final processedPath = await ImageProcessingHelper.saveImage(
      enhanced,
      prefix: StringConstant.docProcessedPrefix,
      quality: 85,
    );

    // Generate a PDF containing the processed image and recognized text.
    onProgress?.call(0.9);
    await Future<void>.delayed(Duration.zero);
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

  // Clamps the longest side of [image] to [maxSide] using linear
  // interpolation. Returns the original if already within bounds.
  img.Image _capResolution(img.Image image, int maxSide) {
    final longer = math.max(image.width, image.height);
    if (longer <= maxSide) return image;
    final scale = maxSide / longer;
    return img.copyResize(
      image,
      width: (image.width * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  }

  // Converts image to grayscale, denoises, sharpens, and boosts contrast
  // to maximize ML Kit text recognition accuracy.
  img.Image _prepareForOcr(img.Image image) {
    var result = image;

    // 1. Resize to OCR-optimal window: downsample large images to cap
    //    expensive per-pixel filter work; upsample very small ones.
    final longer = math.max(result.width, result.height);
    final shorter = math.min(result.width, result.height);
    if (longer > StringConstant.maxOcrDim) {
      result = _capResolution(result, StringConstant.maxOcrDim);
    } else if (shorter < StringConstant.minOcrDim) {
      final scale = StringConstant.minOcrDim / shorter;
      result = img.copyResize(
        result,
        width: (result.width * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }

    // 2. Grayscale — removes colour noise.
    result = img.grayscale(result);

    // 3. Light Gaussian blur — smooths sensor noise and JPEG artefacts
    //    that can be mistaken for character strokes.
    result = img.gaussianBlur(result, radius: 1);

    // 4. Sharpen — restores and enhances text edges after the blur.
    result = img.convolution(
      result,
      filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
      div: 1,
    );

    // 5. High contrast + slight brightness lift — pushes text toward
    //    pure black on white, reducing ambiguous grey strokes.
    result = img.adjustColor(result, contrast: 1.8, brightness: 1.05);

    // 6. Normalize — stretches the histogram so the darkest pixel is 0
    //    and the brightest is 255, maximizing dynamic range for OCR.
    result = img.normalize(result, min: 0, max: 255);

    return result;
  }

  // Detects the paper/document region primarily using OCR cornerPoints to find
  // the 4 corners of the A4 paper, then applies perspective correction.
  // Falls back to luminance analysis or axis-aligned OCR bounding box crop.
  img.Image _detectAndCropDocument(
    img.Image image,
    RecognizedText recognizedText, {
    required int ocrWidth,
    required int ocrHeight,
  }) {
    const tag = StringConstant.tagDocumentProcessingService;

    // Step 1: Try OCR corner-point-based detection.
    // Collects all cornerPoints from text blocks/lines, builds a convex hull,
    // finds the 4 document corners, and applies perspective correction.
    final corners = _findDocumentCornersFromOcr(
      image,
      recognizedText,
      ocrWidth: ocrWidth,
      ocrHeight: ocrHeight,
    );

    if (corners != null) {
      return _perspectiveCorrect(image, corners);
    }

    // Step 2: Fallback — luminance-based paper detection + axis-aligned crop.
    final paperBounds = _detectPaperBounds(image);
    if (paperBounds != null) {
      final minX = paperBounds[0];
      final minY = paperBounds[1];
      final maxX = paperBounds[2];
      final maxY = paperBounds[3];
      final w = maxX - minX;
      final h = maxY - minY;
      if (w > 0 && h > 0) {
        log('Luminance crop: ($minX,$minY) ${w}x$h', name: tag);
        return img.copyCrop(image, x: minX, y: minY, width: w, height: h);
      }
    }

    // Step 3: Fallback — crop to OCR text bounding box with padding.
    if (recognizedText.blocks.isNotEmpty) {
      final scaleX = image.width / ocrWidth;
      final scaleY = image.height / ocrHeight;
      int textMinX = image.width, textMinY = image.height;
      int textMaxX = 0, textMaxY = 0;
      for (final block in recognizedText.blocks) {
        final r = block.boundingBox;
        final l = (r.left * scaleX).toInt();
        final t = (r.top * scaleY).toInt();
        final ri = (r.right * scaleX).toInt();
        final b = (r.bottom * scaleY).toInt();
        if (l < textMinX) textMinX = l;
        if (t < textMinY) textMinY = t;
        if (ri > textMaxX) textMaxX = ri;
        if (b > textMaxY) textMaxY = b;
      }
      const padding = 40;
      textMinX = (textMinX - padding).clamp(0, image.width);
      textMinY = (textMinY - padding).clamp(0, image.height);
      textMaxX = (textMaxX + padding).clamp(0, image.width);
      textMaxY = (textMaxY + padding).clamp(0, image.height);
      final w = textMaxX - textMinX;
      final h = textMaxY - textMinY;
      if (w > 0 && h > 0) {
        return img.copyCrop(
          image,
          x: textMinX,
          y: textMinY,
          width: w,
          height: h,
        );
      }
    }
    return image;
  }

  // Collects all cornerPoints from OCR blocks and lines, computes convex hull,
  // finds the 4 extreme corners, and expands outward to approximate paper edges.
  // Returns [topLeft, topRight, bottomRight, bottomLeft] or null.
  List<math.Point<int>>? _findDocumentCornersFromOcr(
    img.Image image,
    RecognizedText recognizedText, {
    required int ocrWidth,
    required int ocrHeight,
  }) {
    if (recognizedText.blocks.isEmpty) return null;

    final scaleX = image.width / ocrWidth;
    final scaleY = image.height / ocrHeight;

    // Collect ALL corner points from blocks AND lines for maximum coverage.
    final allPoints = <math.Point<int>>[];
    for (final block in recognizedText.blocks) {
      for (final cp in block.cornerPoints) {
        allPoints.add(
          math.Point<int>((cp.x * scaleX).round(), (cp.y * scaleY).round()),
        );
      }
      for (final line in block.lines) {
        for (final cp in line.cornerPoints) {
          allPoints.add(
            math.Point<int>((cp.x * scaleX).round(), (cp.y * scaleY).round()),
          );
        }
      }
    }

    if (allPoints.length < 4) return null;

    // Compute convex hull to get the outermost boundary of all text.
    final hull = _convexHull(allPoints);
    if (hull.length < 4) return null;

    // Find the 4 extreme corners of the convex hull.
    final quad = _findQuadCorners(hull);
    final expanded = _expandQuadrilateral(quad, image, 0.12);
    return expanded;
  }

  // Andrew's monotone chain convex hull algorithm — O(n log n).
  // Returns hull vertices in counter-clockwise order.
  List<math.Point<int>> _convexHull(List<math.Point<int>> points) {
    final pts = List<math.Point<int>>.from(points);
    pts.sort((a, b) => a.x != b.x ? a.x.compareTo(b.x) : a.y.compareTo(b.y));

    if (pts.length <= 1) return pts;

    // Build lower hull.
    final lower = <math.Point<int>>[];
    for (final p in pts) {
      while (lower.length >= 2 &&
          _cross(lower[lower.length - 2], lower[lower.length - 1], p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    // Build upper hull.
    final upper = <math.Point<int>>[];
    for (final p in pts.reversed) {
      while (upper.length >= 2 &&
          _cross(upper[upper.length - 2], upper[upper.length - 1], p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    // Remove last point of each half because it is repeated.
    lower.removeLast();
    upper.removeLast();

    return [...lower, ...upper];
  }

  // Cross product of vectors OA and OB — used by convex hull.
  int _cross(math.Point<int> o, math.Point<int> a, math.Point<int> b) {
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
  }

  // Finds the 4 extreme corners of a convex hull using sum/difference heuristic:
  //   top-left     = min(x + y)
  //   top-right    = max(x − y)
  //   bottom-right = max(x + y)
  //   bottom-left  = min(x − y)
  // Returns [topLeft, topRight, bottomRight, bottomLeft].
  List<math.Point<int>> _findQuadCorners(List<math.Point<int>> hull) {
    var topLeft = hull[0];
    var topRight = hull[0];
    var bottomRight = hull[0];
    var bottomLeft = hull[0];

    int minSum = topLeft.x + topLeft.y;
    int maxSum = bottomRight.x + bottomRight.y;
    int maxDiff = topRight.x - topRight.y;
    int minDiff = bottomLeft.x - bottomLeft.y;

    for (final p in hull) {
      final sum = p.x + p.y;
      final diff = p.x - p.y;
      if (sum < minSum) {
        minSum = sum;
        topLeft = p;
      }
      if (sum > maxSum) {
        maxSum = sum;
        bottomRight = p;
      }
      if (diff > maxDiff) {
        maxDiff = diff;
        topRight = p;
      }
      if (diff < minDiff) {
        minDiff = diff;
        bottomLeft = p;
      }
    }

    return [topLeft, topRight, bottomRight, bottomLeft];
  }

  // Expands a quadrilateral outward from its centroid by [ratio] (e.g. 0.12).
  // Clamps corners to image boundaries.
  List<math.Point<int>> _expandQuadrilateral(
    List<math.Point<int>> corners,
    img.Image image,
    double ratio,
  ) {
    final cx = corners.map((p) => p.x).reduce((a, b) => a + b) / corners.length;
    final cy = corners.map((p) => p.y).reduce((a, b) => a + b) / corners.length;

    return corners.map((p) {
      final dx = p.x - cx;
      final dy = p.y - cy;
      final newX = (cx + dx * (1 + ratio)).round().clamp(0, image.width - 1);
      final newY = (cy + dy * (1 + ratio)).round().clamp(0, image.height - 1);
      return math.Point<int>(newX, newY);
    }).toList();
  }

  // Applies perspective correction using the 4 document corners.
  // Maps the quadrilateral to a rectangle whose dimensions are derived
  // from the longest opposite-edge pair.
  img.Image _perspectiveCorrect(
    img.Image image,
    List<math.Point<int>> corners,
  ) {
    final tl = corners[0]; // top-left
    final tr = corners[1]; // top-right
    final br = corners[2]; // bottom-right
    final bl = corners[3]; // bottom-left

    // Output dimensions = max of opposite edge lengths.
    final outWidth = math.max(_distance(tl, tr), _distance(bl, br)).round();
    final outHeight = math.max(_distance(tl, bl), _distance(tr, br)).round();

    final dest = img.Image(width: outWidth, height: outHeight);

    return img.copyRectify(
      image,
      topLeft: img.Point(tl.x, tl.y),
      topRight: img.Point(tr.x, tr.y),
      bottomLeft: img.Point(bl.x, bl.y),
      bottomRight: img.Point(br.x, br.y),
      interpolation: img.Interpolation.linear,
      toImage: dest,
    );
  }

  // Euclidean distance between two points.
  double _distance(math.Point<int> a, math.Point<int> b) {
    final dx = (a.x - b.x).toDouble();
    final dy = (a.y - b.y).toDouble();
    return math.sqrt(dx * dx + dy * dy);
  }

  // Detects paper boundaries using corner-reference pixel classification.
  // Samples background brightness from image corners, paper brightness from
  // the center region, then classifies each pixel by proximity to decide
  // paper vs background. Returns [minX, minY, maxX, maxY] in original
  // image coordinates, or null if detection fails.
  List<int>? _detectPaperBounds(img.Image image) {
    const scaleFactor = 4;
    final smallW = math.max(20, image.width ~/ scaleFactor);
    final small = img.copyResize(image, width: smallW);
    final gray = img.grayscale(small);

    final w = gray.width;
    final h = gray.height;
    if (w < 20 || h < 20) return null;

    // Build 2D brightness array for fast repeated access.
    final lum = List.generate(
      h,
      (y) => List.generate(w, (x) => gray.getPixel(x, y).r.toInt()),
    );

    // --- Sample background brightness from the 4 corners (5x5 patches). ---
    final bgSamples = <int>[];
    const cs = 5;
    for (var dy = 0; dy < cs && dy < h; dy++) {
      for (var dx = 0; dx < cs && dx < w; dx++) {
        bgSamples.addAll([
          lum[dy][dx],
          lum[dy][w - 1 - dx],
          lum[h - 1 - dy][dx],
          lum[h - 1 - dy][w - 1 - dx],
        ]);
      }
    }
    bgSamples.sort();
    final bgMedian = bgSamples[bgSamples.length ~/ 2].toDouble();

    // --- Sample paper brightness from the center third of the image. ---
    double centerSum = 0;
    int centerCount = 0;
    final cy1 = h ~/ 3, cy2 = 2 * h ~/ 3;
    final cx1 = w ~/ 3, cx2 = 2 * w ~/ 3;
    for (var y = cy1; y < cy2; y++) {
      for (var x = cx1; x < cx2; x++) {
        centerSum += lum[y][x];
        centerCount++;
      }
    }
    if (centerCount == 0) return null;
    final paperMean = centerSum / centerCount;
    final contrast = (paperMean - bgMedian).abs();
    if (contrast < 15) return null;

    // --- Classify every pixel as "paper" or "background". ---
    // A pixel is "paper" when it is closer to paperMean than to bgMedian.
    final rowPaper = List<int>.filled(h, 0);
    final colPaper = List<int>.filled(w, 0);

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final val = lum[y][x].toDouble();
        if ((val - paperMean).abs() < (val - bgMedian).abs()) {
          rowPaper[y]++;
          colPaper[x]++;
        }
      }
    }

    // A row/column is "paper" when > 55 % of its pixels are paper-like.
    final rowThresh = (w * 0.55).toInt();
    final colThresh = (h * 0.55).toInt();

    // --- Pass 1: initial scan with 55 % threshold. ---
    int top = 0, bottom = h - 1, left = 0, right = w - 1;

    for (var y = 0; y < h ~/ 2; y++) {
      if (rowPaper[y] >= rowThresh) {
        top = y;
        break;
      }
    }
    for (var y = h - 1; y > h ~/ 2; y--) {
      if (rowPaper[y] >= rowThresh) {
        bottom = y;
        break;
      }
    }
    for (var x = 0; x < w ~/ 2; x++) {
      if (colPaper[x] >= colThresh) {
        left = x;
        break;
      }
    }
    for (var x = w - 1; x > w ~/ 2; x--) {
      if (colPaper[x] >= colThresh) {
        right = x;
        break;
      }
    }

    // Pass 2: gradient refinement near each boundary.
    const neighbourhood = 30;
    top = _refineEdge(rowPaper, top, neighbourhood, w, forward: true);
    bottom = _refineEdge(rowPaper, bottom, neighbourhood, w, forward: false);
    left = _refineEdge(colPaper, left, neighbourhood, h, forward: true);
    right = _refineEdge(colPaper, right, neighbourhood, h, forward: false);

    if (top >= bottom || left >= right) {
      return null;
    }

    // If the detected region covers essentially the whole image, skip crop.
    if ((right - left) >= w - 4 && (bottom - top) >= h - 4) {
      return null;
    }

    // Small padding so we don't clip paper edges.
    const pad = 2;
    top = math.max(0, top - pad);
    bottom = math.min(h - 1, bottom + pad);
    left = math.max(0, left - pad);
    right = math.min(w - 1, right + pad);

    // Scale back to original image coordinates.
    final scaleX = image.width / w;
    final scaleY = image.height / h;

    final result = [
      (left * scaleX).toInt(),
      (top * scaleY).toInt(),
      ((right + 1) * scaleX).toInt().clamp(0, image.width),
      ((bottom + 1) * scaleY).toInt().clamp(0, image.height),
    ];
    return result;
  }

  // Refines a boundary index by looking for the biggest gradient (drop)
  // in the paper-pixel [profile] within [neighbourhood] of [initial].
  int _refineEdge(
    List<int> profile,
    int initial,
    int neighbourhood,
    int total, {
    required bool forward,
  }) {
    final n = profile.length;
    // Search window around the initial boundary.
    final lo = math.max(0, initial - neighbourhood);
    final hi = math.min(n - 1, initial + neighbourhood);

    int bestIdx = initial;
    int bestDrop = 0;

    if (forward) {
      // Looking for a big upward jump (bg → paper) scanning lo→hi.
      for (var i = lo; i < hi; i++) {
        final drop = profile[i + 1] - profile[i];
        if (drop > bestDrop) {
          bestDrop = drop;
          bestIdx = i + 1;
        }
      }
    } else {
      // Looking for a big downward jump (paper → bg) scanning hi→lo.
      for (var i = hi; i > lo; i--) {
        final drop = profile[i - 1] - profile[i];
        if (drop > bestDrop) {
          bestDrop = drop;
          bestIdx = i - 1;
        }
      }
    }

    // Only use the refined position if the gradient is significant
    // (at least 15 % of the total width/height).
    if (bestDrop > total * 0.15) {
      return bestIdx;
    }
    return initial;
  }

  // Applies contrast enhancement and slight brightness boost for readability.
  img.Image _enhanceContrast(img.Image image) {
    return img.adjustColor(image, contrast: 1.3, brightness: 1.05);
  }

  // Generates a searchable PDF with the processed image and recognized text
  // using Syncfusion PDF. Text is embedded as real text content, enabling
  // find/search within the PDF.
  Future<String> _generatePdf(
    String processedImagePath,
    String text,
    String dirPath,
    int timestamp,
  ) async {
    final document = PdfDocument();
    final imageBytes = await File(processedImagePath).readAsBytes();

    // Page 1: processed image (full A4 page, centered and scaled to fit).
    final page1 = document.pages.add();
    final pageSize = page1.getClientSize();
    final bitmap = PdfBitmap(imageBytes);

    // Scale image to fit within page maintaining aspect ratio.
    final imgAspect = bitmap.width / bitmap.height;
    final pageAspect = pageSize.width / pageSize.height;
    double drawW, drawH, drawX, drawY;
    if (imgAspect > pageAspect) {
      drawW = pageSize.width;
      drawH = drawW / imgAspect;
      drawX = 0;
      drawY = (pageSize.height - drawH) / 2;
    } else {
      drawH = pageSize.height;
      drawW = drawH * imgAspect;
      drawX = (pageSize.width - drawW) / 2;
      drawY = 0;
    }
    page1.graphics.drawImage(bitmap, Rect.fromLTWH(drawX, drawY, drawW, drawH));

    // Page 2+: searchable OCR text with Turkish font support.
    if (text.isNotEmpty) {
      try {
        final fontBytes = await _loadRobotoFont();
        final font = PdfTrueTypeFont(fontBytes, 12);

        final page2 = document.pages.add();
        final textSize = page2.getClientSize();
        const margin = 40.0;

        final textElement = PdfTextElement(
          text: text,
          font: font,
          brush: PdfBrushes.black,
        );
        textElement.stringFormat = PdfStringFormat(lineSpacing: 5);

        textElement.draw(
          page: page2,
          bounds: Rect.fromLTWH(
            margin,
            margin,
            textSize.width - margin * 2,
            textSize.height - margin * 2,
          ),
          format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
        );
      } catch (e, stack) {
        AppErrorHandler.log(
          StringConstant.tagDocumentProcessingService,
          e,
          stack,
        );
      }
    }

    final pdfPath = '$dirPath/document_$timestamp.pdf';
    final bytes = await document.save();
    document.dispose();
    await File(pdfPath).writeAsBytes(bytes);
    return pdfPath;
  }

  // Downloads and caches Roboto Regular font for Syncfusion PDF generation.
  // Needed for Turkish character support (ş, ç, ğ, ı, ö, ü).
  Future<List<int>> _loadRobotoFont() async {
    if (_cachedFontBytes != null) return _cachedFontBytes!;

    final dirPath = await ImageProcessingHelper.getOutputDirectory();
    final fontFile = File('$dirPath/roboto_regular.ttf');

    if (await fontFile.exists()) {
      _cachedFontBytes = await fontFile.readAsBytes();
      return _cachedFontBytes!;
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.parse(StringConstant.robotoRegularFontUrl),
      );
      final response = await request.close();
      final builder = BytesBuilder();
      await response.forEach(builder.add);
      _cachedFontBytes = builder.toBytes();
      await fontFile.writeAsBytes(_cachedFontBytes!);
    } finally {
      client.close();
    }

    return _cachedFontBytes!;
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

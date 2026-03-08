# ImageFlow

A Flutter mobile application for intelligent image analysis and processing. ImageFlow automatically detects whether a photo contains a **face** or a **document**, then applies the appropriate ML-powered pipeline — grayscaling detected faces for a stylized result, or running full OCR, perspective correction, and PDF export for documents.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Core Services](#core-services)
  - [ContentDetectionService](#contentdetectionservice)
  - [FaceProcessingService](#faceprocessingservice)
  - [DocumentProcessingService](#documentprocessingservice)
- [Data Flow](#data-flow)
- [Pages & Navigation](#pages--navigation)
- [Data Persistence](#data-persistence)
- [Localization](#localization)
- [Getting Started](#getting-started)

---

## Features

- **Automatic content detection** — analyzes any image and routes it to the correct pipeline without user input.
- **Face processing** — detects all faces in an image and applies a grayscale filter to each detected region, compositing the result back onto the original color image.
- **Document scanning** — performs OCR, detects the document boundary using geometric algorithms, applies perspective correction, enhances contrast, and exports a searchable PDF.
- **Batch processing** — select multiple images from the gallery and process them sequentially with per-image and overall progress tracking.
- **Processing history** — every result is persisted locally and browsable from the home screen with delete support.
- **Searchable PDF export** — documents are exported as multi-page PDFs: page 1 is the processed image, subsequent pages contain the real searchable OCR text with Turkish character support via the Roboto font.
- **Multilingual UI** — English and Turkish translations via GetX i18n.
- **Dark theme** — fully dark UI with a pink/purple accent palette.

---

## Tech Stack

| Layer | Library / Tool |
|---|---|
| Framework | Flutter (Version `^3.38.5`) |
| State & DI | [GetX](https://pub.dev/packages/get) `^4.7.3` |
| ML — Face Detection | [google_mlkit_face_detection](https://pub.dev/packages/google_mlkit_face_detection) `^0.13.2` |
| ML — Text Recognition | [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition) `^0.15.1` |
| Image Manipulation | [image](https://pub.dev/packages/image) `^4.5.3` |
| PDF Generation | [syncfusion_flutter_pdf](https://pub.dev/packages/syncfusion_flutter_pdf) `^32.2.8` |
| Local Storage | [hive_flutter](https://pub.dev/packages/hive_flutter) `^1.1.0` |
| Image Picking | [image_picker](https://pub.dev/packages/image_picker) `^1.0.7` |
| File Opening | [open_file](https://pub.dev/packages/open_file) `^3.5.10` |
| Responsive UI | [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) `^5.9.3` |
| Serialization | [json_annotation](https://pub.dev/packages/json_annotation) + [json_serializable](https://pub.dev/packages/json_serializable) |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
└── src/
    ├── core/                          # Shared infrastructure
    │   ├── bindings/
    │   │   └── app_bindings.dart      # GetX lazy dependency injection per route
    │   ├── cache/
    │   │   └── local_cache_service.dart  # Hive-backed history persistence
    │   ├── constants/
    │   │   ├── app_theme.dart         # Global dark ThemeData
    │   │   ├── color_constant.dart    # Centralized color palette
    │   │   └── string_constant.dart   # Non-translatable constants & log tags
    │   ├── enum/
    │   │   └── processing_type.dart   # ProcessingType { face, document }
    │   ├── error/
    │   │   └── app_error_handler.dart # Centralized developer-console logging
    │   ├── localization/
    │   │   ├── app_translations.dart  # en_US / tr_TR translation maps
    │   │   └── locale_keys.dart       # Translation key constants
    │   ├── routes/
    │   │   ├── app_pages.dart         # GetPage route definitions
    │   │   └── app_routes.dart        # Route name constants
    │   └── services/
    │       ├── base/
    │       │   ├── base_processing_service.dart   # Abstract generic contract
    │       │   └── image_processing_helper.dart   # Shared EXIF/save utilities
    │       ├── model/
    │       │   ├── document_processing_result_model.dart
    │       │   └── face_processing_result_model.dart
    │       ├── content_detection_service.dart     # Auto face/document classifier
    │       ├── document_processing_service.dart   # Full document pipeline
    │       ├── face_processing_service.dart       # Full face pipeline
    │       └── service.dart                       # App-level init (Hive, UI)
    └── pages/                         # Feature modules
        ├── home/                      # History list + image picker entry
        ├── processing/                # Live progress screen
        ├── face_result/               # Before/after face result
        ├── pdf_result/                # Document result + PDF open
        ├── history_detail/            # Past result detail view
        ├── batch_processing/          # Multi-image queue processor
        ├── batch_summary/             # Batch results overview
        └── result/                    # Shared base result controller & model
```

Every page module follows the same internal structure:

```
<page>/
├── controller/   # GetxController — business logic & state
├── model/        # Data models for the page
├── view/         # Stateless Widget — pure layout
└── widgets/      # Reusable sub-widgets for that page
```

---

## Architecture

ImageFlow follows a **feature-first, GetX MVC** architecture.

### Separation of Concerns

| Layer | Responsibility |
|---|---|
| **View** | Pure layout — reads reactive state via `Obx`, no logic |
| **Controller** | Business logic, service calls, navigation, observable state |
| **Service** | Stateless (singleton) processing — ML Kit, image ops, PDF |
| **Model** | Immutable data classes with `json_serializable` codegen |
| **Cache** | Hive persistence accessed only through `LocalCacheService` |

### Dependency Injection

Each route's dependencies are injected lazily via `AppBindings`. When a route is pushed, `Get.lazyPut` registers the controller; when the route is popped, GetX disposes it automatically. This prevents memory leaks and avoids keeping heavy ML Kit objects alive across screens.

```dart
// Example — processing page binding
static BindingsBuilder<dynamic> processing() {
  return BindingsBuilder(() {
    Get.lazyPut<ProgressingViewController>(ProgressingViewController.new);
  });
}
```

### Base Abstractions

- **`BaseProcessingService<T>`** — all processing services implement `process(imagePath, {onProgress})` and `dispose()`, making them interchangeable and testable.
- **`BaseResultController`** — all result-page controllers extend this abstract class, enforcing a consistent `onActionTap()` / `onBackTap()` interface.
- **`ImageProcessingHelper`** — static utility methods shared by both face and document services: EXIF-aware image loading (`loadImage`), temp file saving (`saveTempBaked`), and timestamped JPEG saving (`saveImage`).

## Core Services

### ContentDetectionService

**File:** `lib/src/core/services/content_detection_service.dart`

The gateway to the entire processing pipeline. Before any pixel manipulation occurs, this service decides *which* pipeline the image should enter.

#### How It Works

1. Both **face detection** and **text recognition** are dispatched in **parallel** using `Future.wait`, so the combined detection time is roughly equal to whichever takes longer rather than the sum of both.
2. **Face detection** uses `FaceDetectorMode.fast` with a minimum face size of 10% of the image — tolerant enough to catch partial or distant faces.
3. **Text recognition** uses the standard ML Kit text recognizer.
4. **Priority rule**: if any face is detected → `ProcessingType.face`. If no face but ≥ 20 recognized characters are found → `ProcessingType.document`. Otherwise, defaults to `ProcessingType.face`.

```
Image
  ├─ FaceDetector.processImage()  ─┐
  │                                 ├─ Future.wait ─► decision
  └─ TextRecognizer.processImage() ─┘
```

#### Why This Matters

Without this service, the user would have to manually select "face mode" or "document mode" every time. The parallel dispatch keeps the detection overhead minimal (typically under 1 second on modern devices).

---

### FaceProcessingService

**File:** `lib/src/core/services/face_processing_service.dart`

Handles the complete face stylization pipeline. Implements `BaseProcessingService<FaceProcessingResultModel>`.

#### Pipeline Steps

```
1. Load image + bake EXIF orientation
        │
2. Save temp baked JPEG (so ML Kit coordinates align with decoded pixels)
        │
3. FaceDetector.processImage() — fast mode, min face 10%
        │
   ┌────┴────────────────────────┐
   │  No faces found?            │
   │  Return original unchanged  │
   └────────────────────────────-┘
        │  faces found
4. For each detected face:
   ├─ Clamp bounding rect to image bounds
   ├─ img.copyCrop(composite, x, y, w, h)
   ├─ img.grayscale(faceCrop)
   └─ img.compositeImage(composite, grayscaleFace, dstX, dstY)
        │
5. img.encodeJpg → save to documents directory
        │
6. Return FaceProcessingResultModel
   { originalPath, processedPath, facesDetected }
```

#### Key Design Decisions

- **EXIF baking before ML Kit**: Mobile cameras embed orientation metadata in EXIF but the pixel data is stored rotated. `img.bakeOrientation` rotates the pixels to match the visual orientation, then the corrected image is saved to a temp file. This ensures that the bounding boxes ML Kit returns map exactly onto the pixel coordinates of the decoded `img.Image`.
- **Composite approach**: Rather than processing a copy of the image, a `composite` clone is mutated in place. Each face crop is extracted, grayscaled, then composited back at the same position. This avoids creating multiple full-resolution copies in memory.
- **`onProgress` callback**: Progress values are emitted at defined checkpoints (0.1 → 0.25 → 0.5 → 0.85 → 1.0), allowing the UI to animate a smooth progress bar.

#### Result Model

```dart
class FaceProcessingResultModel {
  final String originalPath;
  final String processedPath;
  final int facesDetected;
}
```

---

### DocumentProcessingService

**File:** `lib/src/core/services/document_processing_service.dart`

#### Pipeline Overview

```
1.  Load image + EXIF bake → cap to 2500px (capResolution)
         │
2.  Prepare OCR-optimized copy (_prepareForOcr):
    ├─ Resize to 800–1400px range
    ├─ Grayscale
    ├─ Gaussian blur (radius=1) — smooths sensor noise
    ├─ Sharpen convolution [0,-1,0,-1,5,-1,0,-1,0]
    ├─ Contrast 1.8 + brightness 1.05
    └─ Normalize histogram (0–255)
         │
3.  ML Kit OCR on optimized copy
    └─ Retry on original file if result is empty
         │
4.  Document boundary detection (_detectAndCropDocument):
    ├─ Strategy A: OCR corner-point quad detection
    │   ├─ Collect all cornerPoints from text blocks + lines
    │   ├─ Build convex hull (Andrew's monotone chain, O(n log n))
    │   ├─ Find 4 extreme quad corners (sum/diff heuristic)
    │   ├─ Expand quad outward by 12% from centroid
    │   └─ Perspective correction via img.copyRectify
    ├─ Strategy B: Luminance-based paper detection
    │   ├─ Downsample 4×, convert to grayscale
    │   ├─ Sample background brightness from corner patches
    │   ├─ Sample paper brightness from center third
    │   ├─ Classify pixels (paper vs background) by proximity
    │   ├─ Find paper row/col boundaries at 55% threshold
    │   ├─ Gradient-based edge refinement (±30px neighbourhood)
    │   └─ Axis-aligned crop scaled back to original coordinates
    └─ Strategy C: OCR bounding box crop with 40px padding
         │
5.  Contrast enhancement (contrast=1.3, brightness=1.05)
         │
6.  Save processed JPEG (prefix: doc_processed, quality=85)
         │
7.  Generate PDF:
    ├─ Page 1: processed image (aspect-ratio-scaled to A4)
    └─ Page 2+: searchable OCR text (Roboto font, paginated)
         │
8.  Return DocumentProcessingResultModel
    { originalPath, processedImagePath, pdfPath, recognizedText }
```

#### OCR Preprocessing (`_prepareForOcr`)

Raw photos are unsuitable for OCR due to JPEG compression artifacts, colour noise, and varying contrast. A dedicated preprocessing chain runs on a downscaled copy (capped at 1400px on the longest side) to maximize recognition accuracy:

| Step | Operation | Purpose |
|---|---|---|
| 1 | Resize to 800–1400px | Bounds compute cost; tiny images are upscaled |
| 2 | `img.grayscale` | Removes colour noise irrelevant to text |
| 3 | `img.gaussianBlur(radius: 1)` | Smooths JPEG artifacts mistaken for strokes |
| 4 | Sharpen convolution | Restores text edges after blur |
| 5 | `adjustColor(contrast: 1.8, brightness: 1.05)` | Pushes text toward pure black on white |
| 6 | `img.normalize(min: 0, max: 255)` | Maximizes histogram dynamic range |

#### Document Boundary Detection

Three strategies are tried in order of accuracy:

**Strategy A — OCR Corner-Point Quad (primary)**

ML Kit returns `cornerPoints` for each recognized text block and line. These points approximate the convex boundary of the actual text area. The algorithm:

1. Collects all corner points from all blocks and lines.
2. Computes the **convex hull** using Andrew's monotone chain algorithm (O(n log n)) to find the outermost boundary.
3. Reduces the hull to **4 extreme quad corners** using the sum/difference heuristic:
   - Top-left: minimum `x + y`
   - Bottom-right: maximum `x + y`
   - Top-right: maximum `x - y`
   - Bottom-left: minimum `x - y`
4. **Expands** the quadrilateral 12% outward from its centroid to account for margins not covered by text.
5. Applies **perspective correction** via `img.copyRectify`, which maps the skewed quadrilateral onto a rectangle whose dimensions are the max of each pair of opposite edge lengths.

**Strategy B — Luminance Paper Detection (fallback)**

When OCR yields too few points for a reliable quad, the service falls back to a pixel-brightness approach:

1. Downsamples the image 4× for speed.
2. Measures **background brightness** from 5×5 corner patches (median).
3. Measures **paper brightness** from the center third of the image (mean).
4. Rejects detection if the contrast between paper and background is < 15 luminance units.
5. Classifies every pixel as paper or background based on which brightness value it is closer to.
6. Finds paper-row and paper-column boundaries at a 55% pixel threshold.
7. Refines each boundary using a gradient scan within a ±30px neighbourhood, accepting refinement only if the gradient exceeds 15% of the image dimension.
8. Scales crop coordinates back to original resolution.

**Strategy C — OCR Bounding Box (last resort)**

If both above strategies fail, the service simply unions all OCR block bounding boxes and crops to that region with 40px padding on each side.

#### PDF Generation (`_generatePdf`)

The generated PDF has two sections:

- **Page 1** — the processed JPEG, scaled to fit an A4 page while preserving aspect ratio.
- **Pages 2+** — the normalized OCR text rendered as real searchable PDF text elements using `PdfTextElement` with `PdfLayoutType.paginate` (auto-overflow to new pages). The Roboto Regular TrueType font is used to support special characters (Turkish ş, ç, ğ, ı, ö, ü and Latin diacritics). The font file is **downloaded once** from Google Fonts and **cached** to the app documents directory to avoid repeated network requests.

#### OCR Text Normalization (`_normalizeOcrText`)

Raw ML Kit output often contains spurious line breaks where text wraps within a single sentence. The normalizer:

1. Trims and collapses whitespace on each line.
2. Joins consecutive lines into a single paragraph unless the previous line ends with a sentence-ending character (`.`, `!`, `?`, `:`).
3. Preserves genuine paragraph breaks (blank lines in the OCR output).

#### Result Model

```dart
class DocumentProcessingResultModel {
  final String originalPath;
  final String processedImagePath;
  final String pdfPath;
  final String recognizedText;
}
```

---

## Data Flow

### Single Image

```
User taps FAB
      │
HomeViewController.onNewCaptureTap()
      │  shows ChooseSourceDialog
      │
image_picker → file.path
      │
Navigate → /processing (ProcessingArgsModel { imagePath })
      │
ProgressingViewController.onInit()
      │  400ms delay (lets route animation complete)
      │
ContentDetectionService.detect(imagePath)
      │
   ┌──┴──────────────────────────┐
face?                       document?
   │                             │
FaceProcessingService        DocumentProcessingService
.process(imagePath)          .process(imagePath)
   │                             │
   └──────────┬──────────────────┘
              │
   LocalCacheService.saveHistoryItem()
              │
   Navigate → /face-result  OR  /pdf-result
```

### Batch Images

```
User taps "Batch Gallery"
      │
image_picker.pickMultiImage()
      │
Copy each file to app documents (survives OS temp cleanup)
      │
Navigate → /batch-processing (List<String> paths)
      │
BatchProcessingController._processQueue()
  For each image (sequential):
    ├─ ContentDetectionService.detect()
    ├─ FaceProcessingService or DocumentProcessingService
    └─ LocalCacheService.saveHistoryItem()
      │
Navigate → /batch-summary (List<BatchItemResult>)
      │
Tap item → /face-result or /pdf-result
```

---

## Pages & Navigation

| Route | Class | Purpose |
|---|---|---|
| `/home` | `HomeView` | History list, FAB for new capture |
| `/processing` | `ProcessingView` | Animated progress bar, step description |
| `/face-result` | `FaceResultView` | Before/after image comparison |
| `/pdf-result` | `PdfResultView` | Processed image preview + "Open PDF" |
| `/history-detail` | `HistoryDetailView` | Metadata (date, type, file size) + PDF open |
| `/batch-processing` | `BatchProcessingView` | Queue list with per-item + overall progress |
| `/batch-summary` | `BatchSummaryView` | Success/failure counts, tap to view result |

Navigation is handled entirely through GetX named routes (`Get.toNamed`, `Get.offNamed`, `Get.back`). Arguments are passed as strongly-typed model objects (`ProcessingArgsModel`, `ResultArgsModel`, `HistoryItemModel`, `List<String>`, `List<BatchItemResult>`).

---

## Data Persistence

History is stored with **Hive** via `LocalCacheService`:

- Each `HistoryItemModel` is JSON-encoded (`json_serializable`) and stored in a `Box<String>` keyed by a timestamp-based ID.
- Items are loaded sorted newest-first.
- Deletion removes the entry from both the in-memory reactive list and the Hive box.

```dart
class HistoryItemModel {
  final String id;
  final ProcessingType processingType;   // face | document
  final DateTime date;
  final String? thumbnailPath;           // original image
  final String? processedImagePath;      // face: processed JPEG, doc: enhanced JPEG
  final String? pdfPath;                 // document only
}
```

All processed files (JPEGs, PDFs, cached font) are written to `getApplicationDocumentsDirectory()` which persists across app launches and is not cleared by the OS.

---

## Localization

The app uses GetX's built-in `Translations` system. Currently supported locales:

| Locale | Language |
|---|---|
| `en_US` | English (default + fallback) |
| `tr_TR` | Turkish |

All user-visible strings go through `LocaleKeys` constants and the `.tr` extension. Non-translatable strings (box names, file prefixes, log tags, font URL) live in `StringConstant`.

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.4`
- Xcode (iOS builds) / Android Studio (Android builds)
- CocoaPods (iOS)

### Install & Run

```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code
dart run build_runner build --delete-conflicting-outputs

# Run on a connected device or simulator
flutter run
```


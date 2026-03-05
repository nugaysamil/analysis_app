import 'package:analysis_app/src/common/pages/processing/model/processing_args_model.dart';
import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:analysis_app/src/core/services/content_detection_service.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:analysis_app/src/pages/home/widgets/choose_source/choose_source_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Manages home screen state: history list, image picking, navigation.
class HomeViewModel extends GetxController {
  final RxList<HistoryItemModel> historyItems = <HistoryItemModel>[].obs;
  final RxBool isDetecting = false.obs;
  final ImagePicker _picker = ImagePicker();

  // Formats a DateTime for display on history cards.
  String formatHistoryDate(DateTime date) =>
      DateFormat(StringConstant.dateFormat).format(date);

  // Opens the choose source dialog (Camera / Gallery).
  void onNewCaptureTap() {
    showDialog<ImageSource>(
      context: Get.context!,
      builder: (_) => ChooseSourceDialogWidget(
        onCameraTap: () => Get.back(result: ImageSource.camera),
        onGalleryTap: () => Get.back(result: ImageSource.gallery),
      ),
    ).then((source) {
      if (source != null) _pickImage(source);
    });
  }

  // Removes a history item by its id.
  void deleteItem(String id) {
    historyItems.removeWhere((item) => item.id == id);
  }

  // Inserts a new item at the top of the history list.
  void addItem(HistoryItemModel item) {
    historyItems.insert(0, item);
  }

  // Picks an image, auto-detects content type, navigates to processing,
  // then adds result to history on return.
  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (file == null) return;

    final path = file.path;

    // Auto-detect content type using ML Kit.
    isDetecting.value = true;
    final processingType = await ContentDetectionService.instance.detect(path);
    isDetecting.value = false;

    await Get.toNamed<void>(
      AppRoutes.processing,
      arguments: ProcessingArgsModel(
        imagePath: path,
        processingType: processingType,
      ),
    );

    addItem(
      HistoryItemModel(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        processingType: processingType,
        date: DateTime.now(),
        thumbnailPath: path,
      ),
    );
  }

  // Navigates to the history detail screen with the selected item.
  void onItemTap(HistoryItemModel item) {
    Get.toNamed<void>(AppRoutes.historyDetail, arguments: item);
  }
}

import 'package:analysis_app/src/pages/processing/model/processing_args_model.dart';
import 'package:analysis_app/src/core/cache/local_cache_service.dart';
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

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  // Loads persisted history items from local cache.
  void _loadHistory() {
    final items = LocalCacheService.instance.getHistoryItems();
    historyItems.assignAll(items);
  }

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

  // Removes a history item from both the local list and persistent cache.
  Future<void> deleteItem(String id) async {
    historyItems.removeWhere((item) => item.id == id);
    await LocalCacheService.instance.deleteHistoryItem(id);
  }

  // Picks an image, auto-detects content type, navigates to processing,
  // then refreshes history list from cache on return.
  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
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

    // Refresh history from cache after returning from the processing flow.
    _loadHistory();
  }

  // Navigates to the history detail screen with the selected item.
  void onItemTap(HistoryItemModel item) {
    Get.toNamed<void>(AppRoutes.historyDetail, arguments: item);
  }
}

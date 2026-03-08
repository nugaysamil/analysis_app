import 'package:analysis_app/src/pages/processing/model/processing_args_model.dart';
import 'package:analysis_app/src/core/cache/local_cache_service.dart';
import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/error/app_error_handler.dart';
import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:analysis_app/src/pages/home/widgets/choose_source/choose_source_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Manages home screen state: history list, image picking, navigation.
class HomeViewController extends GetxController {
  final RxList<HistoryItemModel> historyItems = <HistoryItemModel>[].obs;
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

  // Opens the choose source dialog (Camera / Gallery / Batch Gallery).
  void onNewCaptureTap() {
    showDialog<ImageSource>(
      context: Get.context!,
      builder: (_) => ChooseSourceDialogWidget(
        onCameraTap: () => Get.back(result: ImageSource.camera),
        onGalleryTap: () => Get.back(result: ImageSource.gallery),
        onBatchGalleryTap: () {
          Get.back<void>();
          pickMultipleImages();
        },
      ),
    ).then((source) {
      if (source != null) _pickImage(source);
    });
  }

  // Removes a history item from both the local list and persistent cache.
  Future<void> deleteItem(String id) async {
    try {
      historyItems.removeWhere((item) => item.id == id);
      await LocalCacheService.instance.deleteHistoryItem(id);
    } catch (e, stack) {
      AppErrorHandler.log(StringConstant.tagHomeViewModel, e, stack);
    }
  }

  // Picks an image and navigates to processing immediately.
  // Content detection happens on the processing screen.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) return;

      await Get.toNamed<void>(
        AppRoutes.processing,
        arguments: ProcessingArgsModel(imagePath: file.path),
      );

      // Refresh history from cache after returning from the processing flow.
      _loadHistory();
    } catch (e, stack) {
      AppErrorHandler.log(StringConstant.tagHomeViewModel, e, stack);
    }
  }

  // Picks multiple images from gallery and navigates to batch processing.
  Future<void> pickMultipleImages() async {
    try {
      final files = await _picker.pickMultiImage();
      if (files.isEmpty) return;

      final paths = files.map((f) => f.path).toList();

      await Get.toNamed<void>(AppRoutes.batchProcessing, arguments: paths);

      // Refresh history from cache after returning from the batch flow.
      _loadHistory();
    } catch (e, stack) {
      AppErrorHandler.log(StringConstant.tagHomeViewModel, e, stack);
    }
  }

  // Navigates to the history detail screen with the selected item.
  void onItemTap(HistoryItemModel item) {
    Get.toNamed<void>(AppRoutes.historyDetail, arguments: item);
  }
}

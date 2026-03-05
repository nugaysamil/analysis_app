import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:analysis_app/src/pages/home/widgets/choose_source/choose_source_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HomeViewModel extends GetxController {
  final RxList<HistoryItemModel> historyItems = <HistoryItemModel>[].obs;
  final ImagePicker _picker = ImagePicker();

  String formatHistoryDate(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);

  void deleteItem(String id) {
    historyItems.removeWhere((item) => item.id == id);
  }

  void addItem(HistoryItemModel item) {
    historyItems.insert(0, item);
  }

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

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file == null) return;

    final processingType = ProcessingType.face;
    final path = file.path;

    await Get.toNamed<void>(
      AppRoutes.processing,
      arguments: {
        'imagePath': path,
        'processingType': processingType,
      },
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

  void onItemTap(HistoryItemModel item) {
    // Navigate to result detail screen
  }
}

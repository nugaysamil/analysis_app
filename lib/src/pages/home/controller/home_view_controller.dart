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
    Get.dialog<void>(
      ChooseSourceDialogWidget(
        onCameraTap: _onCameraTap,
        onGalleryTap: _onGalleryTap,
      ),
      barrierColor: Colors.black54,
    );
  }

  void _onCameraTap() {
    Get.back<void>();
    _pickImage(ImageSource.camera);
  }

  void _onGalleryTap() {
    Get.back<void>();
    _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file == null) return;

    addItem(
      HistoryItemModel(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        processingType: ProcessingType.face,
        date: DateTime.now(),
        thumbnailPath: file.path,
      ),
    );
  }

  void onItemTap(HistoryItemModel item) {
    // Navigate to result detail screen
  }
}

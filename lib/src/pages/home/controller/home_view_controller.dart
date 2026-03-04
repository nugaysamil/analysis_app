import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeViewModel extends GetxController {
  final RxList<HistoryItemModel> historyItems = <HistoryItemModel>[].obs;

  String formatHistoryDate(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);

  void deleteItem(String id) {
    historyItems.removeWhere((item) => item.id == id);
  }

  void addItem(HistoryItemModel item) {
    historyItems.insert(0, item);
  }

  void onNewCaptureTap() {
    // Navigate to capture screen
  }

  void onItemTap(HistoryItemModel item) {
    // Navigate to result detail screen
  }
}

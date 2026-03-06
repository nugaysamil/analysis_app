import 'dart:convert';

import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Singleton local caching service powered by Hive.
class LocalCacheService {
  LocalCacheService._();

  static final LocalCacheService _instance = LocalCacheService._();
  static LocalCacheService get instance => _instance;

  // Initializes Hive for Flutter and opens required boxes.
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(StringConstant.historyBox);
  }

  // ── History operations ──

  Box<String> get _historyBox => Hive.box<String>(StringConstant.historyBox);

  // Saves a history item to the history box (keyed by item id).
  Future<void> saveHistoryItem(HistoryItemModel item) async {
    final jsonString = jsonEncode(item.toJson());
    await _historyBox.put(item.id, jsonString);
  }

  // Returns all history items sorted by date (newest first).
  List<HistoryItemModel> getHistoryItems() {
    final items = <HistoryItemModel>[];
    for (final jsonString in _historyBox.values) {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      items.add(HistoryItemModel.fromJson(map));
    }
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  // Deletes a single history item by its id.
  Future<void> deleteHistoryItem(String id) async {
    await _historyBox.delete(id);
  }
}

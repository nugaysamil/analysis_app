import 'package:hive_flutter/hive_flutter.dart';

// Singleton local caching service powered by Hive.
class LocalCacheService {
  LocalCacheService._();

  static final LocalCacheService _instance = LocalCacheService._();
  static LocalCacheService get instance => _instance;

  static const String _defaultBoxName = 'app_cache';

  // Initializes Hive for Flutter and opens the default box.
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_defaultBoxName);
  }

  // Returns the default cache box.
  Box<dynamic> get _box => Hive.box<dynamic>(_defaultBoxName);

  // Stores a value with the given key.
  Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }

  // Retrieves a value by key, returns defaultValue if not found.
  T? get<T>(String key, {T? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue) as T?;
  }

  // Checks whether a key exists in the cache.
  bool containsKey(String key) {
    return _box.containsKey(key);
  }

  // Removes a single entry by key.
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  // Clears all entries from the default box.
  Future<void> clear() async {
    await _box.clear();
  }

  // Opens and returns a named box for isolated storage.
  Future<Box<T>> openBox<T>(String name) async {
    return Hive.openBox<T>(name);
  }

  // Closes all open Hive boxes.
  Future<void> dispose() async {
    await Hive.close();
  }
}

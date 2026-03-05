import 'package:analysis_app/src/core/cache/local_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Manages all initialization tasks before the app starts.
class Service {
  Service._();

  // Runs all init tasks in parallel.
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Future.wait([
      _initSystemUI(),
      _initServices(),
    ]);
  }

  // Screen orientation and status bar configuration.
  static Future<void> _initSystemUI() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  // Initializes Hive cache and registers GetX services.
  static Future<void> _initServices() async {
    await LocalCacheService.instance.init();
  }
}

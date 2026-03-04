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

  // Registers GetX services (add future services here).
  static Future<void> _initServices() async {}
}

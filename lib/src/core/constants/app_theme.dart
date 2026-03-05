import 'package:analysis_app/src/core/constants/color_constant.dart';
import 'package:flutter/material.dart';

// Global app theme configuration.
class AppTheme {
  AppTheme._();

  // Dark theme used throughout the app.
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: ColorConstant.scaffoldBackground,
        brightness: Brightness.dark,
      );
}

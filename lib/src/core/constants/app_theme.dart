import 'package:analysis_app/src/core/constants/color_constant.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: ColorConstant.scaffoldBackground,
        brightness: Brightness.dark,
      );
}

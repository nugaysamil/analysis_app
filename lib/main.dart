import 'package:analysis_app/src/core/constants/app_theme.dart';
import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/routes/app_pages.dart';
import 'package:analysis_app/src/core/services/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> main() async {
  await Service.init();
  runApp(const AnalysisApp());
}

class AnalysisApp extends StatelessWidget {
  const AnalysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852), 
      minTextAdapt: true, // Adapts font size to screen width
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: StringConstant.appTitle,
          theme: AppTheme.theme,
          initialRoute: AppPages.initial,
          getPages: AppPages.pages,
        );
      },
    );
  }
}

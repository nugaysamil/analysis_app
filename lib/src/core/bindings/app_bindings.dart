import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
import 'package:analysis_app/src/pages/processing/controller/processing_view_controller.dart';
import 'package:get/get.dart';

// Centralized binding management for all pages.
class AppBindings {
  AppBindings._();

  // Home page dependencies.
  static BindingsBuilder<dynamic> home() {
    return BindingsBuilder(() {
      Get.lazyPut<HomeViewModel>(HomeViewModel.new);
    });
  }

  // Processing page dependencies.
  static BindingsBuilder<dynamic> processing() {
    return BindingsBuilder(() {
      final args = Get.arguments as Map<String, dynamic>;
      Get.lazyPut<ProcessingViewModel>(
        () => ProcessingViewModel(
          imagePath: args['imagePath'] as String,
          processingType: args['processingType'] as ProcessingType,
        ),
      );
    });
  }
}

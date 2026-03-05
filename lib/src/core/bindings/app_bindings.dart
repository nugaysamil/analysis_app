import 'package:analysis_app/src/common/pages/processing/controller/processing_view_controller.dart';
import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
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
      Get.lazyPut<ProcessingViewModel>(ProcessingViewModel.new);
    });
  }
}

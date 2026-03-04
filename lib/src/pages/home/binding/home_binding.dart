import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeViewModel>(HomeViewModel.new);
  }
}

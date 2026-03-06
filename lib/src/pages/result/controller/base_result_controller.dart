import 'package:get/get.dart';

// Abstract base for all result page controllers.
abstract class BaseResultController extends GetxController {
  // Called when the bottom action button is tapped.
  void onActionTap();

  // Navigates back to the previous screen.
  void onBackTap() {
    Get.back<void>();
  }
}

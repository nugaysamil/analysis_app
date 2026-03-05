import 'package:get/get.dart';

// Abstract base for all result page controllers.
// Subclasses must provide page title, action button text, and action behaviour.
abstract class BaseResultViewModel extends GetxController {
  // Title displayed in the app bar.
  String get pageTitle;

  // Label for the bottom action button.
  String get actionButtonText;

  // Path of the original (unprocessed) image.
  String get originalImagePath;

  // Called when the bottom action button is tapped.
  void onActionTap();

  // Navigates back to the previous screen.
  void onBackTap() {
    Get.back<void>();
  }
}

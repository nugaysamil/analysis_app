import 'package:analysis_app/src/pages/result/controller/base_result_controller.dart';
import 'package:analysis_app/src/pages/result/model/result_args_model.dart';
import 'package:get/get.dart';

// Manages Face Result screen state, extends the shared base.
class FaceResultViewModel extends BaseResultController {
  String originalImagePath = '';
  String processedImagePath = '';
  int facesDetected = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as ResultArgsModel?;
    if (args == null) {
      Get.back<void>();
      return;
    }
    _initFromArgs(args);
  }

  // Parses navigation arguments and populates local state.
  void _initFromArgs(ResultArgsModel args) {
    originalImagePath = args.originalImagePath;
    processedImagePath = args.processedImagePath ?? '';
  }

  @override
  void onActionTap() {
    Get.back<void>();
  }
}

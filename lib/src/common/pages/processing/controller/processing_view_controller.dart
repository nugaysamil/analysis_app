import 'package:analysis_app/src/common/pages/processing/model/processing_args_model.dart';
import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:get/get.dart';

class ProcessingViewModel extends GetxController {

  final RxDouble progress = 0.0.obs;
  final RxString stepDescription = ''.obs;

  ProcessingArgsModel? get args => Get.arguments as ProcessingArgsModel?;

  @override
  void onInit() {
    super.onInit();
    if (args == null) {
      Get.back<void>();
      return;
    }
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    stepDescription.value = args?.processingType == ProcessingType.face
        ? StringConstant.detectingFaces
        : StringConstant.scanningDocument;

    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      progress.value = i / 10;
    }
  }
}

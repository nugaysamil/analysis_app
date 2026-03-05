import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:get/get.dart';

class ProcessingViewModel extends GetxController {
  final String imagePath;
  final ProcessingType processingType;

  ProcessingViewModel({
    required this.imagePath,
    required this.processingType,
  });

  final RxDouble progress = 0.0.obs;
  final RxString stepDescription = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    stepDescription.value = processingType == ProcessingType.face
        ? StringConstant.detectingFaces
        : StringConstant.scanningDocument;

    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      progress.value = i / 10;
    }
  }
}

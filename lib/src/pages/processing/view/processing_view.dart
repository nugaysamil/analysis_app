import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/processing/controller/processing_view_controller.dart';
import 'package:analysis_app/src/pages/processing/widgets/processing_image_widget.dart';
import 'package:analysis_app/src/pages/processing/widgets/processing_progress_widget.dart';

class ProcessingView extends GetView<ProgressingViewController> {
  const ProcessingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProcessingImageWidget(imagePath: controller.args?.imagePath ?? ''),
              SizedBox(height: 32.h),
              ProcessingProgressWidget(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

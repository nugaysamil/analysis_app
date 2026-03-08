import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/batch_processing/controller/batch_processing_controller.dart';
import 'package:analysis_app/src/pages/batch_processing/widgets/batch_progress_widget.dart';
import 'package:analysis_app/src/pages/batch_processing/widgets/batch_thumbnail_grid_widget.dart';

class BatchProcessingView extends GetView<BatchProcessingController> {
  const BatchProcessingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              Text(
                LocaleKeys.batchProcessing.tr,
                style: TextStyle(
                  color: ColorConstant.textWhite,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: BatchThumbnailGridWidget(controller: controller),
              ),
              BatchProgressWidget(controller: controller),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

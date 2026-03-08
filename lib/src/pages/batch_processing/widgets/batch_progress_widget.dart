import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/batch_processing/controller/batch_processing_controller.dart';
import 'package:analysis_app/src/pages/batch_processing/controller/batch_progress_mixin.dart';

class BatchProgressWidget extends StatefulWidget {
  const BatchProgressWidget({super.key, required this.controller});

  final BatchProcessingController controller;

  @override
  State<BatchProgressWidget> createState() => _BatchProgressWidgetState();
}

class _BatchProgressWidgetState extends State<BatchProgressWidget>
    with SingleTickerProviderStateMixin, BatchProgressMixin<BatchProgressWidget> {
  @override
  BatchProcessingController get batchController => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Text(
            widget.controller.stepDescription.value,
            style: TextStyle(
              color: ColorConstant.textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20.h),
        AnimatedBuilder(
          animation: animController,
          builder: (context, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progressAnim.value.clamp(0.0, 1.0),
                backgroundColor: ColorConstant.progressTrack,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  ColorConstant.primaryPink,
                ),
                minHeight: 6.h,
              ),
            );
          },
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Text(
            '${(widget.controller.overallProgress * 100).toInt()}%',
            style: TextStyle(
              color: ColorConstant.textGrey,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Text(
            '${widget.controller.results.length} / ${widget.controller.totalImages}',
            style: TextStyle(
              color: ColorConstant.textGrey,
              fontSize: 13.sp,
            ),
          ),
        ),
      ],
    );
  }
}

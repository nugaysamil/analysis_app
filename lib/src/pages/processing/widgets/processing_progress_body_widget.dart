import 'package:analysis_app/src/pages/processing/controller/processing_view_controller.dart';
import 'package:analysis_app/src/pages/processing/controller/processing_progress_mixin.dart';
import 'package:analysis_app/src/core/exports/exports.dart';

class ProcessingProgressBodyWidget extends StatefulWidget {
  const ProcessingProgressBodyWidget({super.key, required this.controller});

  final ProgressingViewController controller;

  @override
  State<ProcessingProgressBodyWidget> createState() =>
      _ProcessingProgressBodyWidgetState();
}

class _ProcessingProgressBodyWidgetState
    extends State<ProcessingProgressBodyWidget>
    with ProcessingProgressMixin<ProcessingProgressBodyWidget> {
  @override
  ProgressingViewController get progressController => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Text(
            widget.controller.stepDescription.value.isEmpty
                ? LocaleKeys.processing.tr
                : widget.controller.stepDescription.value,
            style: TextStyle(
              color: ColorConstant.textWhite,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: widget.controller.progress.value,
              backgroundColor: ColorConstant.progressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(
                ColorConstant.primaryPink,
              ),
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '${(widget.controller.progress.value * 100).toInt()}%',
            style: TextStyle(color: ColorConstant.textGrey, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

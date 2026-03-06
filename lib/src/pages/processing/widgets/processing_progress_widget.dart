import 'package:analysis_app/src/pages/processing/controller/processing_view_controller.dart';
import 'package:analysis_app/src/core/exports/exports.dart';

class ProcessingProgressWidget extends StatelessWidget {
  const ProcessingProgressWidget({super.key, required this.controller});

  final ProcessingViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Text(
            controller.hasError.value
                ? LocaleKeys.processingError.tr
                : LocaleKeys.processing.tr,
            style: TextStyle(
              color: controller.hasError.value
                  ? Colors.redAccent
                  : ColorConstant.textWhite,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          if (!controller.hasError.value)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: controller.progress.value),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: ColorConstant.progressTrack,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      ColorConstant.primaryPink,
                    ),
                    minHeight: 6.h,
                  ),
                );
              },
            ),
          SizedBox(height: 16.h),
          Text(
            controller.stepDescription.value,
            style: TextStyle(
              color: ColorConstant.textGrey,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

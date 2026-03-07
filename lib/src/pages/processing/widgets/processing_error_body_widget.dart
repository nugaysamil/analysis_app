import 'package:analysis_app/src/pages/processing/controller/processing_view_controller.dart';
import 'package:analysis_app/src/core/exports/exports.dart';

class ProcessingErrorBodyWidget extends StatelessWidget {
  const ProcessingErrorBodyWidget({super.key, required this.controller});

  final ProgressingViewController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48.r),
        SizedBox(height: 16.h),
        Text(
          LocaleKeys.processingError.tr,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          controller.errorMessage.value,
          style: TextStyle(
            color: ColorConstant.textGrey,
            fontSize: 13.sp,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: controller.goBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstant.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              LocaleKeys.goBack.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

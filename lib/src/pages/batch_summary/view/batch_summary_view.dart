import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/batch_summary/controller/batch_summary_controller.dart';
import 'package:analysis_app/src/pages/batch_summary/widgets/batch_summary_header_widget.dart';
import 'package:analysis_app/src/pages/batch_summary/widgets/batch_summary_list_widget.dart';

class BatchSummaryView extends GetView<BatchSummaryController> {
  const BatchSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            BatchSummaryHeaderWidget(controller: controller),
            SizedBox(height: 24.h),
            Expanded(
              child: BatchSummaryListWidget(controller: controller),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: controller.goHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstant.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.backToHome.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

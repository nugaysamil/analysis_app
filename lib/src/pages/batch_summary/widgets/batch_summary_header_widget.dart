import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/batch_summary/controller/batch_summary_controller.dart';
import 'package:analysis_app/src/pages/batch_summary/widgets/batch_stat_chip_widget.dart';

class BatchSummaryHeaderWidget extends StatelessWidget {
  const BatchSummaryHeaderWidget({super.key, required this.controller});

  final BatchSummaryController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: ColorConstant.primaryPink,
            size: 56.r,
          ),
          SizedBox(height: 16.h),
          Text(
            LocaleKeys.batchSummary.tr,
            style: TextStyle(
              color: ColorConstant.textWhite,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BatchStatChipWidget(
                label: LocaleKeys.successCount.tr
                    .replaceAll('@count', '${controller.successCount}'),
                color: Colors.greenAccent,
              ),
              SizedBox(width: 16.w),
              if (controller.failedCount > 0)
                BatchStatChipWidget(
                  label: LocaleKeys.failedCount.tr
                      .replaceAll('@count', '${controller.failedCount}'),
                  color: Colors.redAccent,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

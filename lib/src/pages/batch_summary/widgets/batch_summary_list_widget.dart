import 'dart:io';

import 'package:analysis_app/src/core/enum/processing_type.dart';
import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/batch_summary/controller/batch_summary_controller.dart';

class BatchSummaryListWidget extends StatelessWidget {
  const BatchSummaryListWidget({super.key, required this.controller});

  final BatchSummaryController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: controller.results.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = controller.results[index];
        return GestureDetector(
          onTap: () => controller.onItemTap(item),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: ColorConstant.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: item.isSuccess
                    ? Colors.greenAccent.withValues(alpha: 0.1)
                    : Colors.redAccent.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 56.r,
                    height: 56.r,
                    child: Image.file(
                      File(item.originalPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: ColorConstant.cardBackground,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: ColorConstant.textGrey,
                          size: 24.r,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.processingType == ProcessingType.face
                            ? LocaleKeys.faceProcessed.tr
                            : LocaleKeys.documentScan.tr,
                        style: TextStyle(
                          color: ColorConstant.textWhite,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.isSuccess
                            ? LocaleKeys.viewDetails.tr
                            : LocaleKeys.failed.tr,
                        style: TextStyle(
                          color: item.isSuccess
                              ? ColorConstant.textGrey
                              : Colors.redAccent,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  item.isSuccess ? Icons.check_circle : Icons.error,
                  color:
                      item.isSuccess ? Colors.greenAccent : Colors.redAccent,
                  size: 24.r,
                ),
                if (item.isSuccess) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right,
                    color: ColorConstant.textGrey,
                    size: 20.r,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

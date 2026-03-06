import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/history_detail/controller/history_detail_view_controller.dart';
import 'package:analysis_app/src/pages/history_detail/widgets/history_detail_metadata_row_widget.dart';

class HistoryDetailMetadataWidget extends StatelessWidget {
  const HistoryDetailMetadataWidget({super.key, required this.controller});

  final HistoryDetailViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorConstant.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          HistoryDetailMetadataRowWidget(
            label: LocaleKeys.date.tr,
            value: controller.formattedDate,
          ),
          Divider(color: ColorConstant.textGrey.withValues(alpha: 0.15), height: 24.h),
          HistoryDetailMetadataRowWidget(
            label: LocaleKeys.type.tr,
            value: controller.isFace
                ? LocaleKeys.faceProcessed.tr
                : LocaleKeys.documentScan.tr,
          ),
          Divider(color: ColorConstant.textGrey.withValues(alpha: 0.15), height: 24.h),
          HistoryDetailMetadataRowWidget(
            label: LocaleKeys.fileSize.tr,
            value: controller.fileSize,
          ),
        ],
      ),
    );
  }
}

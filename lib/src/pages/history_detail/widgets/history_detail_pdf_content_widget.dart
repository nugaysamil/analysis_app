import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/history_detail/controller/history_detail_view_controller.dart';
import 'package:analysis_app/src/pages/pdf_result/widgets/pdf_result_icon_widget.dart';

class HistoryDetailPdfContentWidget extends StatelessWidget {
  const HistoryDetailPdfContentWidget({super.key, required this.controller});

  final HistoryDetailViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        const PdfResultIconWidget(),
        SizedBox(height: 20.h),
        Text(
          LocaleKeys.documentTitle.tr,
          style: TextStyle(
            color: ColorConstant.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}

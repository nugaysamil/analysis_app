import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/pdf_result/controller/pdf_result_view_controller.dart';
import 'package:analysis_app/src/pages/pdf_result/widgets/pdf_result_icon_widget.dart';

class PdfResultPreviewWidget extends StatelessWidget {
  const PdfResultPreviewWidget({super.key, required this.controller});

  final PdfResultViewController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
        ],
      ),
    );
  }
}

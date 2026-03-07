import 'package:analysis_app/src/pages/result/widgets/result_action_button_widget.dart';
import 'package:analysis_app/src/pages/result/widgets/result_app_bar_widget.dart';
import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/history_detail/controller/history_detail_view_controller.dart';
import 'package:analysis_app/src/pages/history_detail/widgets/history_detail_face_content_widget.dart';
import 'package:analysis_app/src/pages/history_detail/widgets/history_detail_metadata_widget.dart';
import 'package:analysis_app/src/pages/history_detail/widgets/history_detail_pdf_content_widget.dart';

class HistoryDetailView extends StatelessWidget {
  const HistoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryDetailViewController>();
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            ResultAppBarWidget(
              title: controller.isFace
                  ? LocaleKeys.faceResult.tr
                  : LocaleKeys.pdfCreated.tr,
              onBackTap: controller.onBackTap,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    if (controller.isFace)
                      HistoryDetailFaceContentWidget(controller: controller)
                    else
                      HistoryDetailPdfContentWidget(controller: controller),
                    SizedBox(height: 24.h),
                    HistoryDetailMetadataWidget(controller: controller),
                  ],
                ),
              ),
            ),
            if (!controller.isFace)
              ResultActionButtonWidget(
                label: LocaleKeys.openPdf.tr,
                onTap: controller.onOpenPdfTap,
              ),
          ],
        ),
      ),
    );
  }
}

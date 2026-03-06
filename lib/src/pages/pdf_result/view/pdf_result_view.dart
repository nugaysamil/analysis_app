import 'package:analysis_app/src/pages/result/widgets/result_action_button_widget.dart';
import 'package:analysis_app/src/pages/result/widgets/result_app_bar_widget.dart';
import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/pdf_result/controller/pdf_result_view_controller.dart';
import 'package:analysis_app/src/pages/pdf_result/widgets/pdf_result_preview_widget.dart';

class PdfResultView extends StatelessWidget {
  const PdfResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdfResultViewModel>();
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            ResultAppBarWidget(
              title: LocaleKeys.pdfCreated.tr,
              onBackTap: controller.onBackTap,
            ),
            Expanded(
              child: PdfResultPreviewWidget(controller: controller),
            ),
            ResultActionButtonWidget(
              label: LocaleKeys.openPdf.tr,
              onTap: controller.onActionTap,
            ),
          ],
        ),
      ),
    );
  }
}

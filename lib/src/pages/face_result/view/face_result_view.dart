import 'package:analysis_app/src/pages/result/widgets/result_action_button_widget.dart';
import 'package:analysis_app/src/pages/result/widgets/result_app_bar_widget.dart';
import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/face_result/controller/face_result_view_controller.dart';
import 'package:analysis_app/src/pages/face_result/widgets/face_result_comparison_widget.dart';

class FaceResultView extends StatelessWidget {
  const FaceResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaceResultViewController>();
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            ResultAppBarWidget(
              title: LocaleKeys.faceResult.tr,
              onBackTap: controller.onBackTap,
            ),
            Expanded(
              child: FaceResultComparisonWidget(controller: controller),
            ),
            ResultActionButtonWidget(
              label: LocaleKeys.done.tr,
              onTap: controller.onActionTap,
            ),
          ],
        ),
      ),
    );
  }
}

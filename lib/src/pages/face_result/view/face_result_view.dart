import 'package:analysis_app/src/common/pages/result/widgets/result_action_button_widget.dart';
import 'package:analysis_app/src/common/pages/result/widgets/result_app_bar_widget.dart';
import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/face_result/controller/face_result_view_controller.dart';
import 'package:analysis_app/src/pages/face_result/widgets/face_result_comparison_widget.dart';

class FaceResultView extends StatelessWidget {
  const FaceResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaceResultViewModel>();
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            ResultAppBarWidget(
              title: controller.pageTitle,
              onBackTap: controller.onBackTap,
            ),
            Expanded(
              child: FaceResultComparisonWidget(controller: controller),
            ),
            ResultActionButtonWidget(
              label: controller.actionButtonText,
              onTap: controller.onActionTap,
            ),
          ],
        ),
      ),
    );
  }
}

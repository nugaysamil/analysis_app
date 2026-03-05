import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/face_result/controller/face_result_view_controller.dart';
import 'package:analysis_app/src/pages/face_result/widgets/face_result_image_card_widget.dart';

class FaceResultComparisonWidget extends StatelessWidget {
  const FaceResultComparisonWidget({super.key, required this.controller});

  final FaceResultViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Align(
        alignment: Alignment.topCenter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FaceResultImageCardWidget(
                label: LocaleKeys.before.tr,
                sublabel: LocaleKeys.original.tr,
                imagePath: controller.originalImagePath,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: FaceResultImageCardWidget(
                label: LocaleKeys.after.tr,
                sublabel: LocaleKeys.blackAndWhite.tr,
                imagePath: controller.processedImagePath,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

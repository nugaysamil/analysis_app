import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/face_result/widgets/face_result_image_card_widget.dart';
import 'package:analysis_app/src/pages/history_detail/controller/history_detail_view_controller.dart';

class HistoryDetailFaceContentWidget extends StatelessWidget {
  const HistoryDetailFaceContentWidget({super.key, required this.controller});

  final HistoryDetailViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FaceResultImageCardWidget(
            label: LocaleKeys.before.tr,
            sublabel: LocaleKeys.original.tr,
            imagePath: controller.imagePath,
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
    );
  }
}

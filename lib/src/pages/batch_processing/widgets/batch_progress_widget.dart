import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/batch_processing/controller/batch_processing_controller.dart';
import 'package:analysis_app/src/pages/batch_processing/controller/batch_progress_mixin.dart';

class BatchProgressWidget extends StatefulWidget {
  const BatchProgressWidget({super.key, required this.controller});

  final BatchProcessingController controller;

  @override
  State<BatchProgressWidget> createState() => _BatchProgressWidgetState();
}

class _BatchProgressWidgetState extends State<BatchProgressWidget>
    with SingleTickerProviderStateMixin, BatchProgressMixin<BatchProgressWidget> {
  @override
  BatchProcessingController get batchController => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Text(
            widget.controller.stepDescription.value,
            style: TextStyle(
              color: ColorConstant.textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
